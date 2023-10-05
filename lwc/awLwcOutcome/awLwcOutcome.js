import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import getClientAccountInfo from "@salesforce/apex/AW_CTR_ClientCommunity.getClientAccountInfo";
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import ACCOUNT_OUTCOME_FIELD from '@salesforce/schema/Account.AW_Outcome__c';

export default class AwLwcOutcome extends LightningElement {

    @track accountInfo;
    @track accountInfoError;
    @track displayDialog = false;
    wiredAccountInfo;

    @wire(getClientAccountInfo) account(result) {
        this.wiredAccountInfo = result;
        if (result.data) {
            this.accountInfo = result.data;
            this.accountInfoError = undefined;
        } else if (result.error) {
            this.accountInfoError = result.error;
            this.accountInfo = undefined;
        }
    }

    openDialog() {
        this.displayDialog = true;
    }

    closeDialog() {
        this.displayDialog = false;
    }

    saveOutcome() {

        const allValid = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allValid) {
            const fields = {};
            fields[ACCOUNT_ID_FIELD.fieldApiName] = this.accountInfo.Id;
            fields[ACCOUNT_OUTCOME_FIELD.fieldApiName] = this.template.querySelector("[data-field='account-outcome']").value;

            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    this.template.querySelector('c-cmn-lwc-toast').successNotification();
                    this.closeDialog();
                    // Display fresh data in the form
                    refreshApex(this.wiredAccountInfo);
                    this.template.querySelector('c-aw-lwc-doughnut-chart').updateChart();
                })
                .catch(error => {
                    this.template.querySelector('c-cmn-lwc-toast').customNotification('Error updating record', error.body.message, 'error');
                });
        }
        else {
            // The form is not valid
            this.template.querySelector('c-cmn-lwc-toast').customNotification('Something is wrong', 'Check your input and try again.', 'error');
        }

    }

}