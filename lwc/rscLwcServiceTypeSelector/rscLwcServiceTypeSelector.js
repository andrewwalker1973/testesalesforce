/**
 * @description JavaScript to handle events of rscLwcServiceTypeSelector component
 *
 * @author Accenture
 *
 * @date June 2021
 */
import {api, LightningElement, wire} from 'lwc';
import {getFieldValue, getRecord, updateRecord} from 'lightning/uiRecordApi';

import getAssignableCaseQueueId from '@salesforce/apex/RSC_CTRL_CloneCaseWithFieldSet.getAssignableCaseQueueId';
import getServiceType from '@salesforce/apex/RSC_CTRL_ServiceType.findServiceTypeById';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import DEPARTMENT_FIELD from '@salesforce/schema/Case.RSC_Department__c';
import SERVICE_TYPE_FIELD from '@salesforce/schema/Case.RSC_ServiceType__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import ASSIGNABLE_TO_FIELD from '@salesforce/schema/Case.SC_AssignedTo__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import userId from '@salesforce/user/Id';
import {FlowNavigationFinishEvent} from 'lightning/flowSupport';

const BLANK = '';
const PROGRESS = 'In Progress';
const successMessage = 'Case updated successfully.';
const informationMessage ='You have reclassified the case and it will be rerouted to the relevant team. Please close tab as you cannot continue processing or select Assign this case to myself.';
const notificationMessage = 'No changes have been made, please make the relevant selections and click on Save. Alternatively, if you do not wish to proceed, please click on Cancel to exit.';

export default class RscLwcServiceTypeSelector extends LightningElement {
    @api recordId;
	@api invokedFromFlow;
	@api selectedCaseOwner;
	@api hideButton = false;
	remainCaseOwner = false;
	showNotification = false;
	isLoading = false;
	messageBody;
	caseDepartment;
	caseServiceType;
	assignableServiceType;
	selectedServiceType;
	assignableCaseQueueId;

	/**
	 * @description function to get details of case record.
	 */
	@wire(getRecord, {
		recordId: '$recordId', fields: [
			DEPARTMENT_FIELD,
			SERVICE_TYPE_FIELD
		]
	}) wiredCase({error, data})
	{
		if(data)
		{
			this.caseDepartment = this.caseDepartment || getFieldValue(data, DEPARTMENT_FIELD);
			this.caseServiceType = this.caseServiceType || getFieldValue(data, SERVICE_TYPE_FIELD);
		}
		else if(error)
		{
			this.showErrorToast(error.body.message);
		}
	}

	/**
	 * @description function is used to get assignable queue Id if selected service type of case is assignable
	 */
	@wire(getAssignableCaseQueueId, {serviceTypeId: '$selectedServiceType'}) fetchAssignableCaseQueue({error, data})
	{
		if(data)
		{
			this.assignableCaseQueueId = data;
		}
		else if(error)
		{
			this.showErrorToast(error.body.message);
		}
	}

	/**
	 * @description function to close the lightning component
	 */
	cancelServiceType()
	{
		this.dispatchEvent(new CloseActionScreenEvent());
		this.handleFlowFinishEvent();
	}

	// function to save service type on the case record
	saveServiceType()
	{
		// Get selected values from the child component
		let selectedDepartment = this.template.querySelector('c-rsc-lwc-choose-service-type').selectedDepartment;
		let selectedServiceType = this.template.querySelector('c-rsc-lwc-choose-service-type').selectedServiceType;
		this.processServiceType(selectedServiceType, selectedDepartment);

	}

	/**
	 * @description function to set selected service type
	 */
	handleServiceTypeSelection(event)
	{
		this.selectedServiceType = event.detail;
	}

	/**
	 * @description function to process case service type base on serviceability
	 */
	processServiceType(selectedServiceType, selectedDepartment)
	{
		this.isLoading = true;
		//noinspection OverlyComplexFunctionJS,FunctionTooLongJS
		getServiceType({recordId: selectedServiceType})
		.then(result =>
		{
			this.assignableServiceType = result.SC_Assignable__c;
			const fields = {};
			fields[ID_FIELD.fieldApiName] = this.recordId;
			fields[DEPARTMENT_FIELD.fieldApiName] = selectedDepartment;
			if(selectedServiceType === BLANK)
			{
				fields[SERVICE_TYPE_FIELD.fieldApiName] = null;
			}
			else
			{
				fields[SERVICE_TYPE_FIELD.fieldApiName] = selectedServiceType;
			}
			if(this.remainCaseOwner)
			{
				fields[STATUS_FIELD.fieldApiName] = PROGRESS;
				fields[ASSIGNABLE_TO_FIELD.fieldApiName] = this.selectedCaseOwner;
				if(this.assignableServiceType)
				{
					fields[OWNER_FIELD.fieldApiName] = this.selectedCaseOwner;
				}
			}
			else
			{
				fields[OWNER_FIELD.fieldApiName] = this.assignableCaseQueueId;
				fields[STATUS_FIELD.fieldApiName] = PROGRESS;
				fields[ASSIGNABLE_TO_FIELD.fieldApiName] = '';
			}

			const recordInput = {fields};
			if(selectedDepartment !== null && selectedServiceType !== null)
			{
				this.isLoading = false;

					if(this.caseDepartment === selectedDepartment && this.caseServiceType === selectedServiceType)
					{
						this.showNotification = this.hideButton !== true;
						this.messageBody = notificationMessage;
					}
					else
					{
						if(this.remainCaseOwner)
						{
							this.handleIfCaseOwnerTrue(recordInput);
						}
						else
						{
							this.handleIfCaseOwnerFalse(recordInput);
						}
					}
			}
			else if(selectedDepartment === null || selectedServiceType === null)
			{
				this.isLoading = false;
				this.showNotification = false;
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', 'Please select Department and ServiceType', 'error');
			}
		})
		.catch(error =>
		{
			this.isLoading = false;
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', error.body.message, 'error');
		});

	}

	/**
	 * @description function to keep the current user as owner on case record.
	 */
	handleRemainCaseOwner(event)
	{
		// function to populate case owner
		this.remainCaseOwner = event.target.checked;
		if(this.remainCaseOwner)
		{
			// eslint-disable-next-line @lwc/lwc/no-api-reassignments
			this.selectedCaseOwner = userId;
		}
	}

	/**
	 * @description function to update case record.
	 */
	handleUpdateRecord(recordInput, message)
	{
		updateRecord(recordInput)
		.then(() =>
		{
			if(this.remainCaseOwner)
			{
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', message, 'success');
				this.dispatchEvent(new CloseActionScreenEvent());
				this.handleFlowFinishEvent();
			}
		})
		.catch(error =>
		{
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', error.body.message, 'error');
		});
	}

	/**
	 * @description function called when remain case owner is true.
	 */
	handleIfCaseOwnerTrue(recordInput)
	{
		this.showNotification = false;
		this.handleUpdateRecord(recordInput, successMessage);
	}

	/**
	 * @description function called when remain case owner is false.
	 */
	handleIfCaseOwnerFalse(recordInput)
	{
		this.messageBody = informationMessage;
		this.handleUpdateRecord(recordInput, successMessage);
	}

	/**
	 * @description function called to cancel the process when users reclassify the case to update the service type.
	 */
	handleFlowFinishEvent()
	{
		if(this.invokedFromFlow)
		{
			this.dispatchEvent(new FlowNavigationFinishEvent());
		}
	}

}