/**
 * @description LWC Component used to display the required fields of a SObject under different sections(Accordion), when
 * this functionality cannot be achieved from configuration. The component accepts the fieldSets and the sections to be active
 * and display them accordingly.
 *
 * @author Jayanth.kumar.s@accenture.com
 */
import {LightningElement, api, wire} from 'lwc';

import {reduceErrors} from 'c/cmnLwcUtil';

import getFieldSetsAndActiveSections from '@salesforce/apex/CMN_CTRL_FieldSet.findByDeveloperName';
import getFieldSetsForRecord from '@salesforce/apex/CMN_CTRL_FieldSet.getFieldSetsForRecord';

//making the reference as CMN_LightningWebComponentsFieldSet__mdt as we get the invalid reference error if we import using CMN_LightningWebComponentsFieldSet__c
import FIELD_FIELD_SETS from '@salesforce/schema/CMN_LightningWebComponentsFieldSet__c.CMN_LWCFieldSets__c';
import FIELD_ACTIVE_SECTIONS from '@salesforce/schema/CMN_LightningWebComponentsFieldSet__c.CMN_LWCActiveSections__c';

export default class CmnLwcSobjectDisplayWithFieldSets extends LightningElement
{
	@api recordId;
	@api objectApiName;
	@api isDisplaySection = false;
	@api sectionsToBeActive;
	@api developerName;

	isLoading = true;

	fieldSetAPINameToFieldSetDTOList;

	/**
	 * @description getter method used to get the sections to be active by default
	 *
	 * @returns list of sections to be made active else empty list
	 */
	get activeSections()
	{
		return this.fieldSetAPINameToFieldSetDTOList && this.sectionsToBeActive ? this.sectionsToBeActive.filter(fieldSetAPIName => fieldSetAPIName in this.fieldSetAPINameToFieldSetDTOList) : [] ;
	}

	/**
	 * @description getter method used to get the list of fieldSetName with field Values
	 *
	 * @returns list of fieldSetNamesToValues else empty list
	 */
	get fieldSetAPINamesWithResults()
	{
		return this.fieldSetAPINameToFieldSetDTOList ? Object.entries(this.fieldSetAPINameToFieldSetDTOList).map(([fieldSetAPIName,dtoList]) =>
		{
			let fieldSetName = dtoList[Symbol.iterator]().next().value['fieldSetName'];
			return {key: fieldSetAPIName, value: dtoList, label: fieldSetName};
		}) : [];
	}

	/**
	 * @description getter method used to display the form on the html
	 *
	 * @returns return true if the elements exists else return false
	 */
	get isDisplaySection()
	{
		return this.fieldSetAPINamesWithResults.length > 0;
	}

	/**
	 * @description Show toast Error notification
	 * @param errorMessage Message to be displayed
	 * @param header Error header
	 * @returns {*}
	 */
	showToastError = (errorMessage, header = 'Error') =>
		this.template.querySelector('c-cmn-lwc-toast').customNotification(header, errorMessage, 'error');

	/**
	 * @description method invokes onload of the component and invokes the function to fetch the fieldset information
	 *
	 */
	@wire(getFieldSetsAndActiveSections, {developerName: '$developerName'})
	async fieldSetsAndActiveSection({error, data})
	{
		if(data)
		{
			this.sectionsToBeActive = data[FIELD_ACTIVE_SECTIONS.fieldApiName].split(',');
			let fieldsetParameterMap = {};
			fieldsetParameterMap[this.recordId] = data[FIELD_FIELD_SETS.fieldApiName].split(',');
			await this.handleGetFieldSetsForRecord(fieldsetParameterMap);
		}
		else if(error)
		{
			let errorMessage = reduceErrors(error).join(' // ');
			this.showToastError(errorMessage);
		}
		this.isLoading = false;
	}

	/**
	 * @description method used to get the fieldSets Information for the given recordId
	 *
	 * @returns promise{*map of recordId to map of fieldSetName with its values}
	 */
	handleGetFieldSetsForRecord(fieldsetParameterMap)
	{
		getFieldSetsForRecord({recordIdToFieldSetListMap: fieldsetParameterMap})
		.then(data => this.fieldSetAPINameToFieldSetDTOList = Object.values(data)[Symbol.iterator]().next().value)
		.catch(error =>
		{
			let errorMessage = reduceErrors(error).join(' // ');
			this.showToastError(errorMessage);
		});
	}
}