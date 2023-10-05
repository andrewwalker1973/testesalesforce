import {LightningElement, api, wire} from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import getOnlineDetails from '@salesforce/apex/SLSC_CTRL_InvestorsMulesoftData.getInvestorRegistrationOnlineDetails';
import getSso from '@salesforce/apex/SLSC_CTRL_InvestorsMulesoftData.getInvestorRegistrationSso';
import ACCOUNT_ID_NUMBER_FIELD from '@salesforce/schema/Account.SLC_IDNumber__c';
import ACCOUNT_ID_TYPE_FIELD from '@salesforce/schema/Account.SLSC_IDType__c';
import { getErrorMessage } from 'c/slscLwcInvestorErrorHandler';

export default class SlscLwcInvestorRegistration extends LightningElement {
  @api recordId;
  onlineDetails;
  onlineDetailsError;
  onlineDetailsSpinner = true;
  sso;
  ssoError;
  ssoSpinner = true;

  @wire(getRecord, { recordId: "$recordId", fields: [ACCOUNT_ID_NUMBER_FIELD, ACCOUNT_ID_TYPE_FIELD] })
  account;

  connectedCallback() {
    console.log('recordId ', this.recordId);
    getOnlineDetails({accountId: this.recordId})
      .then((result) => {
        this.onlineDetails = result;
      })
      .catch((error) => {
        this.onlineDetailsError = this.handleError(error);
      })
      .finally( () => this.onlineDetailsSpinner = false)

    getSso({accountId: this.recordId})
      .then((result) => {
        this.sso = result;
      })
      .catch((error) => {
        this.ssoError = this.handleError(error);
      })
      .finally(() => this.ssoSpinner = false)
  }

  getAccountIdNumber() {
    return this.account.data?.fields?.SLC_IDNumber__c?.value;
  }

  getAccountIdType() {
    return this.account.data?.fields?.SLSC_IDType__c?.value;
  }

  handleError(error) {
    let paramsNotSet = !this.getAccountIdNumber() || !this.getAccountIdType();
    let strParamsDescription = 'Account.IDNumber = ' + this.getAccountIdNumber() + ' and Account.IDType = ' + this.getAccountIdType();
    return getErrorMessage(paramsNotSet, error, strParamsDescription);
  }
}