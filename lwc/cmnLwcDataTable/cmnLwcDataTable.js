/**
 * @description A LWC component for displaying API data in a dynamic table
 *
 * @author Accenture
 *
 * @date June 2021
 */

import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';

import { publishMessage } from 'c/cmnLightningMessageService'
import { MessageContext } from 'lightning/messageService'
import MC_OptionSelected from '@salesforce/messageChannel/CMN_MC_OptionSelected__c'

export default class CmnLwcDataTable extends LightningElement {

    @api rowId = '';
    @api csvListOfMaskedFields = '';
    @api csvListOfShownFields = '';
    @api inputPayload;
    @api isDynamic = false;
    @api isMultipleSelect = false;
    @api canCopySelectedTableRows = false;
    @api sortedBy = '';
    @api sortDirection = 'asc';
    @api outputPayload;
    @api isReadOnly = false;

    @wire(MessageContext) messageContext;

    data = [];
    columns = [];
    maskedFields = [];
    shownFields = [];
    renderTable = true;
    maxRowsSelected;

    connectedCallback() {
        if (this.csvListOfMaskedFields) {
            this.maskedFields = [... this.csvListOfMaskedFields.split(',')];
        }

        if (this.csvListOfShownFields) {
            this.shownFields = [... this.csvListOfShownFields.split(',')];
        }

        // If flag set, event is required to disable navigation until a row is selected
        if (this.isDynamic) {
            publishMessage(this.messageContext, MC_OptionSelected, { optionSelected: false });
        }

        if (this.isReadOnly) {
            this.maxRowsSelected = 0;
        } else {
            this.maxRowsSelected = this.isMultipleSelect ? 100 : 1;
        }

        this.parseJSONResponse();
    }

    /*
     * parses the JSON returned from the flow and splits the columns and rows values
     */
    parseJSONResponse() {
        const json = JSON.parse(this.inputPayload);
        this.data = [...json.rows];
        this.columns = [...json.columns];

        if (!!this.shownFields.length) {
            this.columns = this.columns.filter((currVal) => {
                if (this.shownFields.some(val => currVal.fieldName === val)) {
                    return currVal;
                }
            });
        }

        this.formatCurrencyFields();
        this.checkFieldsForMasking();
        this.renderTable = !!this.data.length;
    }

    /*
     * handles single row selection and passes the key attribute further on to the flow
     */
    handleRowSelection() {
        this.outputPayload = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.dispatchEvent(new CustomEvent('output_updated', {
            detail: [... this.outputPayload]
        }));
        publishMessage(this.messageContext, MC_OptionSelected, { optionSelected: !!this.outputPayload.length });
    }

    /*
     * displays a toast pop-up on top of the screen that contains a message
     */
    displayToastEvent(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    /*
     * adds rand currency to amount fields
     */
    addRandCurrencyToAmount(amount) {
        return 'R ' + amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
    }

    /*
     * formats and aligns all currency fields to standard currency
     */
    formatCurrencyFields() {
        let fieldsToBeFormatted = [];
        this.columns.forEach((col) => {
            if (col.type === 'currency') {
                fieldsToBeFormatted.push(col.fieldName);
            }
        });

        fieldsToBeFormatted.forEach((field) => {
            this.data.forEach((row, index, arr) => {
                arr[index][field] = addRandCurrencyToAmount(row[field]);
            });
        });
    }

    /*
     * handles masking of the sensitive data by adding one more column to the table
     */
    checkFieldsForMasking() {
        this.maskedFields.forEach((field) => {
            let maskedField = field + 'MASKED';
            this.data.forEach((row, index, arr) => {
                let maskedVal = String(row[field])
                    // replace all characters except the last 4 with an X
                    .replace(/.(?!.{0,3}$)/g, 'X')
                    // add a space after every 4 characters
                    .replace(/(.{4})/g, '$1 ')
                    .trim();
                Object.defineProperty(arr[index], maskedField,
                    {
                        value: maskedVal,
                        writable: false
                    });
            });

            let unmaskedIndex;
            this.columns.find((col, index) => {
                unmaskedIndex = index;
                return col.fieldName === field;
            });

            this.columns[unmaskedIndex].fieldName = maskedField;
        });
    }

    /*
     * @description internal function to sort the data in the table
     * @see handleSort()
     */
    sortBy(field, reverse, primer) {

        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };

    }

    /*
     * @description Sort handler to implement sorting of the columns
     */
    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;

    }

    /*
     * @description Copy table data rows to clipboard
     */
    copyContentToClipBoard() {
        let formattedContent = this.transformTextToBeCopied(this.outputPayload);
        this.copyToClipBoard(formattedContent);
    }

    /*
     * @description transform content to copy text friendly format
     */
    transformTextToBeCopied(content) {
        let finalString = '';
        content.forEach((row) => {
            for (let i = 0; i < Object.keys(row).length; i++) {
                let stringToBeModified = Object.keys(row)[i].replace(/([A-Z])/g, ' $1');
                if (String(Object.keys(row)[i]).includes('Date')) {
                    let tempDateTime = Object.values(row)[i].split('T');
                    finalString += stringToBeModified.charAt(0).toUpperCase() + stringToBeModified.slice(1) + ' : ' + tempDateTime[0] + ' ' + tempDateTime[1] + '\n';
                } else {
                    finalString += stringToBeModified.charAt(0).toUpperCase() + stringToBeModified.slice(1) + ' : ' + Object.values(row)[i] + '\n';
                }
            }
            finalString += '\n\n';
        });
        return finalString;
    }

    /*
     * @description copy the formatted text to the clipboard
     */
    copyToClipBoard(text) {
        let dummy = document.createElement("textarea");
        document.body.appendChild(dummy);
        dummy.value = text;
        dummy.select();
        document.execCommand("copy");
        document.body.removeChild(dummy);
    }
}