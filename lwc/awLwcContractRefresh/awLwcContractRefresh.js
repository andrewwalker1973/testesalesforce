/**
 * @description Component used to initiate a request to refresh a clients contracts
 *
 * @author jayanth.kumar.s@accenture.com, jason.van.beukering@accenture.com  @story 127566
 *
 * @date October 2022, May 2023
 */
import updateAccount from '@salesforce/apex/AW_CTRL_RefreshContracts.accountToUpdate';
import triggerRefreshContract from '@salesforce/apex/AW_CTRL_RefreshContracts.triggerRefreshContract';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import STATUS_FIELD from '@salesforce/schema/Account.AW_PoliciesRefreshStatus__c';
import DATE_FIELD from '@salesforce/schema/Account.AW_PoliciesRefreshStatusDate__c';
import {reduceErrors} from 'c/cmnLwcUtil';
import {getFieldValue, getRecord, getRecordNotifyChange} from 'lightning/uiRecordApi';
import {api, LightningElement, wire} from 'lwc';

const DELAY_PERIOD = 1000;
const FIELDS = [
	STATUS_FIELD,
	DATE_FIELD
];
const INTERVAL_PERIOD = 5000;
const TIMEOUT_PERIOD = 60000;
const STATUS_REQUESTED = 'Requested';
const STATUS_FAILED = 'Failed';
const STATUS_SUCCESSFUL = 'Successful';

const MESSAGE_FAILED = 'The policy refresh have failed,please try again or contact support at workbench@liberty.co.za';
const MESSAGE_SUCCESS = 'The policy refresh have been completed. Should you not see all your client\'s in force policies, please try again or contact support '
		+ 'at workbench@liberty.co.za';
const MESSAGE_REQUESTED = 'The policies have been requested. Should you not see all your client\'s in force policies, please try again or '
		+ 'contact support at workbench@liberty.co.za';
const MESSAGE_UNKNOWN_STATUS = 'The refresh was unsuccessful, please try again later or contact support at workbench@liberty.co.za';

export default class AwLwcContractRefresh extends LightningElement
{
	@api recordId;
	account;
	customMessage;
	disableRefreshButton = false;
	iconName;
	objectApiName = 'Account';
	statusValue;
	variantName;

	@wire(getRecord, {recordId: '$recordId', fields: FIELDS}) receiveRecord(result)
	{
		this.account = result;
		this.statusValue = getFieldValue(result.data, STATUS_FIELD);

		if(this.statusValue === STATUS_REQUESTED)
		{
			this.iconName = 'utility:forward_up';
			this.variantName = null;
			this.customMessage = MESSAGE_REQUESTED;
		}
		else if(this.statusValue === STATUS_SUCCESSFUL)
		{
			this.iconName = 'utility:success';
			this.variantName = 'success';
			this.customMessage = MESSAGE_SUCCESS;
		}
		else if(this.statusValue === STATUS_FAILED)
		{
			this.iconName = 'utility:error';
			this.variantName = 'error';
			this.customMessage = MESSAGE_FAILED;
		}
		else
		{
			this.iconName = null;
		}
	}

	contractsRefresh()
	{
		this.customMessage = null;
		this.disableRefreshButton = true;

		triggerRefreshContract({accountId: this.recordId})
		.then(result =>
		{
			if(result.callSuccessful)
			{
				let startTime = new Date();
				this.handleRecordUpdate(STATUS_REQUESTED);
				// Setting interval to be able to periodically poll the status
				let intervalId = setInterval(function()
				{
					getRecordNotifyChange([{recordId: this.recordId}]);
					// The value of the status is not getting reflected immediately, so adding a small delay.
					setTimeout(function()
					{
						let currentTime = new Date();
						if(this.statusValue !== STATUS_REQUESTED || (currentTime - startTime) > TIMEOUT_PERIOD)
						{
							this.disableRefreshButton = false;
							clearInterval(intervalId);

							if(this.statusValue === STATUS_REQUESTED)
							{
								this.customMessage = MESSAGE_REQUESTED;
								this.handleRecordUpdate(STATUS_FAILED);
							}
							else if(this.statusValue === STATUS_SUCCESSFUL)
							{
								this.customMessage = MESSAGE_SUCCESS;
								this.refreshView();
							}
							else if(this.statusValue === STATUS_FAILED)
							{
								this.customMessage = MESSAGE_FAILED;
							}
							else
							{
								this.customMessage = MESSAGE_UNKNOWN_STATUS;
							}
						}
					}.bind(this), DELAY_PERIOD);
				}.bind(this), INTERVAL_PERIOD);
			}
			else
			{
				this.disableRefreshButton = false;
				this.handleRecordUpdate(STATUS_FAILED);
				this.showToast('Error calling refresh service', result.callMessage, 'error');
			}
		})
		.catch(error =>
		{
			this.disableRefreshButton = false;
			this.handleRecordUpdate(STATUS_FAILED);
			//noinspection JSUnresolvedFunction
			let errorMessage = reduceErrors(error).join(' // ');
			this.showToast('Error calling refresh service', errorMessage, 'error');
		});
	}

	handleRecordUpdate(statusToUpdate)
	{
		let accountListToUpdate = [];
		let accountToUpdate = {
			'accountListToUpdate': ACCOUNT_OBJECT.objectApiName,
			'Id': this.recordId,
			'AW_PoliciesRefreshStatus__c': statusToUpdate,
			'AW_PoliciesRefreshStatusDate__c': new Date().toISOString()
		};
		accountListToUpdate.push(accountToUpdate);

		updateAccount({
			accountToUpdate: accountListToUpdate
		})
		.then(() =>
		{
		})
		.catch(error =>
		{
			//noinspection JSUnresolvedFunction
			let errorMessage = reduceErrors(error).join(' // ');
			this.showToast('Error updating Account Status', errorMessage, 'error');
		});
	}

	/**
	 * @description Raise custom event to refresh view. Event is handled by CMN_RefreshView Aura component.
	 *                The component needs to be added to the page for this to work.
	 *
	 * @see CMN_RefreshView.cmp (Aura component)
	 * @see https://mtr-design.com/news/salesforce-mini-how-to-refreshview-alternative-for-lwc
	 */
	refreshView()
	{
		document.dispatchEvent(new CustomEvent('aura://refreshView'));
	}

	showToast(title, message, variant)
	{
		this.template.querySelector('c-cmn-lwc-toast').customNotification(title, message, variant);
	}
}