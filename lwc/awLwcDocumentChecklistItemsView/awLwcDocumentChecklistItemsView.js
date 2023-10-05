/**
 * @description LWC Component to see the DocumentChecklistItem related list with Edit and Delete functionality.
 *              This functionality is not available on custom objects at the time of building this component.
 *
 * @author Accenture
 *
 * @ADO storyNo: 117355
 *
 * @date May 2021
 */

import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { reduceErrors } from 'c/cmnLwcUtil';
import getDocumentListByParent from '@salesforce/apex/AW_CTRL_DocumentChecklistItem.getDocumentListByParent';
import deleteDocumentListItem from '@salesforce/apex/AW_CTRL_DocumentChecklistItem.deleteDocumentListItem';
import saveDocumentListItem from '@salesforce/apex/AW_CTRL_DocumentChecklistItem.saveDocumentListItem';

    const actions = [
        { label: 'Edit', name: 'Edit' },
        { label: 'Delete', name: 'Delete' },
    ];
    const columns = [
        {
            label: 'Name',
            fieldName: 'recordName',
            type:'url',
            typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_self" }
        },
        {
            label: 'Document Type',
            fieldName: 'DocumentType.MasterLabel',
        },
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        },
    ];

 export default class AwCmpDocDemo extends NavigationMixin(LightningElement) {
    error;
    columns = columns;
    @api recordId;
    @track documentChecklistModal = false;
    @track isNew = false;
    currentDocumentChecklistId;
    currentDocumentChecklistName;
    documentList = [];
    wiredDocumentList = [];
    @track insertedDocumentChecklistItemId;

    @wire(getDocumentListByParent, {parentRecordId: '$recordId'})
        getDocumentListByParent(result) {
           this.wiredDocumentList = result;
           if (result.data) {

                var data = result.data;
                var tempDocumentList = [];

                for (let row of data)
                {
                    const flattenedRow = {}

                    let rowKeys = Object.keys(row);

                    rowKeys.forEach((rowKey) => {
                        const singleNodeValue = row[rowKey];
                        if(singleNodeValue.constructor === Object)
                        {
                            this._flatten(singleNodeValue, flattenedRow, rowKey)
                        }
                        else
                        {
                            if(rowKey == 'Name')
                               {
                                   flattenedRow['recordName'] = "/" + row['Id'];
                               }
                            flattenedRow[rowKey] = singleNodeValue;
                        }
                    });
                    tempDocumentList.push(flattenedRow);
                }
                this.documentList = tempDocumentList;
           }
           else if (result.error) {
               this.error = result.error;
               this.documentList = undefined;
           }
        }


    handleRowAction( event ) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'Delete':
                deleteDocumentListItem({documentItemId: row.Id})
                    .then(result => {
                        this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', 'Record is deleted', 'success');
                        return refreshApex(this.wiredDocumentList);
                    })
                    .catch(error => {
                        var errorMessage = reduceErrors(error).join(' // ');
                        this.template.querySelector('c-cmn-lwc-toast').customNotification('Error deleting the document record', errorMessage, 'error');
                    });
            break;
            case 'Edit':
                this.editCurrentRecord(row);
            break;
            default:
        }
    }

    _flatten = (nodeValue, flattenedRow, nodeName) => {
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
            if(key == 'MasterLabel')
            {
               flattenedRow['MasterLabel']  = nodeValue[key];
            }
        })
    }

    editCurrentRecord(currentRow) {
        this.isNew = false;
        this.documentChecklistModal = true;

        // assign record details to the record edit form
        this.currentDocumentChecklistId = currentRow.Id;
        this.currentDocumentChecklistName = currentRow.Name;
    }

    closeModal() {
        this.documentChecklistModal = false;
    }

    newDocumentChecklistItemClick(){
        this.isNew = true;
        this.documentChecklistModal = true;

        // reset record details for new records
        this.currentDocumentChecklistId = '';
        this.currentDocumentChecklistName = '';
    }

    saveDocumentChecklistItem() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allValid) {
            const documentChecklistItem = {};

            if(this.currentDocumentChecklistId == ''){
                documentChecklistItem['documentChecklistItemId'] = null;
            }
            else{
                documentChecklistItem['documentChecklistItemId'] = this.currentDocumentChecklistId;
            }
            documentChecklistItem['documentChecklistItemName'] = this.template.querySelector("[data-field='document-checklist-name']").value;
            documentChecklistItem['documentChecklistItemParentId'] = this.recordId;

            saveDocumentListItem({ request: JSON.stringify(documentChecklistItem) })
                .then(result => {
                    this.insertedDocumentChecklistItemId = result;
                    this.template.querySelector('c-cmn-lwc-toast').successNotification();
                    this.closeModal();
                    refreshApex(this.wiredDocumentList);
                })
                .catch(error => {
                    var errorMessage = reduceErrors(error).join(' // ');
                    this.template.querySelector('c-cmn-lwc-toast').customNotification('Error creating/updating the record', errorMessage, 'error');
                });

        }
        else {
            this.template.querySelector('c-cmn-lwc-toast').requiredFieldsNotification();
        }
    }

 }