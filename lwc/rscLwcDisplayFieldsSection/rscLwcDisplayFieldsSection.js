/**
 * @description Lightning web component is used to display the fields from the fieldSet
 * This Web component is created to be used in the lightning flow to clone cases.
 *
 * @author aakriti.a.goyal@accenture.com, rudzani.ndou@liberty.co.za
 *
 * @date October 2022, April 2023
 */

/*jshint esversion: 6 */
import cloneRecord from '@salesforce/apex/RSC_CTRL_CloneCaseWithFieldSet.cloneRecord';
import createCase from '@salesforce/apex/RSC_CTRL_CloneCaseWithFieldSet.createCase';
import getDocuments from '@salesforce/apex/RSC_CTRL_CloneCaseWithFieldSet.getDocuments';
import getFieldSetMember from '@salesforce/apex/RSC_CTRL_CloneCaseWithFieldSet.getFieldSetMember';
import getAssignableCaseQueueId from '@salesforce/apex/RSC_CTRL_CloneCaseWithFieldSet.getAssignableCaseQueueId';
import getServiceTypeData from '@salesforce/apex/RSC_CTRL_CloneCaseWithFieldSet.getServiceTypeRecord';
import getFieldSetMemberWithObject from '@salesforce/apex/RSC_CTRL_CloneCaseWithFieldSet.getAdditionalSectionFieldSet';
import TIME_ZONE from '@salesforce/i18n/timeZone';

import AdditionalComments from '@salesforce/label/c.RSC_AdditionalComments';
import CaseOriginMandatory from '@salesforce/label/c.RSC_CaseOriginMandatory';
import DepartmentAndServiceTypeMandatory from '@salesforce/label/c.RSC_DepartmentServiceTypeMandatory';
import InternalCaseComments from '@salesforce/label/c.RSC_InternalCaseComments';
import RequesterEmailMandatory from '@salesforce/label/c.RSC_RequesterEmailMandatory';
import RequesterFieldsMandatory from '@salesforce/label/c.RSC_RequesterFieldsMandatory';
import RequesterTypeMandatory from '@salesforce/label/c.RSC_RequesterTypeMandatory';
import ValidRequesterEmail from '@salesforce/label/c.RSC_ValidRequesterEmail';
import ValidRequesterMobile from '@salesforce/label/c.RSC_ValidRequesterMobile';
import ValidRequesterPhone from '@salesforce/label/c.RSC_ValidRequesterPhone';
import CLIENT_NAME_FIELD from '@salesforce/schema/Case.Account.Name';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';

import CLIENT_FIELD from '@salesforce/schema/Case.AccountId';
import INTERNAL_COMMENTS_CASE_FIELD from '@salesforce/schema/Case.Comments';
import CASE_ORIGIN from '@salesforce/schema/Case.Origin';
import CASE_SUBJECT from '@salesforce/schema/Case.Subject';
import PARENT_ID_FIELD from '@salesforce/schema/Case.ParentId';
import CASE_PRIORITY from '@salesforce/schema/Case.Priority';
import CASE_DEPARTMENT from '@salesforce/schema/Case.RSC_Department__c';
import DEPARTMENT_FIELD from '@salesforce/schema/Case.RSC_Department__c';
import IS_RELATED_FIELD from '@salesforce/schema/Case.RSC_IsRelated__c';
import SERVICE_TYPE_FIELD from '@salesforce/schema/Case.RSC_ServiceType__c';
import ASSIGNED_TO from '@salesforce/schema/Case.SC_AssignedTo__c';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import REQUESTER_EMAIL_FIELD from '@salesforce/schema/Case.SC_RequesterEmail__c';
import REQUESTER_MOBILE_FIELD from '@salesforce/schema/Case.SC_RequesterMobile__c';
import REQUESTER_PHONE_FIELD from '@salesforce/schema/Case.SC_RequesterPhone__c';
import CASE_REQUESTER_TYPE from '@salesforce/schema/Case.SC_RequesterType__c';
import REQUESTER_TYPE_FIELD from '@salesforce/schema/Case.SC_RequesterType__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';

import DOCUMENT_CHECK_LIST_ITEM_OBJECT from '@salesforce/schema/DocumentChecklistItem';
import DOCUMENT_CHECK_LIST_ITEM_DATE_VAULTED from '@salesforce/schema/DocumentChecklistItem.AW_DateVaulted__c';
import DOCUMENT_CHECK_LIST_ITEM_IS_VAULTED from '@salesforce/schema/DocumentChecklistItem.AW_Vaulted__c';
import DOCUMENT_CHECK_LIST_ITEM_VAULTED_ID from '@salesforce/schema/DocumentChecklistItem.CMN_VaultedId__c';
import DOCUMENT_CHECK_LIST_ITEM_FIELD_TYPE_ID from '@salesforce/schema/DocumentChecklistItem.DocumentTypeId';
import DOCUMENT_CHECK_LIST_ITEM_IS_REQUIRED from '@salesforce/schema/DocumentChecklistItem.IsRequired';
import DOCUMENT_CHECK_LIST_ITEM_FIELD_NAME from '@salesforce/schema/DocumentChecklistItem.Name';
import DOCUMENT_CHECK_LIST_ITEM_UPLOADED_WITH_CASE from '@salesforce/schema/DocumentChecklistItem.SC_UploadedWithCase__c';
import DOCUMENT_CHECK_LIST_ITEM_FIELD_STATUS from '@salesforce/schema/DocumentChecklistItem.Status';
import CASE_Extension_OBJECT from '@salesforce/schema/SC_CaseExtension__c';
import CASE_Associated_Contract_Ext_OBJECT from '@salesforce/schema/SC_AssociatedContractExtension__c';
import ClientDetails from '@salesforce/label/c.SC_ClientDetails';
import ClientFirstNameMandatory from '@salesforce/label/c.SC_ClientFirstNameMandatory';
import ClientIdNumberMandatory from '@salesforce/label/c.SC_ClientIdNumberMandatory';
import ClientLastNameMandatory from '@salesforce/label/c.SC_ClientLastNameMandatory';
import ClientMobileMandatory from '@salesforce/label/c.SC_ClientMobileMandatory';
import ConsultantCodeMandatory from '@salesforce/label/c.SC_ConsultantCodeMandatory';
import FinancialAdviserDetails from '@salesforce/label/c.SC_FinancialAdvisorDetails';
import NextActionOnCase from '@salesforce/label/c.SC_NextActionOnCaseCreationScreen';
import PolicyNumberMandatory from '@salesforce/label/c.SC_PolicyNumberMandatory';
import ValidClientMobile from '@salesforce/label/c.SC_ValidClientMobile';
import CONSULTANT_CODE from '@salesforce/schema/SC_AssociatedContractExtension__c.RSC_ConsultantCode__c';
import CLIENT_MOBILE from '@salesforce/schema/SC_CaseExtension__c.RSC_ClientCellNumber__c';
import CLIENT_FIRSTNAME from '@salesforce/schema/SC_CaseExtension__c.RSC_ClientFirstName__c';
import CLIENT_ID_NUMBER from '@salesforce/schema/SC_CaseExtension__c.RSC_ClientIdentificationNumber__c';
import CLIENT_SURNAME from '@salesforce/schema/SC_CaseExtension__c.RSC_ClientSurname__c';
import CLIENT_POLICY_NUMBER from '@salesforce/schema/SC_CaseExtension__c.RSC_MasterContractNumber__c';

import userId from '@salesforce/user/Id';
import {reduceErrors, sortBy} from 'c/cmnLwcUtil';
import {getFieldValue, getRecord} from 'lightning/uiRecordApi';
import {api, LightningElement, wire} from 'lwc';

const CLONE_SUCCESS_MESSAGE = 'Case has been cloned successfully';
const CREATE_SUCCESS_MESSAGE = 'Case created successfully';
export const FIRST_STEP = 'First';
export const SECOND_STEP = 'Second';
export const THIRD_STEP = 'Third';
export const FINAL_STEP = 'Final';
const CUSTOMER = 'Customer';
const BLANK = '';
const REQUESTER_FIELDS_FIELDSET = 'RSC_RequesterFields';
const CLONE_FIELDSET = 'RSC_Clone';
export const RENDER_FLOW = 'Fourth';

const POLICY_COLUMNS = [{label: 'Policy Number', fieldName: 'policyNumber', type: 'text'}, {
	label: 'Policy Type',
	fieldName: 'type',
	type: 'text'
}, {label: 'Product Type', fieldName: 'productType', type: 'text'}, {label: 'Commencement Date', fieldName: 'commencementDate', type: 'text'}, {
	label: 'Status',
	fieldName: 'status',
	type: 'text'
}, {label: 'Premium', fieldName: 'premium', type: 'decimal'}];

const DOCUMENT_COLUMNS = [{label: 'Document Name', sortable: true, fieldName: 'Name', type: 'text'}, {
	label: 'Document Status',
	sortable: true,
	fieldName: 'Status'
}, {label: 'Document Type', sortable: true, fieldName: 'MasterLabel'}, {
	label: 'Document Vaulted Time', fieldName: 'AW_DateVaulted__c', type: 'date', typeAttributes: {
		year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false, timeZone: TIME_ZONE
	}
}, {label: 'Vaulted?', fieldName: 'AW_Vaulted__c', type: 'boolean'}, {label: 'Required?', fieldName: 'IsRequired', type: 'boolean'}];
const PHONE_REGEX = /^((\+)?[1-9]{1,4})?([-\s.\/])?((\(\d{1,4}\))|\d{1,4})(([-\s.\/])?[0-9]{1,6}){2,6}(\s?(ext|x)\s?[0-9]{1,6})?$/;
//noinspection LongLine
const EMAIL_REGEX = /^[a-zA-Z0-9!.#$%&'*+\/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!.#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+([a-zA-Z]{2,8}|[0-9]{1,3})$/;

export default class RscLwcDisplayFieldsSection extends LightningElement
{
	// Public fields
	@api recordTypeId;

	@api isClone = false;
	@api recordId = null;
		/**
	 * @description Comma seperated list of field API names e.g. 'FirstName,LastName'
	 * @type {string}
	 */
	@api lookUpFields = 'Name';
	/**
	 * @description Format for lookup item display e.g. 'Mr. LastName'
	 * @type {string}
	 */
	@api lookUpDisplayFormat;
	@api objectApiName;
	@api invokedFromFlow = false;

	// Class fields - Data Layer
	firstScreenDataCapture;
	secondScreenSelectedPolicyIds;
	secondScreenSelectedPolicies = [];
	thirdScreenSelectedDocumentIds;
	thirdScreenSelectedDocuments;
	serviceTypeName = BLANK;
	requesterType = BLANK;
	currentlySelectedStep = FIRST_STEP;

	relatedToParentCheckBoxValue = false;
	assignToMeValue = false;
	selectedDepartment = BLANK;
	selectedServiceType = null;
	clientId = BLANK;
	previousDepartment;
	previousServiceType;
	isPreviousClicked = false;
	fieldSets;

	// UI Fields
	isLoading = false;
	policyTableColumns = POLICY_COLUMNS;
	documentColumns = DOCUMENT_COLUMNS;
	defaultSortDirection = 'asc';
	sortDirection = 'asc';
	sortedBy = 'Name';
	assignableCaseQueueId;
	clientFieldSetMembers = [];
	consultantFieldSetMembers = [];
	contractExtensionRecord;
	caseExtRecord;
	accountId;
	flowInputVariables = [];
	isClientDetails = false;
	isConsultantDetails = false;
	hasNextActionOnCase =false;
	activeSections = [
		'clientDetails',
		'comments',
		'FinancialAdviserDetails'
	];
	labels = {
		AdditionalComments,
		InternalCaseComments,
		RequesterTypeMandatory,
		RequesterFieldsMandatory,
		RequesterEmailMandatory,
		ValidRequesterPhone,
		ValidRequesterEmail,
		ValidRequesterMobile,
		DepartmentAndServiceTypeMandatory,
		CaseOriginMandatory,
		ClientDetails,
		FinancialAdviserDetails,
		ValidClientMobile,
		ClientFirstNameMandatory,
		ClientLastNameMandatory,
		ClientIdNumberMandatory,
		ClientMobileMandatory,
		ConsultantCodeMandatory,
		PolicyNumberMandatory,
		NextActionOnCase
	};

	// Wires
	@wire(getRecord, {recordId: '$recordId', fields: [CLIENT_NAME_FIELD]})
	case;
	@wire(getDocuments, {recordId: '$recordId'})
	documents;
	@wire(getRecord, {recordId: '$accountId', fields: [ACCOUNT_NAME_FIELD]})
	accountRecord;
	/**
	 * @description function is used to get assignable queue Id if selected service type of case is assignable
	 */
	@wire(getAssignableCaseQueueId, {serviceTypeId: '$selectedServiceType'})
	fetchAssignableCaseQueue({error, data})
	{
		if(data)
		{
			this.assignableCaseQueueId = data;
		}
		else if(error){
			this.showErrorToast(error.body.message);
		}
	}
	@api displayRelatedToParentCheckbox = false;

	// Getters / Setters
	get isCloneMode()
	{
		return this.isClone;
	}

	get isReadOnly()
	{
		return this.invokedFromFlow;
	}

	@api get selectedStep()
	{
		return this.currentlySelectedStep;
	}

	set selectedStep(value)
	{
		this.currentlySelectedStep = value;
		this.dispatchStepChangeEvent(value);
	}

	get displayFields()
	{
		let fields = (this.isCustomerRequesterType || !this.requesterType) ? this.fields.filter(field => (field.fieldSetAPIName !== REQUESTER_FIELDS_FIELDSET)) : this.fields;
		if(this.firstScreenDataCapture)
		{
			fields = fields.map(field =>
			{
				let populatedField = {...field};
				populatedField.fieldValue = this.firstScreenDataCapture[field.fieldName];
				return populatedField;
			});
		}

		return fields;
	}

	get serviceTypeSelector()
	{
		return this.template.querySelector('c-rsc-lwc-choose-service-type');
	}

	get form()
	{
		return this.template.querySelector('c-cmn-lwc-create-form[data-my-id=in1]');
	}
	get clientForm(){
		return this.template.querySelector('c-cmn-lwc-create-form[data-my-id=in2]');
	}
	get financialAdviserForm(){
		return this.template.querySelector('c-cmn-lwc-create-form[data-my-id=in3]');
	}

	get comments()
	{
		return this.template.querySelector('[data-name=\'Comments\']');
	}
	/**
	 * @description function to set selected service type
	 */
	handleServiceTypeSelection(event)
	{
		this.selectedServiceType = event.detail;

		if(this.selectedServiceType && !this.isClone){
			this.getServiceTypeRecord(this.selectedServiceType);
		}else{
				this.dispatchEvent(new CustomEvent('service_type_change', {detail: {hasServiceType:false}}));
				this.hasNextActionOnCase=false;
				this.isClientDetails=false;
				this.isConsultantDetails = false;
		}


	}
	get populatedRecord()
	{
		//noinspection JSUnresolvedVariable
		this.selectedServiceType = this.serviceTypeSelector.selectedServiceType;
		//noinspection JSUnresolvedVariable
		this.serviceTypeName = this.serviceTypeSelector.selectedServiceTypeName;
		//noinspection JSUnresolvedVariable
		this.selectedDepartment = this.serviceTypeSelector.selectedDepartment;
		//noinspection JSUnresolvedVariable
		const comments = this.comments.value;
		//noinspection JSUnresolvedFunction
		const formRecord = this.form.createRecordForApex();
		let record = {...formRecord};
		record[CASE_PRIORITY.fieldApiName] = record[CASE_PRIORITY.fieldApiName] || 'Medium';
		record[SERVICE_TYPE_FIELD.fieldApiName] = this.selectedServiceType;
		record[DEPARTMENT_FIELD.fieldApiName] = this.selectedDepartment;
		record[INTERNAL_COMMENTS_CASE_FIELD.fieldApiName] = (comments || BLANK).trim();
		record[ASSIGNED_TO.fieldApiName] = this.assignToMeValue ? userId : undefined;
		record[OWNER_FIELD.fieldApiName] = this.assignToMeValue ? userId : this.assignableCaseQueueId;
		record[CASE_STATUS.fieldApiName] = this.assignToMeValue ? 'In Progress' : 'New';

		if(this.isCloneMode)
		{
			record[PARENT_ID_FIELD.fieldApiName] = this.recordId;
			record[IS_RELATED_FIELD.fieldApiName] = this.relatedToParentCheckBoxValue;
		}

		return record;
	}

	get showRelatedToParentCheckbox()
	{
		return this.isCloneMode && this.displayRelatedToParentCheckbox && (this.selectedStep === FIRST_STEP);
	}

	get showAssignedToMe()
	{
		return this.selectedStep === FIRST_STEP;
	}

	get showFirstScreen()
	{
		return this.selectedStep === FIRST_STEP;
	}

	get showSecondScreen()
	{
		return this.selectedStep === SECOND_STEP;
	}

	get showThirdScreen()
	{
		return this.selectedStep === THIRD_STEP;
	}

	get showFinalScreen()
	{
		return this.selectedStep === FINAL_STEP;
	}

	get isCustomerRequesterType()
	{
		return this.requesterType === CUSTOMER;
	}

	get showSelectedDocuments()
	{
		return this.thirdScreenSelectedDocuments.length > 0;
	}

	get showSelectedPolicies()
	{
		return this.secondScreenSelectedPolicies.length > 0;
	}

	get requesterFields()
	{
		return this.fields.filter(field => (field.fieldSetAPIName === REQUESTER_FIELDS_FIELDSET));
	}

	get selectedPolicies()
	{
		//noinspection JSUnresolvedFunction
		return this.contractsSection ? this.contractsSection.returnSelectedRowData() : [];
	}

	get selectedPolicyIds()
	{
		return this.selectedPolicies.map(rowData => rowData.id);
	}

	get selectedAccountName()
	{
		return this.accountRecord && this.accountRecord.data ? getFieldValue(this.accountRecord.data, ACCOUNT_NAME_FIELD) || BLANK : BLANK;
	}

	get contractsSection()
	{
		return this.template.querySelector('c-rsc-lwc-display-contracts-section');
	}
	get showMedicalRequirementScreen()
	{
		return this.selectedStep === RENDER_FLOW;
	}

	get displayDocuments()
	{
		const reverse = this.sortDirection === 'asc' ? 1 : -1;
		return this.documents && this.documents.data ? this.documents.data.map(document => ({
															   Id: document.Id,
															   Name: document[DOCUMENT_CHECK_LIST_ITEM_FIELD_NAME.fieldApiName],
															   Status: document[DOCUMENT_CHECK_LIST_ITEM_FIELD_STATUS.fieldApiName],
															   MasterLabel: (document['DocumentType'] || '') && (document['DocumentType']['MasterLabel'] || ''),
															   AW_DateVaulted__c: document[DOCUMENT_CHECK_LIST_ITEM_DATE_VAULTED.fieldApiName],
															   AW_Vaulted__c: document[DOCUMENT_CHECK_LIST_ITEM_IS_VAULTED.fieldApiName],
															   IsRequired: document[DOCUMENT_CHECK_LIST_ITEM_IS_REQUIRED.fieldApiName],
															   DocumentTypeId: document[DOCUMENT_CHECK_LIST_ITEM_FIELD_TYPE_ID.fieldApiName],
															   CMN_VaultedId__c: document[DOCUMENT_CHECK_LIST_ITEM_VAULTED_ID.fieldApiName]
														   }))
														   .sort(sortBy(this.sortedBy, reverse, null)) : [];
	}

	get preSelectedDocumentIds()
	{
		let preSelectedDocumentIds;
		if(this.thirdScreenSelectedDocumentIds)
		{
			preSelectedDocumentIds = this.thirdScreenSelectedDocumentIds;
		}
		else
		{
			preSelectedDocumentIds = this.documents && this.documents.data ? this.documents.data.filter(
																						 document => document[DOCUMENT_CHECK_LIST_ITEM_UPLOADED_WITH_CASE.fieldApiName])
																				 .map(document => document.Id) : [];
		}
		return preSelectedDocumentIds;
	}

	get selectedDocumentIds()
	{
		return this.selectedDocuments.map(document => document.Id);
	}

	get selectedDocuments()
	{
		//noinspection JSUnresolvedFunction
		return this.template.querySelector('[data-name=\'Documents\']').getSelectedRows();
	}

	get caseTableColumns()
	{
		let nonRequesterTypeHeadings = this.fields.filter(
				field => field.fieldSetAPIName === CLONE_FIELDSET && field.fieldName !== REQUESTER_EMAIL_FIELD.fieldApiName
						&& field.fieldName !== CASE_SUBJECT.fieldApiName)
										   .map(field => ({
											   label: field.fieldLabel, fieldName: field.fieldName
										   }));

		let nonFieldSetHeadings = [
			{label: 'Department', fieldName: DEPARTMENT_FIELD.fieldApiName},
			{label: 'Service Type', fieldName: SERVICE_TYPE_FIELD.fieldApiName},
			{label: 'Is Related?', fieldName: IS_RELATED_FIELD.fieldApiName}
		];
		return [
			...nonRequesterTypeHeadings,
			...nonFieldSetHeadings
		];
	}

	get displayConfirmationTableRow()
	{
		let record = {...this.firstScreenDataCapture};
		record[SERVICE_TYPE_FIELD.fieldApiName] = this.serviceTypeName;
		record[CLIENT_FIELD.fieldApiName] = this.selectedAccountName;
		record[IS_RELATED_FIELD.fieldApiName] = this.relatedToParentCheckBoxValue ? 'Yes' : 'No';
		return [record];
	}

	get requesterTableColumns()
	{
		return this.fields.filter(field => field.fieldSetAPIName === REQUESTER_FIELDS_FIELDSET || field.fieldName === REQUESTER_EMAIL_FIELD.fieldApiName)
				   .map(field => ({
					   label: field.fieldLabel, fieldName: field.fieldName
				   }));
	}

	get selectedDocumentChecklistItems()
	{
		return this.thirdScreenSelectedDocuments ? this.thirdScreenSelectedDocuments.map(document => ({
			sobjectType: DOCUMENT_CHECK_LIST_ITEM_OBJECT.objectApiName,
			Name: document[DOCUMENT_CHECK_LIST_ITEM_FIELD_NAME.fieldApiName],
			Status: document[DOCUMENT_CHECK_LIST_ITEM_FIELD_STATUS.fieldApiName],
			DocumentTypeId: document[DOCUMENT_CHECK_LIST_ITEM_FIELD_TYPE_ID.fieldApiName],
			CMN_VaultedId__c: document[DOCUMENT_CHECK_LIST_ITEM_VAULTED_ID.fieldApiName],
			AW_Vaulted__c: document[DOCUMENT_CHECK_LIST_ITEM_IS_VAULTED.fieldApiName],
			AW_DateVaulted__c: document[DOCUMENT_CHECK_LIST_ITEM_DATE_VAULTED.fieldApiName],
			SC_UploadedWithCase__c: document[DOCUMENT_CHECK_LIST_ITEM_UPLOADED_WITH_CASE.fieldApiName]
		})) : [];
	}

	get fields()
	{
		return this.fieldSets && this.fieldSets ? this.fieldSets.map(({
			fieldAPIName, fieldValue, isRequired, fieldLabel, fieldSetAPIName
		}) =>
		{
			const field = {
				fieldName: fieldAPIName, fieldValue: fieldValue, isRequired: isRequired, fieldLabel: fieldLabel, fieldSetAPIName: fieldSetAPIName
			};

			if([CASE_ORIGIN.fieldApiName, CASE_PRIORITY.fieldApiName, CASE_REQUESTER_TYPE.fieldApiName, CASE_DEPARTMENT.fieldApiName].some(
					fieldApiName => fieldAPIName === fieldApiName))
			{
				field['padPicklistValuesBeginning'] = [{label: '-- None --', value: '', isDefault: false}];
			}

			if(fieldAPIName === CASE_DEPARTMENT.fieldApiName)
			{
				field['fieldType'] = 'PICKLIST';
			}

			return field;
		}) : [];
	}

	// Lifecycle Hooks
	connectedCallback()
	{
		this.getFieldValues();
		this.selectedStep = FIRST_STEP;
		this.requesterType = this.fields.find(field => field.fieldName === REQUESTER_TYPE_FIELD.fieldApiName);
		this.relatedToParentCheckBoxValue = this.invokedFromFlow;
	}

	getFieldValues()
	{
		getFieldSetMember({caseId: this.recordId})
		.then((result) =>
		{
			this.fieldSets = result;
			this.isLoading = false;
		});
	}

	renderedCallback()
	{
		if(this.firstScreenDataCapture)
		{
			if(this.comments)
			{
				this.comments.value = this.firstScreenDataCapture[INTERNAL_COMMENTS_CASE_FIELD.fieldApiName];
			}
		}
	}

	clearNonCreateFormComponents()
	{
		this.assignToMeValue = false;
		this.comments && (this.comments.value = BLANK);
		this.serviceTypeSelector && (this.serviceTypeSelector.selectedDepartment = BLANK);
		this.selectedDepartment = BLANK;
		this.selectedServiceType = null;
	}

	errorCallback(error, stack)
	{
		console.error('Message: ', error.message, '\nName: ', error.name, '\nError Stack: ', error.stack, '\nStack: ', stack);
	}

	// Validation
	isInvalidPhoneNumber = (number) => !PHONE_REGEX.test(String(number));
	isInvalidEmail = (email) => !EMAIL_REGEX.test(String(email));

	@api validateFirstScreen()
	{
		let isValid = true;
		let record = this.populatedRecord;
		this.previousDepartment = this.selectedDepartment;
		this.previousServiceType = this.selectedServiceType;

		//noinspection OverlyComplexFunctionJS
		Object.entries(record)
			  .filter(([key]) => this.displayFields.some(field => field.fieldName === key))
			  .forEach(([key, value]) =>
			  {
				  if(value)
				  {
					  //to verify regex
					  if(key === REQUESTER_EMAIL_FIELD.fieldApiName && this.isInvalidEmail(value))
					  {
						  this.showErrorToast(this.labels.ValidRequesterEmail);
						  isValid = false;
					  }

					  if(!this.isCustomerRequesterType)
					  {
						  //to verify the Requester Mobile and Requester Phone fields
						  if(key === REQUESTER_MOBILE_FIELD.fieldApiName && this.isInvalidPhoneNumber(value))
						  {
							  this.showErrorToast(this.labels.ValidRequesterMobile);
							  isValid = false;
						  }
						  if(key === REQUESTER_PHONE_FIELD.fieldApiName && this.isInvalidPhoneNumber(value))
						  {
							  this.showErrorToast(this.labels.ValidRequesterPhone);
							  isValid = false;
						  }
					  }
				  }
				  else
				  {
					  if([CASE_ORIGIN.fieldApiName, REQUESTER_TYPE_FIELD.fieldApiName, REQUESTER_EMAIL_FIELD.fieldApiName]
					  .some(element => key === element))
					  {
						  switch(key)
						  {
							  case 'Origin':
								  this.showErrorToast(this.labels.CaseOriginMandatory);
								  break;
							  case 'SC_RequesterType__c':
								  this.showErrorToast(this.labels.RequesterTypeMandatory);
								  break;
							  case 'SC_RequesterEmail__c':
								  this.showErrorToast(this.labels.RequesterEmailMandatory);
								  break;
							  default:
								  break;
						  }
						  isValid = false;
					  }

					  if(!this.isCustomerRequesterType && this.requesterFields.map(field => field.fieldName)
															  .some(element => key === element))
					  {
						  this.showErrorToast(this.labels.RequesterFieldsMandatory);
						  isValid = false;
					  }
				  }
			  });

		Object.entries(record)
			  .filter(([key]) => [DEPARTMENT_FIELD.fieldApiName, SERVICE_TYPE_FIELD.fieldApiName].some(element => element === key))
			  .forEach(([, value]) =>
			  {
				  if(!value)
				  {
					  this.showErrorToast(this.labels.DepartmentAndServiceTypeMandatory);
					  isValid = false;
				  }
			  });
		if(this.isClientDetails  || this.isConsultantDetails){
			isValid = this.validateClientDetailsSection(isValid);
		}
		if(isValid && this.clientId)
		{
			this.selectedStep = SECOND_STEP;
		}
		else if(isValid && this.isCloneMode)
		{
			this.clearSecondScreen();
			this.selectedStep = THIRD_STEP;
		}
		// Assign values in input variable of flow
		else if(isValid && this.hasNextActionOnCase)
		{

			this.selectedStep = RENDER_FLOW;
			this.flowInputVariables = [
				{
					name: 'SC_CaseRecord', type: 'SObject', value: record
				},
				{
					name: 'SC_CaseExtension', type: 'SObject', value: this.caseExtRecord
				},
				{
					name: 'SC_AssociatedContractExtension', type: 'SObject', value: this.contractExtensionRecord
				}
			]

		}
		else
		{
			this.selectedStep = FIRST_STEP;
		}

		this.firstScreenDataCapture = record;
		this.accountId = this.firstScreenDataCapture.AccountId;
		return isValid;
	}

	clearSecondScreen()
	{
		this.secondScreenSelectedPolicyIds = undefined;
		this.secondScreenSelectedPolicies = [];
	}

	// Callout Methods
	@api cloneCase(isSaveAndNew)
	{
		this.isLoading = true;
		let record = {...this.firstScreenDataCapture, Id: this.recordId};
		return cloneRecord({
			existingCase: record,
			selectedPolicyIds: this.secondScreenSelectedPolicyIds || [],
			checklistItems: this.selectedDocumentChecklistItems,
			isRelatedToParentCase: this.relatedToParentCheckBoxValue
		})
		.then(caseId =>
		{
			this.isLoading = false;
			this.showSuccessToast(CLONE_SUCCESS_MESSAGE);
			if(isSaveAndNew)
			{
				this.resetComponent();
			}
			if(this.invokedFromFlow)
			{
				this.sendCloneSuccessful();
			}
			return caseId;
		})
		.catch(e =>
		{
			console.error(e);
			this.showErrorToast(e.body.message);
		});
	}

	@api sendCloneSuccessful()
	{
		return this.invokedFromFlow;
	}

	@api insertNewCase()
	{
		this.isLoading = true;
		let record = {...this.firstScreenDataCapture};
		delete record.Id;
		return createCase({newCase: record, selectedPolicyIds: this.selectedPolicyIds})
		.then(caseId =>
		{
			this.isLoading = false;
			this.showSuccessToast(CREATE_SUCCESS_MESSAGE);
			return caseId;
		})
		.catch(e =>
		{
			this.showErrorToast(e.body.message);
			throw e;
		});
	}

	@api resetComponent()
	{
		this.firstScreenDataCapture = undefined;
		this.clearSecondScreen();
		this.thirdScreenSelectedDocumentIds = undefined;
		this.thirdScreenSelectedDocuments = undefined;
		this.selectedStep = FIRST_STEP;
		//noinspection JSUnresolvedFunction
		this.form && this.form.clearForm();
		this.clearNonCreateFormComponents();
	}

	// Dispatchers
	//noinspection JSUnresolvedFunction
	showErrorToast = (errorMessage, header = 'Error') => this.template.querySelector('c-cmn-lwc-toast')
															 .customNotification(header, errorMessage, 'error');
	//noinspection JSUnresolvedFunction
	showSuccessToast = (successMessage, header = 'Success') => this.template.querySelector('c-cmn-lwc-toast')
																   .customNotification(header, successMessage, 'success');
	dispatchStepChangeEvent = (stepName) => this.dispatchEvent(new CustomEvent('stepchange', {detail: stepName}));

	//Handlers
	handleRelatedToParentChange = (event) => (this.relatedToParentCheckBoxValue = event.target.checked);
	handleAssignToMe = (event) => (this.assignToMeValue = event.target.checked);

	onFormValueChanged({detail})
	{
		if(detail)
		{
			this.requesterType = detail.fields[REQUESTER_TYPE_FIELD.fieldApiName];
			this.clientId = detail.fields[CLIENT_FIELD.fieldApiName];
		}

		this.dispatchEvent(new CustomEvent('client_id_change', {detail: {hasClientId: Boolean(this.clientId)}}));
	};

	handleOnDocTableSort(event)
	{
		const {fieldName: sortedBy, sortDirection} = event.detail;
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;
	}

	// Navigation
	@api handleNext()
	{
		switch(this.selectedStep)
		{
			case FIRST_STEP:
				this.validateFirstScreen();
				break;
			case SECOND_STEP:
				this.secondScreenSelectedPolicies = this.selectedPolicies;
				this.secondScreenSelectedPolicyIds = this.selectedPolicyIds;
				this.selectedStep = THIRD_STEP;
				break;
			case THIRD_STEP:
				this.thirdScreenSelectedDocuments = this.selectedDocuments;
				this.thirdScreenSelectedDocumentIds = this.selectedDocumentIds;
				this.selectedStep = FINAL_STEP;
				break;
			default:
				break;
		}
	}

	@api handlePrevious()
	{
		switch(this.selectedStep)
		{
			case SECOND_STEP:
				this.secondScreenSelectedPolicies = this.selectedPolicies;
				this.secondScreenSelectedPolicyIds = this.selectedPolicyIds;
				this.selectedDepartment = this.previousDepartment;
				this.selectedServiceType = this.previousServiceType;
				this.selectedStep = FIRST_STEP;
				this.isPreviousClicked = true;
				break;
			case THIRD_STEP:
				this.thirdScreenSelectedDocuments = this.selectedDocuments;
				this.thirdScreenSelectedDocumentIds = this.selectedDocumentIds;
				if(this.clientId)
				{
					this.selectedStep = SECOND_STEP;
				}
				else
				{
					this.clearSecondScreen();
					this.selectedStep = FIRST_STEP;
				}
				break;
			case FINAL_STEP:
				this.selectedStep = THIRD_STEP;
				break;
			default:
				break;
		}
	}
	/**
	 * @Description This Function use to get service type record with field set name and flow name.
	 * */
	getServiceTypeRecord(serviceTypeId){
		getServiceTypeData({serviceTypeId: serviceTypeId})
		.then(result =>
		{

				if(result.SC_CaseExtensionCreationFieldSet__c){
					this.getFieldsOfFieldSets(CASE_Extension_OBJECT.objectApiName,result.SC_CaseExtensionCreationFieldSet__c.split(','));
					this.isClientDetails = true;
				}else{
					this.isClientDetails = false;
				}
				if(result.SC_AssociatedContractExtCreationFieldSet__c){
					this.getFieldsOfFieldSets(CASE_Associated_Contract_Ext_OBJECT.objectApiName,result.SC_AssociatedContractExtCreationFieldSet__c.split(','));
					this.isConsultantDetails = true;
				}else{
					this.isConsultantDetails=false;
				}
				if(result.SC_NextActionOnCaseCreationScreen__c ===this.labels.NextActionOnCase && !this.isCloneMode){
					this.dispatchEvent(new CustomEvent('service_type_change', {detail: {hasServiceType:true}}));
					this.hasNextActionOnCase=true;
				}
				else{
					this.dispatchEvent(new CustomEvent('service_type_change', {detail: {hasServiceType:false}}));
					this.hasNextActionOnCase=false;
				}


		})
		.catch(error =>
		{
			this.showErrorToast(reduceErrors(error));
		});
	}
	//TO get fields for client details section.
	get displayClientFields()
	{
		return this.clientSectionFields;
	}

	//TO get fields for financial advisor section.
	get displayFinancialAdvisorFields()
	{
		return this.consultantSectionFields;
	}
	/**
	 * @Description This Function use to  call apex method and get field set data.
	 * */
	getFieldsOfFieldSets(objectName, fieldSetApiNamesList)
	{
		let mapOfFieldSetWithObject = {};
		mapOfFieldSetWithObject[objectName] = Object.values(fieldSetApiNamesList);
		getFieldSetMemberWithObject({mapOfObjectsFieldsSet: mapOfFieldSetWithObject})
		.then(result =>
		{
			if(objectName===CASE_Extension_OBJECT.objectApiName)
			{
				this.clientFieldSetMembers = result;
			}
			if(objectName===CASE_Associated_Contract_Ext_OBJECT.objectApiName)
			{
				this.consultantFieldSetMembers = result;
			}

		})
		.catch(error =>
		{
			this.showErrorToast(reduceErrors(error));
		});
	}
	/**
	 * @Description This Function use to store Case extension object's fieldset fields.
	 * */
	get clientSectionFields()
	{
		return this.clientFieldSetMembers ? this.clientFieldSetMembers.map(({fieldAPIName, fieldValue, isRequired, fieldLabel, fieldSetAPIName}) =>
		{
			return {
				fieldName: fieldAPIName, fieldValue: fieldValue, isRequired: isRequired, fieldLabel: fieldLabel, fieldSetAPIName: fieldSetAPIName
			};
		}) : [];
	}
	/**
	 * @Description This Function use to store Associated Contract extension object's fieldset fields.
	 * */
	get consultantSectionFields()
	{
		return this.consultantFieldSetMembers ? this.consultantFieldSetMembers.map(({fieldAPIName, fieldValue, isRequired, fieldLabel, fieldSetAPIName}) =>
		{
			return {
				fieldName: fieldAPIName, fieldValue: fieldValue, isRequired: isRequired, fieldLabel: fieldLabel, fieldSetAPIName: fieldSetAPIName
			};
		}) : [];
	}
	/**
	 * @Description This Function use to validate client and Financial Adviser section
	 * */
	@api validateClientDetailsSection(isValid){
		let isValidScreen = isValid;
		//noinspection JSUnresolvedFunction
		const caseExtRecord = this.clientForm.createRecordForApex();
		this.caseExtRecord = {...caseExtRecord};
		Object.entries(this.caseExtRecord)
		.filter(([key]) => this.displayClientFields.some(field => field.fieldName === key))
		.forEach(([key, value]) =>
		{
			if(value)
			{
				if(key === CLIENT_MOBILE.fieldApiName && this.isInvalidPhoneNumber(value))
				{
					this.showErrorToast(this.labels.ValidClientMobile);
					isValidScreen = false;
				}
			}else{
				if([CLIENT_FIRSTNAME.fieldApiName,
					CLIENT_SURNAME.fieldApiName,
					CLIENT_ID_NUMBER.fieldApiName,
					CLIENT_MOBILE.fieldApiName,
					CLIENT_POLICY_NUMBER.fieldApiName].some(element => key === element)){
					switch(key)
					{
						case CLIENT_FIRSTNAME.fieldApiName:
							this.showErrorToast(this.labels.ClientFirstNameMandatory);
							break;
						case CLIENT_SURNAME.fieldApiName:
							this.showErrorToast(this.labels.ClientLastNameMandatory);
							break;
						case CLIENT_ID_NUMBER.fieldApiName:
							this.showErrorToast(this.labels.ClientIdNumberMandatory);
							break;
						case CLIENT_MOBILE.fieldApiName:
							this.showErrorToast(this.labels.ClientMobileMandatory);
							break;
						case CLIENT_POLICY_NUMBER.fieldApiName:
							this.showErrorToast(this.labels.PolicyNumberMandatory);
							break;
						default:
							break;
					}
					isValidScreen = false;
				}
			}
		});
		isValidScreen = this.validateConsultantDetails(isValidScreen);
		return isValidScreen;
	}

	@api validateConsultantDetails(isValidScreen)
	{
		let isValidateConsultantSection = isValidScreen;
		//noinspection JSUnresolvedFunction
		const faRecord = this.financialAdviserForm.createRecordForApex();
		this.contractExtensionRecord = {...faRecord};
		Object.entries(this.contractExtensionRecord)
		.filter(([key]) => this.displayFinancialAdvisorFields.some(field => field.fieldName === key))
		.forEach(([key, value]) =>
		{
			if(!value)
			{
				if(key === CONSULTANT_CODE.fieldApiName)
				{
					this.showErrorToast(this.labels.ConsultantCodeMandatory);
					isValidateConsultantSection = false;
				}
			}
		});
		return isValidateConsultantSection;
	}
	/**
	 * @Description This Function use to handle flow status if flow status finish then screen will be close.
	 * */
	handleStatusChange(event) {
		if (event.detail.status === "FINISHED") {
			let caseId;
			//noinspection JSUnresolvedVariable
			const outputVariables = event.detail.outputVariables;
			outputVariables.forEach(outputVariable =>
			{
				if(outputVariable.name === 'SC_caseId')
				{
					caseId = outputVariable.value;
				}
			});
			this.hasNextActionOnCase=false;
			this.isClientDetails=false;
			this.isConsultantDetails = false;
			if(caseId){
				this.showSuccessToast(CREATE_SUCCESS_MESSAGE);
			}
			this.dispatchEvent(new CustomEvent('close_flow_change', {detail: {caseId:caseId}}));
		}
	}
}