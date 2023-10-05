import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import getBankDetails from '@salesforce/apex/SLSC_CTRL_InvestorsMulesoftData.getBankDetails';
import ACCOUNT_ID_NUMBER_FIELD from '@salesforce/schema/Account.SLC_IDNumber__c';
import ACCOUNT_ID_TYPE_FIELD from '@salesforce/schema/Account.SLSC_IDType__c';
import { getErrorMessage } from 'c/slscLwcInvestorErrorHandler';

const columns = [
  { label: 'Bank name', fieldName: 'Bank name' },
  { label: 'Branch name', fieldName: 'Branch name' },
  { label: 'Account holder name', fieldName: 'Account holder name' },
  { label: 'Account number', fieldName: 'Account number' },
  { label: 'Account type', fieldName: 'Account type' },
  { label: 'E-trade status', fieldName: 'E-trade status' },
];

export default class slscLwcBankDetails extends LightningElement {
  @api recordId;
  @api
  columns = columns;
  error;
  bankDetails;
  spinner = true;

  @wire(getRecord, { recordId: "$recordId", fields: [ACCOUNT_ID_NUMBER_FIELD, ACCOUNT_ID_TYPE_FIELD] })
  account;

  connectedCallback() {
    console.log('recordId ', this.recordId);
    getBankDetails({accountId: this.recordId})
      .then((result) => {
        this.bankDetails = result;
      })
      .catch((error) => {
        let paramsNotSet = !this.getAccountIdNumber() || !this.getAccountIdType();
        let strParamsDescription = 'Account.IDNumber = ' + this.getAccountIdNumber() + ' and Account.IDType = ' + this.getAccountIdType();
        this.error = getErrorMessage(paramsNotSet, error, strParamsDescription);
      })
      .finally( () => this.spinner = false)
  }

  getAccountIdNumber() {
    return this.account.data?.fields?.SLC_IDNumber__c?.value;
  }

  getAccountIdType() {
    return this.account.data?.fields?.SLSC_IDType__c?.value;
  }
}