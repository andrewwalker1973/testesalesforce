/**
 * @description Component to create task record
 * @story ST-308231
 * @author jayanth.kumar.s@accenture.com uttpal.chandra@accenture.com
 *
 * @date November 2022
 */
import compareTime from '@salesforce/apex/SC_CTRL_CreateTask.compareTime';
import createTask from '@salesforce/apex/SC_CTRL_CreateTask.createTask';
import getPicklistLabel from '@salesforce/apex/SC_CTRL_CreateTask.getPicklistLabel';
import caseResumeDateValidation from '@salesforce/label/c.RSC_CaseResumeDateValidation';
import reminderDateTime from '@salesforce/label/c.RSC_ReminderDateTime';
import compareDateTime from '@salesforce/label/c.RSC_CompareDateTime';
import TASK_OBJECT_NAME from '@salesforce/schema/Task';
import {reduceErrors} from 'c/cmnLwcUtil';
import {CloseActionScreenEvent} from 'lightning/actions';
import {FlowNavigationFinishEvent} from 'lightning/flowSupport';
import {api, LightningElement, wire} from 'lwc';

const ENGAGED = 'Engaged';
const NO_ANSWER = 'No Answer';
const NOT_CONTACTABLE = 'Not Contactable - Service Not Available';
const RESCHEDULE = 'Client Answered and Requested Reschedule';
const VOICE_MAIL = 'Voicemail';

const REMINDER_SUBJECTS = [
	NO_ANSWER,
	ENGAGED,
	NOT_CONTACTABLE,
	RESCHEDULE,
	VOICE_MAIL
];

export default class ScLwcCreateTask extends LightningElement
{
	@api recordId;
	@api invokedFromFlow;
	showReminderDateTime;
	showReminderCheckbox;
	showErrorMessage;
	isLoading = false;
	fieldName = 'Subject';
	reminderTime;
	warningMessage = reminderDateTime;
	selectedSubject;
	@wire(getPicklistLabel, {fieldName: '$fieldName'})
	subjectPickLists;

	get subjectOptions()
	{
		let options = [];
		if(this.subjectPickLists)
		{
			const {error, data} = this.subjectPickLists;
			if(error)
			{
				this.showToastError(reduceErrors(error));
			}
			else if(data)
			{
				Object.keys(data).forEach(subject =>
				{
					options.push({label: subject, value: data[subject]});
				});
			}
		}
		return options;
	}

	showReminder()
	{
		if(REMINDER_SUBJECTS.includes(this.selectedSubject))
		{
			let checkboxValue = this.template.querySelector('[data-field=\'reminderCheckbox\']');
			if(checkboxValue != null)
			{
				this.template.querySelector('[data-field=\'reminderCheckbox\']').checked = false;
			}
			this.showReminderCheckbox = true;
		}
		else
		{
			this.showReminderCheckbox = false;
		}
	}

	handleChange(event)
	{
		if(event.target.checked)
		{
			this.showReminderDateTime = true;
			this.showErrorMessage = false;
		}
		else
		{
			this.showErrorMessage = true;
			this.showReminderDateTime = false;
		}
	}

	handleDateTimeChange(event)
	{
		this.reminderTime = event.target.value;
		if(this.reminderTime !== '' || this.reminderTime !== null)
		{
			this.showErrorMessage = false;
		}
	}

	//noinspection JSUnresolvedFunction
	showToastError = (errorMessage, header = 'Error') => this.template.querySelector('c-cmn-lwc-toast').customNotification(header, errorMessage, 'error');

	//noinspection JSUnresolvedFunction
	dateTimeError = (errorMessage, header = 'Error') => this.template.querySelector('c-cmn-lwc-toast')
	.customNotification(header, compareDateTime, 'error');

	handleSelectedSubject(event)
	{
		this.showErrorMessage = false;
		this.showReminderDateTime = false;
		this.selectedSubject = event.target.options.find(opt => opt.value === event.detail.value).label;
		this.reminderTime = '';
		this.showReminder();
	}

	closeAction = () => (this.handleCancel());

	checkTask()
	{
		if(REMINDER_SUBJECTS.includes(this.selectedSubject) && (this.reminderTime === '' || this.reminderTime === null) && this.template.querySelector(
				'[data-field=\'reminderCheckbox\']').checked === true)
		{
			this.showErrorMessage = true;
		}
		else
		{
			if((REMINDER_SUBJECTS.includes(this.selectedSubject) && this.template.querySelector('[data-field=\'reminderCheckbox\']').checked === false)
					|| (!REMINDER_SUBJECTS.includes(this.selectedSubject)))
			{
				this.reminderTime = '';
				this.createTask();
			}
			else if(REMINDER_SUBJECTS.includes(this.selectedSubject) && this.template.querySelector('[data-field=\'reminderCheckbox\']').checked === true)
			{
				this.checkDateTime();
			}
		}
	}

	checkDateTime()
	{
		compareTime({userDateTime: this.reminderTime , numberOfMonths: caseResumeDateValidation})
		.then((result) =>
		{
			if(result === true)
			{
				this.createTask();
			}
			else
			{
				this.dateTimeError();
			}
		})
		.catch((error) =>
		{
			this.showToastError(error);
		});
	}

	createTask()
	{
		this.isLoading = true;
		this.showErrorMessage = false;
		const taskDetails = {
			sobjectType: TASK_OBJECT_NAME.objectApiName,
			Subject: this.selectedSubject,
			Description: this.template.querySelector('[data-field=\'comment\']').value,
			ReminderDateTime: this.reminderTime,
			WhatId: this.recordId
		};

		createTask({taskDetail: taskDetails})
		.then((result) =>
		{
			if(result)
			{
				this.isLoading = false;
				this.dispatchEvent(new CloseActionScreenEvent());
				this.handleFlowFinishEvent();
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', 'Call Log Created successfully', 'success');
			}
		})
		.catch((error) =>
		{
			this.isLoading = false;
			this.showToastError(error);
		});
	}

	handleCancel()
	{
		this.dispatchEvent(new CloseActionScreenEvent());
		this.handleFlowFinishEvent();
	}

	handleFlowFinishEvent()
	{
		if(this.invokedFromFlow)
		{
			this.dispatchEvent(new FlowNavigationFinishEvent());
		}
	}
}