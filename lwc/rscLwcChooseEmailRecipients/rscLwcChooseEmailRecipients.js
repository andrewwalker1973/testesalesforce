import MC_Footer from '@salesforce/messageChannel/CMN_MC_Footer__c';
import MC_OptionSelected from '@salesforce/messageChannel/CMN_MC_OptionSelected__c';
import BUSINESS_ACCOUNT_EMAIL from '@salesforce/schema/Account.AW_Email__c';
import BUSINESS_ACCOUNT_MOBILE from '@salesforce/schema/Account.AW_Mobile__c';
import IS_PERSON_ACCOUNT from '@salesforce/schema/Account.IsPersonAccount';
import PERSON_ACCOUNT_LAST_NAME from '@salesforce/schema/Account.LastName';
import ACCOUNT_EMAIL from '@salesforce/schema/Account.PersonEmail';
import PERSON_ACCOUNT_PHONE from '@salesforce/schema/Account.PersonMobilePhone';
import PERSON_ACCOUNT_SALUTATION from '@salesforce/schema/Account.Salutation';
import CONTACT_LAST_NAME from '@salesforce/schema/Contact.LastName';
import CONTACT_TITLE from '@salesforce/schema/Contact.Title';
import {publishMessage, subscribeToMessageChannel} from 'c/cmnLightningMessageService';
import {MessageContext} from 'lightning/messageService';
import {api, LightningElement, wire} from 'lwc';

const NO_NAME_PROVIDED = 'No Name Provided';
const NO_EMAIL_PROVIDED = 'No Email Provided';
const PERSON_ACCOUNT_INITIALS = 'CMN_Initials__pc';
const ERROR_MESSAGE = 'Please indicate the recipient(s) of the email';
const ERROR_HEADER = 'Recipient(s) not selected';
const ERROR_VARIANT = 'error';
const HEADER = 'Please indicate the recipient(s) of the email';

const CLIENT_TYPE = 'Client';
const FINANCIAL_ADVISER_TYPE = 'Financial Adviser';
const OTHER_TYPE = 'Other';

const NAME = 'Name';
const PHONE = 'Phone';
const EMAIL = 'Email';

/**
 * @description Choose the intended recipient(s) for any Comms email. Can be Client/Financial Adviser/Third Party (Requester).
 * @author darrion.james.singh@accenture.com
 * @date July 2022
 */
export default class RscLwcChooseEmailRecipients extends LightningElement
{
	header = HEADER;
	@wire(MessageContext) messageContext;
	@api includeName = false;
	@api client;
	@api financialAdvisor;
	@api thirdParty;
	disableClient = false;
	disableFinancialAdvisor = false;
	disableThirdParty = false;

	selectedRecipients = [];
	isClientSelected;
	isFinancialAdvisorSelected;
	isThirdPartySelected;

	emailAddress;
	fullName;
	cellphoneNumber;
	recipientType = '';
	emailType = 'To';
	recipientTitle;
	recipientInitials;
	recipientSurname;

	/**
	 * @description Returns selected recipients
	 * @returns {*[]}
	 */
	@api get recipients()
	{
		return this.selectedRecipients;
	}

	/**
	 * @description Sets recipients array
	 * @param value
	 */
	set recipients(value)
	{
		this.selectedRecipients = [...value];
	}

	/**
	 * @description Returns if client is selected
	 * @returns {boolean}
	 */
	@api get clientSelected()
	{
		return this.isClientSelected;
	}

	/**
	 * @description Returns if financial adviser is selected
	 * @returns {boolean}
	 */
	@api get financialAdvisorSelected()
	{
		return this.isFinancialAdvisorSelected;
	}

	/**
	 * @description Returns if third party is selected
	 * @returns {boolean}
	 */
	@api get thirdPartySelected()
	{
		return this.isThirdPartySelected;
	}

	/**
	 * @description Returns client name
	 * @returns {string}
	 */
	get clientName()
	{
		return this.getField(this.client, NAME);
	}

	/**
	 * @description Returns client email
	 * @returns {string}
	 */
	get clientEmail()
	{
		return this.getAccountEmail(this.client);
	}

	/**
	 * @description Returns client to be displayed
	 * @returns {{name: (string), email: (string)}}
	 */
	get clientDisplay()
	{
		return {
			name: this.clientName || NO_NAME_PROVIDED, email: this.clientEmail || NO_EMAIL_PROVIDED
		};
	}

	/**
	 * @description Returns financial adviser name
	 * @returns {string}
	 */
	get financialName()
	{
		return this.getField(this.financialAdvisor, NAME);
	}

	/**
	 * @description Returns financial adviser email
	 * @returns {string}
	 */
	get financialEmail()
	{
		return this.getField(this.financialAdvisor, EMAIL);
	}

	/**
	 * @description Returns client to be displayed
	 * @returns {{name: (string|string), email: (string|string)}}
	 */
	get financialDisplay()
	{
		return {
			name: this.financialName || NO_NAME_PROVIDED, email: this.financialEmail || NO_EMAIL_PROVIDED
		};
	}

	/**
	 * @description Returns third party name
	 * @returns {string}
	 */
	get thirdPartyName()
	{
		return this.getField(this.thirdParty, NAME);
	}

	/**
	 * @description Returns third party email
	 * @returns {string}
	 */
	get thirdPartyEmail()
	{
		return this.getField(this.thirdParty, EMAIL);
	}

	/**
	 * @description Returns third party to be displayed
	 * @returns {{name: (string|string), email: (string|string)}}
	 */
	get thirdPartyDisplay()
	{
		return {
			name: this.thirdPartyName || NO_NAME_PROVIDED, email: this.thirdPartyEmail || NO_EMAIL_PROVIDED
		};
	}

	/**
	 * @description Creates recipient
	 */
	get createRecipient()
	{
		let recipientNoName = {
			emailAddress: this.emailAddress,
			emailType: this.emailType,
			cellphoneNumber: this.cellphoneNumber,
			recipientType: this.recipientType,
			recipientTitle: this.recipientTitle,
			recipientInitials: this.recipientInitials,
			recipientSurname: this.recipientSurname
		};

		return this.includeName ? {...recipientNoName, fullName: this.fullName} : recipientNoName;
	}

	/**
	 * @description Shows toast to indicate no recipients has been selected
	 */
	@api showNoRecipientsError()
	{
		//noinspection JSUnresolvedFunction
		this.template.querySelector('c-cmn-lwc-toast').customNotification(ERROR_HEADER, ERROR_MESSAGE, ERROR_VARIANT);
	}

	/**
	 * @description Sets that client has been selected
	 * @param event
	 */
	setClientSelected(event)
	{
		this.isClientSelected = event.target.checked;
		this.setRecipients();
	}

	/**
	 * @description Sets that financial adviser has been selected
	 * @param event
	 */
	setFinancialAdvisorSelected(event)
	{
		this.isFinancialAdvisorSelected = event.target.checked;
		this.setRecipients();
	}

	/**
	 * @description Sets that third party has been selected
	 * @param event
	 */
	setThirdPartySelected(event)
	{
		this.isThirdPartySelected = event.target.checked;
		this.setRecipients();
	}

	/**
	 * @description Returns the email address for a passed in account
	 * @param account
	 * @returns {*|string}
	 */
	getAccountEmail(account)
	{
		return this.getField(account, IS_PERSON_ACCOUNT.fieldApiName) ? this.getField(account, ACCOUNT_EMAIL.fieldApiName) : this.getField(account,
				BUSINESS_ACCOUNT_EMAIL.fieldApiName);
	}

	/**
	 * @description Returns the phone number for a passed in account
	 * @param account
	 * @returns {*|string|string}
	 */
	getAccountPhone(account)
	{
		return this.getField(account, IS_PERSON_ACCOUNT.fieldApiName) ? this.getField(account, PERSON_ACCOUNT_PHONE.fieldApiName) || this.getField(account,
				PHONE) : this.getField(account, BUSINESS_ACCOUNT_MOBILE.fieldApiName) || this.getField(account, PHONE);
	}

	/**
	 * @description returns an attribute of an object or an empty string if the attribute isn't found
	 * @param object
	 * @param attribute
	 * @returns {string}
	 */
	getField(object, attribute)
	{
		return object ? object[attribute] || '' : '';
	}

	connectedCallback()
	{
		this.disableClient = !(this.clientName && this.clientEmail);
		this.disableFinancialAdvisor = !(this.financialName && this.financialEmail);
		this.disableThirdParty = !(this.thirdPartyName && this.thirdPartyEmail);

		this.recipients.forEach(rec =>
		{
			if(rec.emailAddress)
			{
				if(this.clientEmail === rec.emailAddress)
				{
					this.isClientSelected = true;
				}

				if(this.financialEmail === rec.emailAddress)
				{
					this.isFinancialAdvisorSelected = true;
				}

				if(this.thirdPartyEmail === rec.emailAddress)
				{
					this.isThirdPartySelected = true;
				}
			}
		});

		subscribeToMessageChannel(this.messageContext, MC_Footer, message =>
		{
			if('noRecipientSelected' in message && !!message.noRecipientSelected)
			{
				this.showNoRecipientsError();
			}
		});
	}

	/**
	 * @description Populates the recipients that have been selected for output
	 */
	setRecipients()
	{
		this.selectedRecipients = [];
		if(this.clientSelected)
		{
			this.populateClientDetails();
			this.selectedRecipients.push(this.createRecipient);
		}

		if(this.financialAdvisorSelected)
		{
			this.populateFinancialAdvisor();
			this.selectedRecipients.push(this.createRecipient);
		}

		if(this.thirdPartySelected)
		{
			this.populateThirdParty();
			this.selectedRecipients.push(this.createRecipient);
		}

		let noRecipients = this.recipients.length === 0;
		publishMessage(this.messageContext, MC_OptionSelected, {noRecipientSelected: noRecipients});
		if(noRecipients)
		{
			this.dispatchEvent(new CustomEvent('no_recipient_selected'));
		}
		else
		{
			this.dispatchEvent(new CustomEvent('recipients_set', {detail: {recipients: this.recipients}}));
		}
	}

	/**
	 * @description Sets state of component to save client details
	 */
	populateClientDetails()
	{
		if(this.client[IS_PERSON_ACCOUNT.fieldApiName])
		{
			this.recipientTitle = this.client[PERSON_ACCOUNT_SALUTATION.fieldApiName];
			this.recipientSurname = this.client[PERSON_ACCOUNT_LAST_NAME.fieldApiName];
			this.recipientInitials = this.client[PERSON_ACCOUNT_INITIALS];
		}
		else
		{
			this.recipientSurname = this.getField(this.client, NAME);
		}

		this.emailAddress = this.clientEmail;
		this.fullName = this.clientName;
		this.cellphoneNumber = this.getAccountPhone(this.client);
		this.recipientType = CLIENT_TYPE;
	}

	/**
	 * @description Sets state of component to save financial adviser details
	 */
	populateFinancialAdvisor()
	{
		this.recipientTitle = this.financialAdvisor[CONTACT_TITLE.fieldApiName];
		this.recipientInitials = this.getInitials(this.getField(this.financialAdvisor, NAME));
		this.recipientSurname = this.financialAdvisor[CONTACT_LAST_NAME.fieldApiName];

		this.emailAddress = this.financialEmail;
		this.fullName = this.financialName;
		this.cellphoneNumber = this.getField(this.financialAdvisor, PHONE);
		this.recipientType = FINANCIAL_ADVISER_TYPE;
	}

	/**
	 * @description Sets state of component to save third party details
	 */
	populateThirdParty()
	{
		this.recipientInitials = this.getInitials(this.getField(this.thirdParty, NAME));
		this.recipientSurname = this.getField(this.thirdParty, NAME);

		this.emailAddress = this.thirdPartyEmail;
		this.fullName = this.thirdPartyName;
		this.cellphoneNumber = this.getField(this.thirdParty, PHONE);
		this.recipientType = OTHER_TYPE;
	}

	/**
	 * @description Returns initials from name
	 * @param string
	 * @returns {string}
	 */
	getInitials(string)
	{
		let initials = '';
		let name = string.split(' ');

		if(name.length > 0)
		{
			initials += name[0].substring(0, 1).toUpperCase();
		}

		if(name.length > 2)
		{
			initials += name[1].substring(0, 1).toUpperCase();
		}
		return initials;
	}
}