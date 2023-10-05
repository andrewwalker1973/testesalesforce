import FINANCIAL_ACCOUNT_PAID_TO_DATE_FIELD from '@salesforce/schema/FinServ__FinancialAccount__c.CMN_PaidtoDate__c';
import FINANCIAL_ACCOUNT_POLICY_NUMBER_FIELD from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c';
import FINANCIAL_ACCOUNT_PRODUCT_TYPE_FIELD from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c';
import FINANCIAL_ACCOUNT_START_DATE_FIELD from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__OpenDate__c';
import FINANCIAL_ACCOUNT_FREQUENCY_FIELD from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__PaymentFrequency__c';
import FINANCIAL_ACCOUNT_CONTRIBUTION_FIELD from '@salesforce/schema/FinServ__FinancialAccount__c.CMN_ContributionAmount__c';
import FINANCIAL_ACCOUNT_STATUS_FIELD from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__Status__c';

import INSURANCE_POLICY_START_DATE_FIELD from '@salesforce/schema/InsurancePolicy.AW_CommencementDate__c';
import INSURANCE_POLICY_FREQUENCY_FIELD from '@salesforce/schema/InsurancePolicy.AW_Frequency__c';
import INSURANCE_POLICY_POLICY_NUMBER_FIELD from '@salesforce/schema/InsurancePolicy.Name';
import INSURANCE_POLICY_PAID_TO_DATE_FIELD from '@salesforce/schema/InsurancePolicy.PaidToDate';
import INSURANCE_POLICY_PRODUCT_TYPE_FIELD from '@salesforce/schema/InsurancePolicy.PolicyType';
import INSURANCE_POLICY_CONTRIBUTION_FIELD from '@salesforce/schema/InsurancePolicy.PremiumAmount';
import INSURANCE_POLICY_STATUS_FIELD from '@salesforce/schema/InsurancePolicy.Status';

import {CONTRIBUTION, FREQUENCY, PAID_TO_DATE, POLICY_NUMBER, PRODUCT_TYPE, START_DATE, STATUS} from 'c/rscLwcChooseCPPPoliciesTable';
import {FlowNavigationNextEvent} from 'lightning/flowSupport';
import {api, LightningElement} from 'lwc';

const ID_FIELD = 'Id';

export default class RscLwcSendCppEmail extends LightningElement
{
	@api client;
	@api financialAdvisor;
	@api thirdParty;
	@api insurancePolicies = [];
	@api financialAccounts = [];
	sortDirection = 'asc';
	sortedBy = 'Name';

	isCancelPressed = false;

	get policies()
	{
		let insurancePolicies = this.insurancePolicies.map(policy =>
		{
			let policyObject = {};
			policyObject[POLICY_NUMBER] = policy[INSURANCE_POLICY_POLICY_NUMBER_FIELD.fieldApiName];
			policyObject[CONTRIBUTION] = policy[INSURANCE_POLICY_CONTRIBUTION_FIELD.fieldApiName];
			policyObject[FREQUENCY] = policy[INSURANCE_POLICY_FREQUENCY_FIELD.fieldApiName];
			policyObject[PAID_TO_DATE] = policy[INSURANCE_POLICY_PAID_TO_DATE_FIELD.fieldApiName];
			policyObject[START_DATE] = policy[INSURANCE_POLICY_START_DATE_FIELD.fieldApiName];
			policyObject[PRODUCT_TYPE] = policy[INSURANCE_POLICY_PRODUCT_TYPE_FIELD.fieldApiName];
			policyObject[STATUS] = policy[INSURANCE_POLICY_STATUS_FIELD.fieldApiName];
			policyObject[ID_FIELD] = policy[ID_FIELD];
			return policyObject;
		});

		let financialAccounts = this.financialAccounts.map(financialAccount =>
		{
			let financialAccountObject = {};
			financialAccountObject[POLICY_NUMBER] = financialAccount[FINANCIAL_ACCOUNT_POLICY_NUMBER_FIELD.fieldApiName];
			financialAccountObject[CONTRIBUTION] = financialAccount[FINANCIAL_ACCOUNT_CONTRIBUTION_FIELD.fieldApiName];
			financialAccountObject[FREQUENCY] = financialAccount[FINANCIAL_ACCOUNT_FREQUENCY_FIELD.fieldApiName];
			financialAccountObject[PAID_TO_DATE] = financialAccount[FINANCIAL_ACCOUNT_PAID_TO_DATE_FIELD.fieldApiName];
			financialAccountObject[START_DATE] = financialAccount[FINANCIAL_ACCOUNT_START_DATE_FIELD.fieldApiName];
			financialAccountObject[PRODUCT_TYPE] = financialAccount[FINANCIAL_ACCOUNT_PRODUCT_TYPE_FIELD.fieldApiName];
			financialAccountObject[STATUS] = financialAccount[FINANCIAL_ACCOUNT_STATUS_FIELD.fieldApiName];
			financialAccountObject[ID_FIELD] = financialAccount[ID_FIELD];
			return financialAccountObject;
		});

		return [...insurancePolicies, ...financialAccounts];
	}

	@api get isCancel()
	{
		return this.isCancelPressed;
	}

	get emailRecipientComponent()
	{
		return this.template.querySelector('c-rsc-lwc-choose-email-recipients');
	}

	get policyTableComponent()
	{
		return this.template.querySelector('c-rsc-lwc-choose-c-p-p-policies-table');
	}

	@api get recipients()
	{
		//noinspection JSUnresolvedVariable
		return this.emailRecipientComponent.recipients;
	}

	@api get selectedPolicies()
	{
		//noinspection JSUnresolvedVariable
		return this.template.querySelector('c-rsc-lwc-choose-c-p-p-policies-table').selectedPolicies;
	}

	handleNavigationEvent({detail})
	{
		switch(detail)
		{
			case 'NEXT':
				if(this.selectedPolicies.length > 0 && this.recipients.length > 0)
				{
					this.dispatchEvent(new FlowNavigationNextEvent());
				}

				if(this.selectedPolicies.length === 0)
				{
					//noinspection JSUnresolvedFunction
					this.policyTableComponent.showNoPoliciesSelectedError();
				}

				if(this.recipients.length === 0)
				{
					//noinspection JSUnresolvedFunction
					this.emailRecipientComponent.showNoRecipientsError();
				}
				break;

			case 'BACK':
				try
				{
					this.isCancelPressed = true;
					this.dispatchEvent(new FlowNavigationNextEvent());
				}
				catch(e)
				{
					console.error(e);
				}
				break;

			default:
				throw new Error('Invalid Flow Event Type');
		}
	}
}