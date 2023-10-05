import FINANCIAL_ACCOUNT_NUMBER from '@salesforce/schema/FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c';
import INSURANCE_POLICY_NUMBER from '@salesforce/schema/InsurancePolicy.Name';
import {formatTemplateString} from 'c/cmnLwcUtil';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecords} from 'lightning/uiRecordApi';
import {api, LightningElement, wire} from 'lwc';

const yearField = 'year';
const policyNumberField = 'policyNumber';
const certificateTypeField = 'certificateType';
const DELIVERY_MEDIUM_EMAIL = 'Email';

const SELECT_TAX_CERTIFICATES_ERROR = 'Please select contracts for tax certificate(s)';

const SELECT_RECIPIENTS_ERROR = 'Please indicate the recipient(s) of the email.';
const NO_CERTS_AVAILABLE_ERROR = 'No tax certificates are available for policies linked to this case.';
const FETCHING_AC_ERROR = 'Error fetching associated contracts.';

const ERROR_TEMPLATE = '{} - {}: {}';

/**
 * @description Tax table to select contract certificates / recipients.
 * @story 147578
 * @author darrion.james.singh@accenture.com
 * @date May 2022
 */
export default class RscLwcChooseTaxCertificatesTable extends LightningElement
{
	/**
	 * @description Account SObject representing the client.
	 */
	@api client;
	/**
	 * @description Contact SObject representing the financial adviser.
	 */
	@api financialAdvisor;
	/**
	 * @description User SObject representing the third party
	 */
	@api thirdParty;
	/**
	 * @description Payload from the Get Tax API
	 * @type {string}
	 */
	@api payload = '';
	/**
	 * @description Number of table results to display
	 * @type {number}
	 */
	@api resultsPerPage = 10;
	/**
	 * @description Associated contracts
	 */
	@api associatedContracts = [];

	isReadOnly = false;
	/**
	 * @description Parsed payload object
	 * @type {{rows: [], columns: [], error}}
	 */
	parsedPayload;
	sortDirection = 'asc';
	sortedBy = 'Name';
	yearFilter = '';
	selectedTaxCerts = [];
	recipientList = [];
	associatedContractNumbers = [];

	/**
	 * @description Request payload that is generated to be sent to the Send Tax API
	 * @returns {string}
	 */
	@api get requestPayload()
	{
		let recipients = this.recipients.map(recipient => ({
			emailAddress: recipient.emailAddress, fullName: recipient.fullName
		}));

		let requests = this.selectedTaxCertificates.map(val => ({
			contractNumber: val[policyNumberField],
			year: val[yearField],
			documentType: val[certificateTypeField],
			recipients: recipients,
			encryptDocument: true,
			deliveryMedium: DELIVERY_MEDIUM_EMAIL
		}));

		return JSON.stringify(requests);
	}

	/**
	 * @description Returns a list of the currently selected recipients
	 * @returns {*[]}
	 */
	@api get recipients()
	{
		return this.recipientList;
	}

	set tableRowsSelected(value)
	{
		let table = this.template.querySelector('c-cmn-lwc-paginated-table');
		if(table)
		{
			table.selectedTableRows = value || [];
		}
	}

	/**
	 * @description Returns a list of the currently selected tax certificates
	 * @returns {*[]}
	 */
	@api get selectedTaxCertificates()
	{
		return this.selectedTaxCerts;
	}

	get selectedTaxCertificateIds()
	{
		return this.selectedTaxCertificates.map(val => val.Id);
	}

	get hasSelectedPolicies()
	{
		return this.selectedTaxCertificates.length > 0;
	}

	get taxTableData()
	{
		let taxTableData = this.parsedPayload ? this.parsedPayload.rows || [] : [];
		//noinspection JSUnresolvedVariable
		taxTableData = taxTableData.filter(cert => this.associatedContractNumbers.includes(cert.policyNumber))
		.filter(cert => !this.yearFilter || (cert.year === this.yearFilter))
		.map(cert => ({...cert, Id: `${cert.policyNumber}-${cert.certificateType}-${cert.year}`}));

		if(this.parsedPayload && this.parsedPayload.rows && this.associatedContractNumbers.length && !taxTableData.length)
		{
			this.showComponentError(NO_CERTS_AVAILABLE_ERROR);
		}
		return taxTableData;
	}

	get taxTableColumns()
	{
		return this.parsedPayload ? this.parsedPayload.columns || [] : [];
	}

	get taxYears()
	{
		let taxYears;
		if(this.taxTableData.length > 0)
		{
			let years = this.parsedPayload ? this.parsedPayload.rows.map(({year}) => year) || [] : [];
			let uniqueYears = new Set(years);
			let options = [...uniqueYears].map(val => ({label: val, value: val}));
			options.unshift({label: 'All', value: ''});
			taxYears = options;
		}
		else
		{
			taxYears = [];
		}
		return taxYears;
	}

	set tableErrorMessage(value)
	{
		if(value.toString().trim())
		{
			//noinspection JSUnresolvedFunction
			this.template.querySelector('c-cmn-lwc-paginated-table').showError(value);
		}
	}

	get hasRecipients()
	{
		return this.recipients.length > 0;
	}

	get fetchContractsParams()
	{
		let insurancePolicies = this.associatedContracts.map(contract => contract.SC_InsurancePolicy__c)
		.filter(contractId => !!contractId);

		let financialAccounts = this.associatedContracts.map(contract => contract.SC_FinancialAccount__c)
		.filter(contractId => !!contractId);
		return [
			{
				recordIds: insurancePolicies, fields: [INSURANCE_POLICY_NUMBER]
			},
			{
				recordIds: financialAccounts, fields: [FINANCIAL_ACCOUNT_NUMBER]
			}
		];
	}

	@wire(getRecords, {records: '$fetchContractsParams'}) fetchPolicies({error, data})
	{
		if(error)
		{
			this.showComponentError(FETCHING_AC_ERROR);
			console.error(error);
		}
		else if(data)
		{
			//noinspection JSUnresolvedVariable
			this.associatedContractNumbers = data.results.map(({result}) =>
			{
				let financialAccountNumber = result.fields.FinServ__FinancialAccountNumber__c;
				let insurancePolicyNumber = result.fields.Name;

				return ((financialAccountNumber && financialAccountNumber.value) || (insurancePolicyNumber && insurancePolicyNumber.value));
			})
			.filter(contractNumber => !!contractNumber);
		}
	}

	connectedCallback()
	{
		this.parsedPayload = JSON.parse(this.payload);

		if(this.parsedPayload.error)
		{
			let error = this.parsedPayload.error;
			//noinspection JSUnresolvedVariable
			let message = formatTemplateString(ERROR_TEMPLATE, [
				error.errorCode,
				error.errorMessage,
				error.errorDescription
			]);
			this.showComponentError(message);
			console.error(this.parsedPayload);
		}
	}

	/**
	 * @description Shows a custom error
	 * @param value
	 */
	showComponentError(value)
	{
		let val = value.trim();
		if(val)
		{
			//noinspection JSCheckFunctionSignatures
			this.dispatchEvent(new ShowToastEvent({
				title: val, message: '', variant: 'error', mode: 'sticky'
			}));
		}
	}

	renderedCallback()
	{
		this.tableRowsSelected = this.selectedTaxCertificateIds;
	}

	/**
	 * @description Filters selected certificates by the currently selected year
	 */
	filterCertificatesByYear()
	{
		this.selectedTaxCerts = this.selectedTaxCerts.filter(({year}) => year !== this.yearFilter);
	}

	/**
	 * @description Save rows that selected
	 * @param rows Rows that are selected. Property of the detail object in the event
	 */
	saveSelectedRows({detail: {rows}})
	{
		if(this.yearFilter)
		{
			this.filterCertificatesByYear();
		}
		else
		{
			this.selectedTaxCerts = [];
		}

		rows.forEach(row =>
		{
			this.selectedTaxCerts.push(this.taxTableData.find(val => val.Id === row));
		});
		this.tableErrorMessage = this.selectedTaxCertificates.length > 0 ? '' : SELECT_TAX_CERTIFICATES_ERROR;
	}

	/**
	 * @description Handles year filter changing.
	 * @param value Year to filter on. Property of the detail object of the event
	 */
	handleYearChange({detail: {value}})
	{
		this.yearFilter = value;
		this.template.querySelector('c-cmn-lwc-paginated-table').selectedTableRows = this.selectedTaxCerts.map(val => val.Id);
	}

	/**
	 * @description Shows table confirmation screen
	 */
	changeToConfirmationScreen()
	{
		this.isReadOnly = true;
	}

	/**
	 * @description Shows the table selection screen
	 */
	changeToChooseScreen()
	{
		this.isReadOnly = false;
	}

	/**
	 * @description Shows an error when no policy has been selected
	 */
	handleNoPolicySelected()
	{
		this.tableErrorMessage = SELECT_TAX_CERTIFICATES_ERROR;
	}

	handleNoRecipientSelected()
	{
		this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', SELECT_RECIPIENTS_ERROR, 'error');
	}

	/**
	 * @description Clears recipient array when no recipient is selected
	 */
	noRecipientSelected()
	{
		this.recipientList = [];
	}

	/**
	 * @description Saves selected recipients
	 * @param recipients List of recipients. Property of the detail object of the event.
	 */
	setRecipients({detail: {recipients}})
	{
		this.recipientList = recipients;
	}
}