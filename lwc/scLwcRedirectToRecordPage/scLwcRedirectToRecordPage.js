/**
* @description Common Lightning web component used to navigate to record based on the recordId and objectApiName
*
* @author Accenture
*
* @date June 2021
*/

import { LightningElement, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ScLwcRedirectToRecordPage extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    connectedCallback(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectApiName,
                actionName: 'view'
            }
        });
   }
}