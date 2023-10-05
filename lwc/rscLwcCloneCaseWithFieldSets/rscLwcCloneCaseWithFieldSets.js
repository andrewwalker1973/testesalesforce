/**
 * @description Lightning web component to allow agents to clone case record by modifying the required fields
 * This Web component is created to be used in the lightning flow to clone cases.
 *
 * @author aditya.kumar.nanda@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date June 2021, June 2023
 */
import RECORDTYPE_ID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import FIRST_NAME from '@salesforce/schema/Account.FirstName';
import LAST_NAME from '@salesforce/schema/Account.LastName';
import NAME from '@salesforce/schema/Account.Name';
import COMPANY_TRUST_NUMBER from '@salesforce/schema/Account.AW_CompanyRegistrationTrustNumber__c';
const IDENTIFICATION_NUMBER = 'AW_IdentificationNumber__pc';

import {FINAL_STEP, FIRST_STEP, SECOND_STEP, THIRD_STEP} from 'c/rscLwcDisplayFieldsSection';
import {CloseActionScreenEvent} from 'lightning/actions';
import {FlowNavigationBackEvent, FlowNavigationFinishEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';

import {getFieldValue, getRecord} from 'lightning/uiRecordApi';
import {api, LightningElement, wire} from 'lwc';

const STATUS_IN_PROGRESS = 'In Progress';
const STATUS_ON_HOLD = 'On Hold';
const STATUS_ESCALATED = 'Escalated';
export default class RscLwcCloneCaseWithFieldSets extends LightningElement
{
	@api recordId;
	@api cancelClicked = false;
	@api invokedFromFlow;
	@api cloneSuccess = false;
	isLoading = false;

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

	stepName;
	@wire(getRecord, {
		recordId: '$recordId', fields: [
			RECORDTYPE_ID_FIELD,
			STATUS_FIELD
		]
	})
	case;
	@api dispatchFlowFinish = false;

	get showNextButton()
	{
		return !this.isFinalStep;
	}

	get showPreviousButton()
	{
		return !this.isFirstStep;
	}

	get showSaveButtons()
	{
		return this.isFinalStep;
	}

	get isFirstStep()
	{
		return this.stepName === FIRST_STEP;
	}

	get isFinalStep()
	{
		return this.stepName === FINAL_STEP;
	}

	get recordTypeId()
	{
		return this.case && this.case.data && getFieldValue(this.case.data, RECORDTYPE_ID_FIELD);
	}

	get showRelatedToParentCheckbox()
	{
		return this.case && this.case.data && [
			STATUS_IN_PROGRESS,
			STATUS_ON_HOLD,
			STATUS_ESCALATED
		].some(
		status => status === getFieldValue(this.case.data, STATUS_FIELD));
	}

	get displayFieldsSection()
	{
		return this.template.querySelector('c-rsc-lwc-display-fields-section');
	}

	connectedCallback()
	{
		this.isLoading = false;
		this.stepName = FIRST_STEP;
	}

	// Save operations
	async handleSaveAndNew()
	{
		try
		{
			//noinspection JSUnresolvedFunction
			await this.displayFieldsSection.cloneCase(true);
		}
		catch(e)
		{
			console.error(e);
		}
	}

	async handleSave()
	{
		let id;
		try
		{
			//noinspection JSUnresolvedFunction
			id = await this.displayFieldsSection.cloneCase();
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
				this.handleCloseActionScreen();
				//this is true only when the clone component is invoked from RSC_FLOW_CaseOnHold
				//noinspection JSUnresolvedFunction
				this.cloneSuccess = this.displayFieldsSection.sendCloneSuccessful();
				if(this.cloneSuccess)
				{
					this.handleDispatchNextEvent();
				}

			}
		}
	}

	handleDispatchNextEvent()
	{
		this.dispatchEvent(new FlowNavigationNextEvent());
	}

	// Handlers
	handleCloseActionScreen = () => this.dispatchEvent(new CloseActionScreenEvent());

	// Navigation

	handleStepChange = ({detail}) => (this.stepName = detail);

	//noinspection JSUnresolvedFunction
	redirectToPageById = (id) => this.template.querySelector('c-cmn-lwc-redirect').redirectToRecordPage(id);

	handleNext()
	{
		switch(this.stepName)
		{
			case FIRST_STEP:
			case SECOND_STEP:
				//noinspection JSUnresolvedFunction
				this.displayFieldsSection.handleNext();
				break;
			case THIRD_STEP:
				//noinspection JSUnresolvedFunction
				this.displayFieldsSection.handleNext();
				break;
			default:
				break;
		}
	}

	handlePrevious()
	{
		switch(this.stepName)
		{
			case SECOND_STEP:
			case THIRD_STEP:
			case FINAL_STEP:
				//noinspection JSUnresolvedFunction
				this.displayFieldsSection.handlePrevious();
				break;
			default:
				break;
		}
	}

	handleCancel()
	{
		this.dispatchEvent(new CustomEvent('cancel_pressed'));
		this.dispatchEvent(new CloseActionScreenEvent());
		this.finishFlowEvent();
		if(this.invokedFromFlow)
		{
			this.cancelClicked = true;
			this.flowPreviousEvent();
		}
	}

	finishFlowEvent()
	{
		if(this.dispatchFlowFinish)
		{
			this.dispatchEvent(new FlowNavigationFinishEvent());
		}
	}

	flowPreviousEvent()
	{
		if(this.cancelClicked)
		{
			this.dispatchEvent(new FlowNavigationBackEvent());
		}
	}
}