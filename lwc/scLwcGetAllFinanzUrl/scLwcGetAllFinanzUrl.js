/**
 * @description LWC Component used to invoke AllFinanz Web service and redirect user to the returned URL.
 *
 * @author d.pillay@accenture.com
 *
 * @date August 2021
 */
import { LightningElement } from 'lwc';
import getAllFinanzUrl from '@salesforce/apex/SC_CTRL_GetAllFinanzUrl.getUrl';
import { NavigationMixin } from 'lightning/navigation';

export default class ScLwcGetAllFinanzUrl extends NavigationMixin(LightningElement) {

    allFinanzUrl;
    identityNumber;
    contractNumber;
    isSpinner = false;

    getUrl(){

        const allValid = [...this.template.querySelectorAll('lightning-input')]
          .reduce((validSoFar, inputFields) => {
            inputFields.reportValidity();
            return validSoFar && inputFields.checkValidity();
          }, true);

        if (allValid) {
            this.isSpinner = true;

            this.identityNumber = this.template.querySelector("[data-field='identity-number']").value;
            this.contractNumber = this.template.querySelector("[data-field='contract-number']").value;

            getAllFinanzUrl({ identityNumber: this.identityNumber, contractNumber: this.contractNumber })
                .then(result => {
                    this.isSpinner = false;

                    if(result.callSuccessful){
                        this.allFinanzUrl = result.interviewUrlOrErrorMessage;
                        this.openUrl();
                        this.clearForm();
                    }
                    else{
                        this.showToast('Error', result.interviewUrlOrErrorMessage, 'error');
                    }
                })
                .catch(error => {
                    this.isSpinner = false;
                    this.showToast('Error', 'An unexpected error occurred. Please contact your system administrator', 'error'); 
                });
        }
    }

    openUrl(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.allFinanzUrl
            }
        },
        false
        );
    }

    clearForm() {
        this.identityNumber = '';
        this.contractNumber = '';
    }


    /**
     * Used to show toast message
     */
    showToast(title, message, variant)
    {
        this.template.querySelector('c-cmn-lwc-toast').customNotification(title, message, variant);
    }
}