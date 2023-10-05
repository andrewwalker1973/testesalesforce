//noinspection CssInvalidHtmlTagReference,FunctionWithMultipleLoopsJS

/**
 * @description Form component with ability to create an object. Can be used as a replacement for lightning-record-edit-form
 * @see CmnLwcLookup {Lookup form element component (Dependency)}
 * @author darrion.james.singh@accenture.com, jayanth.kumar.s@accenture.com
 * @date January 2022, June 2023
 * TODO: Add support for more field types
 */
import getSObjectFieldInfo from '@salesforce/apex/CMN_CTRL_SObjectInformation.getSObjectFieldInformation';
import {getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import {createRecord, generateRecordInputForCreate, getRecordCreateDefaults} from 'lightning/uiRecordApi';
import {api, LightningElement, wire} from 'lwc';

export default class CmnLwcCreateForm extends LightningElement
{
	/**
	 * @description If true, shows the Save button
	 * @type {boolean}
	 */
	@api showSave = false;

	/**
	 * @description If true, shows the Cancel button
	 * @type {boolean}
	 */
	@api showCancel = false;

	/**
	 * @description (Required) Object API Name
	 * @type {string}
	 */
	@api objectName = '';

	/**
	 * @description List of fields to display, see @type for object structure.
	 * @type {Field[]}
	 */
	@api fields = [];
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
	/**
	 * @description Record type Id to create the SObject. If not provided, the default record type Id
	 * will be used.
	 * @type {string}
	 */
	@api recordTypeId = '';

	/**
	 * @description Creates SObject structure with required fields and default values.
	 */
	@wire(getRecordCreateDefaults, {objectApiName: '$objectName'})
	objectCreateDefaults;

	/**
	 * @description Returns field information such as type, label etc. required for form element rendering.
	 * @type {{data: {lookupObjectApiName}, error}}
	 */
	@wire(getSObjectFieldInfo, {objectName: '$objectName'})
	objectInfo;

	//noinspection JSCheckFunctionSignatures //Incorrect inspection error shown, see documentation below.
	/**
	 * @description Retrieves picklist values for record type.
	 * @see https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_wire_adapters_picklist_values_record
	 * @see https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_responses_picklist_values_collection.htm
	 * @type {{data: {picklistFieldValues, objectInfos}, error}}
	 */
	@wire(getPicklistValuesByRecordType, {objectApiName: '$objectName', recordTypeId: '$availableRecordTypeId'})
	picklistCollection;

	formElementMap = {};
	awaitingRecordCreation = false;

	get showSpinner()
	{
		return this.isLoading || this.awaitingRecordCreation;
	}

	get isLoading()
	{
		this.showFetchErrors();
		return this.displayFieldList.length === 0;
	}

	get picklistMap()
	{
		return this.picklistCollection && this.picklistCollection.data ?
			   this.picklistCollection.data.picklistFieldValues : {};
	}

	get defaultRecordTypeId()
	{
		return this.objectCreateDefaults && this.objectCreateDefaults.data
			   ? this.objectCreateDefaults.data.objectInfos[this.objectName].defaultRecordTypeId
			   : null;
	}

	//noinspection JSUnusedGlobalSymbols
	get availableRecordTypeId()
	{
		return this.recordTypeId || this.defaultRecordTypeId;
	}

	/**
	 * @description Converts fields into List of Field objects.
	 * @see fields
	 * @returns {Field[]}
	 */
	get displayFieldList()
	{
		return this.fields.map(field =>
		{
			let populatedField = new Field();
			populatedField.fieldType = field.fieldType || this.getFieldType(field.fieldName);
			populatedField.isRequired = Boolean(field.isRequired);
			populatedField.fieldName = field.fieldName;
			populatedField.fieldValue = field.fieldValue || (populatedField.isLookup ? null : '');
			populatedField.fieldLabel = field.fieldLabel || this.getFieldLabel(field.fieldName);
			populatedField.picklistValues = field.picklistValues || (populatedField.isPicklist ? this.getPicklistValues(field.fieldName)
																							   : undefined);
			populatedField.padPicklistValuesBeginning = field.padPicklistValuesBeginning || [];
			populatedField.padPicklistValuesEnd = field.padPicklistValuesEnd || [];
			populatedField.fieldLookupObjectApiName = field.fieldLookupObjectApiName ||
				(populatedField.isLookup ? this.getLookupObjectApiName(field.fieldName) : undefined);
			return populatedField;
		});
	}

	get recordInputForCreate()
	{
		return this.objectCreateDefaults && this.objectCreateDefaults.data
			   ? generateRecordInputForCreate(
				this.objectCreateDefaults.data.record,
				this.objectCreateDefaults.data.objectInfos[this.objectName])
			   : {fields: {}};
	}

	showFetchErrors()
	{
		(this.objectInfo && this.objectInfo.error) && this.showErrorToast(this.objectInfo.error.body.message);
		(this.picklistCollection && this.picklistCollection.error) && this.showErrorToast(this.picklistCollection.error.body.message);
	}

	getFieldType = (fieldName) => this.objectInfo && this.objectInfo.data ? this.objectInfo.data[fieldName].fieldType : '';
	getFieldLabel = (fieldName) => this.objectInfo && this.objectInfo.data ? this.objectInfo.data[fieldName].fieldLabel : '';
	getLookupObjectApiName = (fieldName) => this.objectInfo && this.objectInfo.data ? this.objectInfo.data[fieldName].lookupObjectApiName
																					: '';

	/**
	 * @description Returns picklist values for a field from the picklist collection.
	 * @param fieldName Field API name
	 * @returns {{label, value, isDefault}[]}
	 */
	getPicklistValues(fieldName)
	{
		let picklistData = this.picklistMap[fieldName];
		return picklistData ? picklistData.values.map(val =>
			({
				label: val.label,
				value: val.value,
				isDefault: Boolean(picklistData.defaultValue) && picklistData.defaultValue.value === val.value
			})) : [];
	}

	/**
	 * @description Create New Object that is ready for insert via uiRecordApi.createRecord
	 *
	 * @see RecordInputRepresentation {for object structure}
	 * @returns {RecordInputRepresentation}
	 */
	@api createRecord()
	{
		let defaultRecord = this.recordInputForCreate;
		if(defaultRecord)
		{
			this.fields.forEach(({fieldName, fieldValue}) => (defaultRecord.fields[fieldName] = fieldValue));
			Object.keys(this.formElementMap).forEach(key => (defaultRecord.fields[key] = this.formElementMap[key]));
		}
		return defaultRecord;
	}

	/**
	 * @description Create New Object that is ready for insert via Apex controller
	 * @returns {{[p: string]: string | number | boolean | null}}
	 */
	@api createRecordForApex()
	{
		let defaultRecord = this.createRecord();
		let apexRecord = defaultRecord.fields;
		apexRecord['sobjectType'] = this.objectName;
		return apexRecord;
	}

	/**
	 * @description Inserts a new object based on the form inputs and object defaults via {uiRecordApi.createRecord}.
	 * @see uiRecordApi.createRecord
	 * @returns {Promise<RecordRepresentation>}
	 */
	@api
	async insertRecord()
	{
		let record = this.createRecord();
		let createResult;
		try
		{
			this.awaitingRecordCreation = true;
			createResult = await createRecord(record);
			this.dispatchRecordCreatedEvent(createResult);
			this.showSuccessToast('Case Created Successfully');
		}
		catch(e)
		{
			this.showErrorToast(e.body.message);
		}
		finally
		{
			this.awaitingRecordCreation = false;
		}
		return createResult;
	}

	@api clearForm()
	{
		this.template.querySelectorAll('.form-field').forEach(element => (element.value = ''));
		this.template.querySelectorAll('.lookup-field').forEach(element => (element.defaultRecordId = null));
	}

	//noinspection JSUnresolvedFunction
	showErrorToast = (message = '', header = 'Error') => this.template.querySelector('c-cmn-lwc-toast')
															 .customNotification(header, message, 'error');
	//noinspection JSUnresolvedFunction
	showSuccessToast = (message = '', header = 'Success') => this.template.querySelector('c-cmn-lwc-toast')
																 .customNotification(header, message, 'success');

	handleFieldChange = ({detail: {value}, target: {dataset: {id}}}) =>
	{
		this.formElementMap[id] = value;
		this.dispatchValueChangedEvent();
	};
	handleLookupValueSelect = ({detail: {key, selectedId}}) =>
	{
		this.formElementMap[key] = selectedId;
		this.dispatchValueChangedEvent();
	};

	errorCallback(error, stack)
	{
		console.error('Message: ', error.message, '\nName: ', error.name, '\nError Stack: ', error.stack, '\nStack: ', stack);
	}

	dispatchRecordCreatedEvent = (createResult) => this.dispatchEvent(new CustomEvent('recordcreated', {detail: {createResult}}));
	dispatchValueChangedEvent = () => this.dispatchEvent(new CustomEvent('valuechanged', {detail: this.createRecord()}));
	cancel = () => (this.dispatchEvent(new CustomEvent('cancel')));
}

const TEXT_FIELD_TYPE = 'STRING';
const BOOLEAN_FIELD_TYPE = 'BOOLEAN';
const LOOKUP_FIELD_TYPE = 'REFERENCE';
const EMAIL_FIELD_TYPE = 'EMAIL';
const PICKLIST_FIELD_TYPE = 'PICKLIST';
const PHONE_FIELD_TYPE = 'PHONE';

/**
 * @description Internal class to hold field information
 */
export class Field
{
	fieldName = '';
	fieldValue = '';
	fieldLabel = '';
	fieldType = '';
	fieldLookupObjectApiName = '';
	isRequired = false;

	/**
	 * @description List of picklist options if the field type is picklist
	 * @property {string} label API Name
	 * @property {string} value API Value
	 * @property {boolean} isDefault Marks the option as the default option for this list
	 * @type {{label, value, isDefault}[]}
	 */
	picklistValues = [];

	padPicklistValuesBeginning = [];
	padPicklistValuesEnd = [];

	//noinspection JSUnusedGlobalSymbols // Used in HTML
	get displayPicklistOptions()
	{
		return [...this.padPicklistValuesBeginning, ...this.picklistValues, ...this.padPicklistValuesEnd];
	}

	//noinspection JSUnusedGlobalSymbols // Used in HTML
	get isText()
	{
		return this.fieldType === TEXT_FIELD_TYPE;
	}

	//noinspection JSUnusedGlobalSymbols // Used in HTML
	get isBoolean()
	{
		return this.fieldType === BOOLEAN_FIELD_TYPE;
	}

	get isLookup()
	{
		return this.fieldType === LOOKUP_FIELD_TYPE;
	}

	//noinspection JSUnusedGlobalSymbols // Used in HTML
	get isEmail()
	{
		return this.fieldType === EMAIL_FIELD_TYPE;
	}

	get isPicklist()
	{
		return this.fieldType === PICKLIST_FIELD_TYPE;
	}

	//noinspection JSUnusedGlobalSymbols // Used in HTML
	get isPhone()
	{
		return this.fieldType === PHONE_FIELD_TYPE;
	}
}