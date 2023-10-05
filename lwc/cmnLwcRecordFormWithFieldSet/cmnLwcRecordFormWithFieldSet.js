import getFieldSet from '@salesforce/apex/CMN_CTRL_FieldSet.getFieldSetsForRecord';
import {api, LightningElement} from 'lwc';
import {reduceErrors} from 'c/cmnLwcUtil';

const DELAY = 1500;

/**
 * @description Common component to display record form for an object using fieldset. This component accepts object API name,
 * recordId of the record and the fieldset name for displaying the section with inline edit.
 * The fields can be edited and saved using standard functionality provided by lightning record form.
 *
 * @author vikrant.goswami@accenture.com
 *
 * @date September 2022
 */
export default class CmnLwcRecordFormWithFieldSet extends LightningElement
{
	@api objectApiName;
	activeSections;
	recordId;
	fieldSetAPINameToFieldSetDTOList;
	foundError;
	isLoading;
	inViewMode = true;

	get fieldSetAPINamesWithResults()
	{
		return this.fieldSetAPINameToFieldSetDTOList ? Object.entries(this.fieldSetAPINameToFieldSetDTOList).map(([fieldSetAPIName, dtoList]) =>
		{
			let fieldsToDisplay = [];
			let fieldSetName = dtoList[Symbol.iterator]().next().value['fieldSetName'];
			for(let field of dtoList)
			{
				fieldsToDisplay.push(field);
			}
			return {key: fieldSetAPIName, value: fieldsToDisplay, label: fieldSetName, sectionName: fieldSetAPIName};
		}) : [];
	}

	@api
	async getFieldsForFieldSet(recordId, listOfFieldSetAPINames)
	{
		let recordIdWithFieldsetMap = {};
		recordIdWithFieldsetMap[recordId] = Object.values(listOfFieldSetAPINames);
		this.recordId = recordId;
		await getFieldSet({recordIdToFieldSetListMap: recordIdWithFieldsetMap})
		.then(data =>
		{
			let sections = [];
			this.fieldSetAPINameToFieldSetDTOList = Object.values(data)[Symbol.iterator]().next().value;
			Object.entries(this.fieldSetAPINameToFieldSetDTOList).map(([fieldSetAPIName]) =>
			{
				sections.push(fieldSetAPIName);
			});
			this.activeSections = sections;
		})
		.catch(error =>
		{
			this.foundError = error;
			this.showErrorToast(reduceErrors(error));
		});
	}

	//this function is used to toggle the mode of display from view to edit form and vice-versa
	toggleFormMode(){
		this.isLoading = true;
		setTimeout(() =>
		{
			this.isLoading = false;
			this.inViewMode = !this.inViewMode;
		}, DELAY);
	}

	handleSubmit(event){
		event.preventDefault();       // stop the form from submitting
		const fields = event.detail.fields;
		this.template.querySelector('lightning-record-edit-form').submit(fields);
	}

	handleSuccess(event){
		let message = 'Record Updated Successfully'
		this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', message, 'success');
		this.toggleFormMode();
	}

	handleError(event) {
		let error = event.detail.detail;
		error = error.charAt(0).toUpperCase() + error.slice(1);
		this.showErrorToast(error);
	}

	showErrorToast(message, header = 'Error')
	{
		this.template.querySelector('c-cmn-lwc-toast').customNotification(header, message, 'error');
	}
}