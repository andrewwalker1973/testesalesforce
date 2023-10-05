/**
 *  @description LWC Component used to view link and authorize advise and AtWork
 *
 *  @author k.marakalala@accenture.com
 *
 *  @date March 2023
 */

import getAtWorkURLAction from '@salesforce/apex/AW_CTR_GetAtWorkURL.getAtWorkURL';
import getUserDetails from '@salesforce/apex/AW_CTR_GetAtWorkURL.getUserDetails';
import getAvalonURL from '@salesforce/apex/AW_CTR_GetAvalonURL.getAvalonBaseUrl';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {LightningElement,api, track, wire} from 'lwc';
import ACCOUNT_SKF_ID_FIELD from '@salesforce/schema/Account.AW_SKF_Id__c';
import OPPORTUNITY_SKF_ID_FIELD from '@salesforce/schema/Opportunity.Account.AW_SKF_Id__c';

export default class AwLwcAccessFinancialNeed extends NavigationMixin(LightningElement)
{
	@api recordId;
	@track displayConfirmationDialog = false;
	@track loader = false;
	@track atWorkIdUsername;
	@track atWorkURL;
	@track avalonURL;
	@track error;
	@track userRecord;
	@track userRecordError;

	@api isAccountObject = false;
	@api isOpportunityObject = false;
	accountRecord;
	opportunityRecord;
	@wire(getUserDetails, {recordId: '$recordId'})
	user(result)
	{
		if(result.data)
		{
			this.userRecord = result.data;
			this.atWorkIdUsername = this.userRecord.AW_AtWorkUsername__c;
			this.userRecordError = undefined;
		}
		else if(result.error)
		{
			this.userRecordError = result.error;
			this.userRecord = undefined;
		}
	}

	openConfirmationDialog()
	{
		this.displayConfirmationDialog = true;
	}

	closeConfirmationDialog()
	{
		this.displayConfirmationDialog = false;
	}

	getAtWorkURL()
	{
		const allValid = [...this.template.querySelectorAll('lightning-input')]
		.reduce((validSoFar, inputFields) =>
		{
			inputFields.reportValidity();
			return validSoFar && inputFields.checkValidity();
		}, true);

		if(allValid)
		{

			this.loader = true;
			this.clientAtWorkId = this.template.querySelector('[data-field=\'atwork-username\']').value;

			getAtWorkURLAction({recordId: this.recordId, atWorkUserId: this.clientAtWorkId})
			.then(result =>
			{
				if(result.callSuccessful)
				{
					this.loader = false;
					this.atWorkURL = result.secureUrlOrErrorMessage;
					this.error = undefined;
					this.navigateToAtWorkTab();
					this.displayConfirmationDialog = false;
				}
				else
				{
					this.loader = false;
					this.error = result.secureUrlOrErrorMessage;
					this.atWorkURL = undefined;
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', this.error, 'error');
				}
			})
			.catch(error =>
			{
				this.loader = false;
				this.error = error;
				this.atWorkURL = undefined;
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', error.body.message, 'error');
			});
		}
		else
		{
			// The form is not valid
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Field Required', 'Your atWork username is required to access the FNA.', 'error');
		}

	}
    //   Calling the navigateToAtWorkTab() method in the controller to obtain the base URL to atWork
	navigateToAtWorkTab()
	{
		this[NavigationMixin.Navigate]({
			type: 'standard__navItemPage',
			attributes: {
				apiName: 'AW_atWork'
			},
			state: {
				c__url: this.atWorkURL.toString()
			}
		});
	}

	//    Calling the getAvalonURL() method in the controller to obtain the base URL to avalon including the Identification number
	//    https://login-liberty-group-uat.avalon.co.za? clientid= IDENTIFICATION_NUMBER &context=fna
	getAvalonURL()
	{
				getAvalonURL({recordId: this.recordId})
				.then(result =>
				{
					//            Open Avalon in a new tab on the browser.
					window.open(result.toString(), 'clientContextAvalonTab');
				})
				.catch((error) =>
				{
					this.message = 'Error received: ' + error.body.message;
					const event = new ShowToastEvent({
						title: this.message,
						variant: 'error'
					});
					this.dispatchEvent(event);
				});
	}
	//accountRecord
	@wire(getRecord,{recordId: '$recordId', fields:[ACCOUNT_SKF_ID_FIELD]})
	returnedRecord({error, data})
	{
		if(error)
		{
			this.accountRecord = undefined;
		}
		else if(data)
		{
			this.accountRecord = data;
		}
	}

	@wire(getRecord,{recordId: '$recordId', fields:[OPPORTUNITY_SKF_ID_FIELD]})
	returnedOppRecord({error, data})
	{
		if(error)
		{
			this.opportunityRecord = undefined;
		}
		else if(data)
		{
			this.opportunityRecord = data;
		}
	}

	onclickAdvice()
	{
		if(this.isAccountObject)
		{
			if(getFieldValue(this.accountRecord, ACCOUNT_SKF_ID_FIELD))
			{
				this.getAvalonURL();

			}else
			{
				this.showStickyToast('Advice+ cannot be accessed at this time as SKF Id is not available.'
						+ ' Please contact workbench@liberty.co.za');
			}
		}
		else if(this.isOpportunityObject)
		{
			if(getFieldValue(this.opportunityRecord, OPPORTUNITY_SKF_ID_FIELD))
			{
				this.getAvalonURL();

			}else
			{
				this.showStickyToast('Advice+ cannot be accessed at this time as SKF Id is not available.'
						+ ' Please contact workbench@liberty.co.za');
			}
		}

	}

	onclickAdviceAtWork()
	{
		if(this.isAccountObject)
		{
			if(getFieldValue(this.accountRecord, ACCOUNT_SKF_ID_FIELD))
			{
				this.openConfirmationDialog();

			}else
			{
				this.showStickyToast('atWork cannot be accessed at this time as SKF Id is not available. Please contact workbench@liberty.co.za');
			}
		}
		else if(this.isOpportunityObject)
		{
			if(getFieldValue(this.opportunityRecord, OPPORTUNITY_SKF_ID_FIELD))
			{
				this.openConfirmationDialog();

			}else
			{
				this.showStickyToast('atWork cannot be accessed at this time as SKF Id is not available. Please contact workbench@liberty.co.za');
			}
		}
	}

	showStickyToast(message)
	{
		const evt = new ShowToastEvent({
			title: '',
			message: message,
			variant: 'error',
			mode: 'sticky'
		});
		this.dispatchEvent(evt);
	}

}