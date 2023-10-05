import {LightningElement, api, wire} from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import getHoldingDetails from '@salesforce/apex/SLSC_CTRL_InvestorsMulesoftData.getHoldingDetails';
import HOLDING_FUND_ACC_NUMBER from '@salesforce/schema/FinServ__FinancialHolding__c.SLSC_FundAccNumber__c';
import FIN_ACCOUNT_ENTITY_NUMBER from '@salesforce/schema/FinServ__FinancialHolding__c.FinServ__FinancialAccount__r.SLSC_EntityNumber__c';
import { getErrorMessage } from 'c/slscLwcInvestorErrorHandler';

export default class SlscLwcInvestor extends LightningElement {
  @api recordId;
  holdingDetails;
  error;
  spinner = true;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [FIN_ACCOUNT_ENTITY_NUMBER, HOLDING_FUND_ACC_NUMBER]
  })
  holding;

  connectedCallback() {
    getHoldingDetails({holdingId: this.recordId})
      .then((result) => {
        this.holdingDetails = result;
      })
      .catch((error) => {
        let paramsNotSet = !this.getEntityNumber() || !this.getFundAccNumber();
        let strParamsDescription = 'FinancialAccount.EntityNumber = ' + this.getEntityNumber() + ' and FinancialHolding.FundAccNumber = ' + this.getFundAccNumber();
        this.error = getErrorMessage(paramsNotSet, error, strParamsDescription);
      })
      .finally( () => this.spinner = false)
  }

  getFundAccNumber() {
    return this.holding.data?.fields?.SLSC_FundAccNumber__c?.value;
  }

  getEntityNumber() {
    return this.holding.data?.fields?.FinServ__FinancialAccount__r?.value?.fields?.SLSC_EntityNumber__c?.value;
  }
}