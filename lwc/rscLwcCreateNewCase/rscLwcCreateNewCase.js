/**
 * @description Lightning web component to allow agents to create case record by modifying the required fields
 * This Web component is created to be used in the global action using Aura component to create cases.
 *
 * @author vijay.jayswal@accenture.com, jayanth.kumar.s@accenture.com

 * @date June 2021, June 2023
 */
import CASE_OBJECT from '@salesforce/schema/Case';
import {FIRST_STEP, RENDER_FLOW, SECOND_STEP} from 'c/rscLwcDisplayFieldsSection';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {LightningElement, wire} from 'lwc';
import FIRST_NAME from '@salesforce/schema/Account.FirstName';
import LAST_NAME from '@salesforce/schema/Account.LastName';
import NAME from '@salesforce/schema/Account.Name';
import COMPANY_TRUST_NUMBER from '@salesforce/schema/Account.AW_CompanyRegistrationTrustNumber__c';

const RETAIL_RT = 'Retail';
const IDENTIFICATION_NUMBER = 'AW_IdentificationNumber__pc';

export default class RscLwcCreateNewCase extends LightningElement
{
	@wire(getObjectInfo, {objectApiName: CASE_OBJECT})
	objectInfo;

	currentStep;
	hasClientId = false;
	hasNextActionOnCase = false;

	get lookUpFields()
	{
		return [
			NAME.fieldApiName,
			FIRST_NAME.fieldApiName,
			LAST_NAME.fieldApiName,
			IDENTIFICATION_NUMBER,
			COMPANY_TRUST_NUMBER.fieldApiName
		].join(',');
	}

	get lookUpDisplayFormat()
	{
		return [
			NAME.fieldApiName,
			'|',
			IDENTIFICATION_NUMBER,
			COMPANY_TRUST_NUMBER.fieldApiName
		].join(' ');
	}
	
	get lookUpFields()
	{
		return [
			NAME.fieldApiName,
			FIRST_NAME.fieldApiName,
			LAST_NAME.fieldApiName,
			IDENTIFICATION_NUMBER,
			COMPANY_TRUST_NUMBER.fieldApiName
		].join(',');
	}

	get lookUpDisplayFormat()
	{
		return [
			NAME.fieldApiName,
			'|',
			IDENTIFICATION_NUMBER,
			COMPANY_TRUST_NUMBER.fieldApiName
		].join(' ');
	}

	get isLoading()
	{
		return !(this.objectInfo);
	}

	get recordTypeId()
	{
		const recordTypes = (this.objectInfo && this.objectInfo.data) ? this.objectInfo.data.recordTypeInfos : {};
		return Object.keys(recordTypes).find(recordTypeId => recordTypes[recordTypeId].name === RETAIL_RT);
	}

	get showNextButton()
	{

		return (this.currentStep === FIRST_STEP) && (this.hasClientId || this.hasNextActionOnCase);
	}

	get showPreviousButton()
	{
		return (this.currentStep === SECOND_STEP);
	}

	get showSaveButtons()
	{
		return (this.currentStep === SECOND_STEP) || (!this.hasClientId && !this.hasNextActionOnCase);
	}

	get displayFieldsSection()
	{
		return this.template.querySelector('c-rsc-lwc-display-fields-section');
	}

	/**
	 * To hide cancel button when flow render from LWC.
	 */
	get hideCancelButton()
	{
		return (this.currentStep === RENDER_FLOW);
	}

	errorCallback(error, stack)
	{
		console.error('Message: ', error.message, '\nName: ', error.name, '\nError Stack: ', error.stack, '\nStack: ', stack);
	}

	//noinspection FunctionWithMultipleReturnPointsJS
	async handleCreate()
	{
		if(!this.hasClientId && !this.hasNextActionOnCase)
		{
			//noinspection JSUnresolvedFunction
			let isValid = this.displayFieldsSection.validateFirstScreen();

			if(!isValid)
			{
				return;
			}
		}
		
		//noinspection DuplicatedCode
		let id;
		try
		{
			//noinspection JSUnresolvedFunction
			id = await this.displayFieldsSection.insertNewCase();
			(id && this.redirectToPageById(id));
		}
		catch(e)
		{
			console.error(e);
		}
		finally
		{
			if(id)
			{
				//noinspection JSUnresolvedFunction
				this.displayFieldsSection.resetComponent();
				this.dispatchCloseEvent();
			}
		}
	}

	//noinspection JSUnresolvedFunction
	redirectToPageById = (id) => this.template.querySelector('c-cmn-lwc-redirect').redirectToRecordPage(id);

	handleStepChange = ({detail}) => (this.currentStep = detail);

	//noinspection JSUnresolvedFunction
	handleNext = () => this.displayFieldsSection.handleNext();

	//noinspection JSUnresolvedFunction
	handlePrevious = () => this.displayFieldsSection.handlePrevious();
	handleCancel = () =>
	{
		//noinspection JSUnresolvedFunction
		this.displayFieldsSection.resetComponent();
		this.dispatchCloseEvent();
	};

	handleClientIdChange({detail: {hasClientId}})
	{
		this.hasClientId = hasClientId;
	}

	dispatchCloseEvent = () => this.dispatchEvent(new CustomEvent('close'));

	/**
	 * It will handel service type change if NextActionOnCase will have value with  flow api  name it will get boolean true
	 * */
	handleServiceTypeChange({detail: {hasServiceType}})
	{
		this.hasNextActionOnCase = hasServiceType;
	}

	/**
	 * To close the screen when flow status will be finish
	 * */
	handleCloseFlowScreen({detail: {caseId}})
	{

		if(caseId)
		{
			(caseId && this.redirectToPageById(caseId));
		}
		//noinspection JSUnresolvedFunction
		this.displayFieldsSection.resetComponent();
		this.dispatchCloseEvent();
		this.hasNextActionOnCase = false;

	}
}