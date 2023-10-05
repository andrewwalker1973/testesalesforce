/**
 * @description Lightning web component to allow agents to select department & the service type for a case
 * This Web component is created to be used in the lightning flow to clone cases.
 *
 * @author darrion.james.singh@accenture.com rajpal.singh@accenture.com
 *
 * @date Sept 2022
 */
import getDepartments from '@salesforce/apex/RSC_CTRL_ServiceType.findAllDepartments';
import DEPARTMENT_FIELD from '@salesforce/schema/Case.RSC_Department__c';
import SERVICE_TYPE_FIELD from '@salesforce/schema/Case.RSC_ServiceType__c';

import SERVICE_TYPE_OBJECT from '@salesforce/schema/SC_ServiceType__c';
import SERVICE_TYPE_NAME_FIELD from '@salesforce/schema/SC_ServiceType__c.Name';
import PROCESS_NAME_FIELD from '@salesforce/schema/SC_ServiceType__c.SC_Department__c';
import {getFieldValue, getRecord} from 'lightning/uiRecordApi';
import {api, LightningElement, wire} from 'lwc';

export default class RscLwcChooseServiceType extends LightningElement
{

	@api caseRecordId;
	@api selectedServiceType;
	department;
	@api selectedServiceTypeName;
	sObjectName = SERVICE_TYPE_OBJECT.objectApiName;
	sObjectFieldName = SERVICE_TYPE_NAME_FIELD.fieldApiName;
	@api filterCriteria;
	@wire(getDepartments)
	departments;

	@api get selectedDepartment()
	{
		return this.department;
	}

	set selectedDepartment(value)
	{
		this.department = value;
		let scLup = this.template.querySelector('c-sc-lwc-custom-lookup');
		if(!value && scLup)
		{
			//noinspection JSUnresolvedFunction
			scLup.updateSelectedRecord();
		}
	}

	get displayDepartments()
	{
		((this.departments && this.departments.error) && this.showErrors());
		return this.departments && this.departments.data ? [
			{value: '', label: '-- None --'},
			...this.departments.data.map(element => ({value: element, label: element}))
		] : [];
	}

	showErrors = () =>
	{
		this.showErrorToast(this.departments.error.body.message);
	};

	//noinspection JSUnresolvedFunction
	showErrorToast = (errorMessage, header = 'Error') => this.template.querySelector('c-cmn-lwc-toast').customNotification(header, errorMessage, 'error');

	@wire(getRecord, {
		recordId: '$caseRecordId', fields: [
			DEPARTMENT_FIELD,
			SERVICE_TYPE_FIELD
		]
	}) wiredCase({error, data})
	{
		if(data)
		{
			this.department = this.department || getFieldValue(data, DEPARTMENT_FIELD);
			this.selectedServiceType = this.selectedServiceType || getFieldValue(data, SERVICE_TYPE_FIELD);
			this.filterCriteria = this.department ? PROCESS_NAME_FIELD.fieldApiName + ' = \'' + this.department + '\'' : this.filterCriteria;
		}
		else if(error)
		{
			this.showErrorToast(error.body.message);
		}
	}

	// function to handle change event of department dropdown
	handleDepartmentChange = ({detail}) =>
	{
		this.department = detail.value;
		this.filterCriteria = PROCESS_NAME_FIELD.fieldApiName + ' = \'' + this.department + '\'';
		this.selectedServiceType = null;
		//noinspection JSUnresolvedFunction
		this.template.querySelector('c-sc-lwc-custom-lookup').updateSelectedRecord();
	};

	handleServiceTypeSelection = ({detail}) =>
	{
		this.selectedServiceType = detail.selectedRecord ? detail.selectedRecord.Id : null;
		this.selectedServiceTypeName = detail.selectedRecord ? detail.selectedRecord.Name : null;
		this.dispatchEvent(new CustomEvent('servicetypeselection', {detail: this.selectedServiceType}));
	};
}