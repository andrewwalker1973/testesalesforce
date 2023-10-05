import {LightningElement, wire, api} from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import getHoldings from '@salesforce/apex/SLSC_CTRL_InvestorsMulesoftData.getHoldings';
import FIN_ACCOUNT_ENTITY_NUMBER from '@salesforce/schema/FinServ__FinancialAccount__c.SLSC_EntityNumber__c';
import { getErrorMessage } from 'c/slscLwcInvestorErrorHandler';

const columns = [
    { label: 'Fund Acc number', fieldName: 'Fund Acc number' },
    { label: 'Fund Name', fieldName: 'Fund Name' },
    { label: 'Total fund units', fieldName: 'Total fund units' },
    { label: 'Latest unit price', fieldName: 'Latest unit price' },
    { label: 'Ceded units', fieldName: 'Adviser name' },
    { label: 'Market Value', fieldName: 'Market Value' },
];

export default class SlscLwcInvestors extends LightningElement {
    @api recordId;
    columns = columns;
    holdings;
    error;
    spinner = true;

    @wire(getRecord, { recordId: "$recordId", fields: [FIN_ACCOUNT_ENTITY_NUMBER] })
    account;

    connectedCallback() {
        getHoldings({finAccountId: this.recordId})
          .then((result) => {
              this.holdings = result;
          })
          .catch((error) => {
              let paramsNotSet = !this.getAccountEntityNumber();
              let strParamsDescription = 'Account.EntityNumber = ' + this.getAccountEntityNumber();
              this.error = getErrorMessage(paramsNotSet, error, strParamsDescription);
          })
          .finally( () => this.spinner = false)
    }

    getAccountEntityNumber() {
        return this.account.data?.fields?.SLSC_EntityNumber__c?.value;
    }
}