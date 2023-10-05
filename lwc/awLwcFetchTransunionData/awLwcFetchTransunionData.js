/**
 * @description Component used to fetch the Transunion Data
 *
 * @author vishakha.saini@accenture.com @story 168885
 *
 * @date March 2022
 */
import {api, LightningElement, wire} from 'lwc';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import userId from '@salesforce/user/Id';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {getRecordNotifyChange} from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import {CloseActionScreenEvent} from 'lightning/actions';
import getConsentData from '@salesforce/apex/AW_CTRL_FetchTransunionData.getConsentData';
import removeConsentData from '@salesforce/apex/AW_CTRL_FetchTransunionData.removeConsentData';
import getLeadRecord from '@salesforce/apex/AW_CTRL_FetchTransunionData.getLeadRecord';

//import fields
import CREDIT_BUREAU_CONSENT_FIELD from '@salesforce/schema/Lead.AW_CreditBureauConsent__c';
import CREDIT_BUREAU_REQUEST_MESSAGE_FIELD from '@salesforce/schema/Lead.AW_CreditBureauRequestStatusMessage__c';
import CREDIT_BUREAU_CALL_STATUS_FIELD from '@salesforce/schema/Lead.AW_CreditBureauCallStatus__c';
import CREDIT_BUREAU_LAST_CALL_DATETIME_FIELD from '@salesforce/schema/Lead.AW_CreditBureauLastCallDateTime__c';
import IDENTIFICATION_TYPE_FIELD from '@salesforce/schema/Lead.AW_IdentificationType__c';
import IDENTIFICATION_NUMBER_FIELD from '@salesforce/schema/Lead.AW_IdentificationNumber__c';
import DATE_OF_BIRTH_FIELD from '@salesforce/schema/Lead.AW_DateOfBirth__c';
import FIRST_NAME_FIELD from '@salesforce/schema/Lead.FirstName';
import LAST_NAME_FIELD from '@salesforce/schema/Lead.LastName';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const FIELDS = [CREDIT_BUREAU_CONSENT_FIELD, CREDIT_BUREAU_REQUEST_MESSAGE_FIELD, CREDIT_BUREAU_CALL_STATUS_FIELD,
				CREDIT_BUREAU_LAST_CALL_DATETIME_FIELD, IDENTIFICATION_TYPE_FIELD, IDENTIFICATION_NUMBER_FIELD, DATE_OF_BIRTH_FIELD, LAST_NAME_FIELD, FIRST_NAME_FIELD];

export default class AwLwcFetchTransunionData extends LightningElement
{
	@api recordId;
	isSpinner = false;
	creditBureauConsent;
	creditBureauRequestMessage;
	creditBureauCallStatus;
	creditBureauLastCallDatetime;
	identificationType;
	identificationNumber;
	dateOfBirth;
	lastName;
	firstName;
	creditCheck;
	currentUserProfile;
	foundLead;
	profileName = 'Liberty Lead Manager';
	showModal = false;

	/**
	 * wired method to get the user record data
	 **/
	@wire(getRecord, {recordId: userId, fields: [PROFILE_NAME_FIELD]})
	userData({data})
	{
		if(data)
		{
			this.currentUserProfile = data.fields.Profile.value.fields.Name.value;
		}
	};

	/**
	 * wired method to get the record
	 **/
	@wire(getRecord, {recordId: '$recordId', fields: FIELDS})
	getRecord(result)
	{
		if(this.currentUserProfile && this.currentUserProfile === this.profileName)
		{
			this.creditBureauConsent = getFieldValue(result.data, CREDIT_BUREAU_CONSENT_FIELD);
			this.creditBureauRequestMessage = getFieldValue(result.data, CREDIT_BUREAU_REQUEST_MESSAGE_FIELD);
			getFieldValue(result.data, CREDIT_BUREAU_CALL_STATUS_FIELD) ?
			this.creditBureauCallStatus = getFieldValue(result.data, CREDIT_BUREAU_CALL_STATUS_FIELD) : this.creditBureauCallStatus = 'None';
			this.identificationType = getFieldValue(result.data, IDENTIFICATION_TYPE_FIELD);
			this.identificationNumber = getFieldValue(result.data, IDENTIFICATION_NUMBER_FIELD);
			this.creditBureauLastCallDatetime = getFieldValue(result.data, CREDIT_BUREAU_LAST_CALL_DATETIME_FIELD);
			this.dateOfBirth = getFieldValue(result.data, DATE_OF_BIRTH_FIELD);
			this.firstName = getFieldValue(result.data, FIRST_NAME_FIELD);
			this.lastName = getFieldValue(result.data, LAST_NAME_FIELD);
			this.getLeadRecord();
			this.showModal = true;
		}
		else if(this.currentUserProfile && this.currentUserProfile !== this.profileName)
		{
			this.showToast('Error', 'The function is not available for your user account.', 'error');
			this.handleClose();
		}
	}

	/**
	 * used to store the consent check
	 **/
	handleConsent(event)
	{
		this.creditCheck = event.target.checked;
	}

	/**
	 * method to check if consent is provided or not and make the necessary apex calls
	 **/
	handleSubmit()
	{
		const passport = 'Passport';

		if(this.creditCheck === false)
		{
			this.removeConsentData();
		}
		else if(this.creditCheck || this.creditBureauConsent)
		{
			if(!this.identificationType || !this.identificationNumber)
			{
				this.showToast('Error', 'Identification Type and Identification Number are required', 'error');
			}
			else if(this.identificationType === passport && (!this.firstName || !this.lastName || !this.dateOfBirth))
			{
				this.showToast('Error', 'First Name, Last Name and Date of Birth are required', 'error');
			}
			else
			{
				this.getConsentData();
			}
		}
		else
		{
			this.showToast('Error', 'Please check the consent before proceeding.', 'error');
		}
	}

	/**
	 * method to call the apex method to make an API call
	 **/
	getConsentData()
	{
		this.isSpinner = true;
		getConsentData({leadRecord: this.foundLead}).then((result) =>
		{
			this.isSpinner = false;
			result.callSuccessful ? this.showToast('Success', result.responseMessage, 'success')
								  : this.showToast('Error', result.responseMessage, 'error');
			this.refreshRecord();
		}).catch(error =>
		{
			this.isSpinner = false;
			this.showToast('Error', error.body.message, 'error');
		});
	}

	/**
	 * method to call the apex method to remove consent data
	 **/
	removeConsentData()
	{
		this.isSpinner = true;
		removeConsentData({leadRecord: this.foundLead}).then(() =>
		{
			this.isSpinner = false;
			this.showToast('Success', 'Consent Data removed successfully', 'success');
			this.refreshRecord();
		}).catch(error =>
		{
			this.isSpinner = false;
			this.showToast('Error', error.body.message, 'error');
		});
	}

	/**
	 * method to call the apex method to retrieve the lead record
	 **/
	getLeadRecord()
	{
		getLeadRecord({leadId: this.recordId}).then((result) =>
		{
			this.foundLead = result;
		}).catch(error =>
		{
			this.showToast('Error', error.body.message, 'error');
		});
	}

	/**
	 * method to refresh the record
	 **/
	refreshRecord()
	{
		getRecordNotifyChange([{recordId: this.recordId}]);
		refreshApex(this.recordId);
	}

	/**
	 * method to close the modal
	 **/
	handleClose()
	{
		this.dispatchEvent(new CloseActionScreenEvent());
	}

	/**
	 * used to show toast message based on different success or fail scenarios
	 */
	showToast(title, message, variant)
	{
		const evt = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(evt);
	}
}