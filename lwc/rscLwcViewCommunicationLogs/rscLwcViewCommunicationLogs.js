//noinspection CssInvalidHtmlTagReference

/**
 * @description LWC Component that fetches the communication logs on the Case records that are associated to Account
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @see storyNo: #259693
 *
 * @date February 2022
 */
import getCases from '@salesforce/apex/RSC_CTRL_ViewCommunicationLogs.getCases';
import getCommunicationLogs from '@salesforce/apex/RSC_CTRL_ViewCommunicationLogs.getCommunicationLogs';
import NAME_FIELD from '@salesforce/schema/CMN_CommunicationLog__c.Name';
import STATUS_FIELD from '@salesforce/schema/CMN_CommunicationLog__c.CMN_Status__c';
import REQUESTED_DOCUMENTS_FIELD from '@salesforce/schema/CMN_CommunicationLog__c.CMN_RequestedDocuments__c';
import CASE_FIELD from '@salesforce/schema/CMN_CommunicationLog__c.Case__c';
import TEMPLATE_FIELD from '@salesforce/schema/CMN_CommunicationLog__c.CMN_CommunicationTemplate__c';
import LOG_ID_FIELD from '@salesforce/schema/CMN_CommunicationLog__c.Id';

import spinnerMessage from '@salesforce/label/c.RSC_SpinnerContent';

import {api, LightningElement, wire} from 'lwc';
import {reduceErrors, sortBy} from 'c/cmnLwcUtil';

const columns = [
	{
		label: 'Log Number', fieldName: 'CommunicationLogRecord', type: 'url',
		typeAttributes: {label: {fieldName: 'Name'}, tooltip: 'Log Number', target: '_self'}
	},
	{
		label: 'Case', fieldName: 'CaseRecord', type: 'url',
		typeAttributes: {label: {fieldName: 'CaseNumber'}, tooltip: 'CaseNumber', target: '_self'}
	},
	{label: 'Template', fieldName: 'CommunicationTemplateName'},
	{label: 'Status', fieldName: 'CMN_Status__c'},
	{label: 'Requested Documents', fieldName: 'CMN_RequestedDocuments__c', type: 'boolean'}
];

export default class RscLwcViewCommunicationLogs extends LightningElement
{

	label =
			{
				spinnerMessage
			};

	@api recordId;

	columns = columns;
	foundCasesOnAccount = [];
	foundCaseIds = [];
	foundCommunicationLogs = [];
	sortDirection = 'asc';
	sortBy = 'Name';
	isLoading = true;
	helpText = spinnerMessage;

	/**
	 * @description method will return the list of communication log records on the Cases in sorted order
	 *
	 */
	get displayCommunicationLogs()
	{
		const reverse = this.sortDirection === 'asc' ? 1 : -1;
		return this.foundCommunicationLogs ?
			   this.foundCommunicationLogs.map(communicationLog => ({
					   Id: communicationLog.Id,
					   Name: communicationLog[NAME_FIELD.fieldApiName],
					   CMN_RequestedDocuments__c: communicationLog[REQUESTED_DOCUMENTS_FIELD.fieldApiName],
					   CaseNumber: (communicationLog['Case__r'] || '') && (communicationLog['Case__r']['CaseNumber'] || ''),
					   CommunicationTemplateName: (communicationLog['CMN_CommunicationTemplate__r'] || '') && (communicationLog['CMN_CommunicationTemplate__r']['Name'] || ''),
					   CMN_Status__c: communicationLog[STATUS_FIELD.fieldApiName],
					   Case__c: communicationLog[CASE_FIELD.fieldApiName],
					   CMN_CommunicationTemplate__c: communicationLog[TEMPLATE_FIELD.fieldApiName],
					   CommunicationLogRecord: '/' + communicationLog[LOG_ID_FIELD.fieldApiName],
					   CaseRecord: '/' + communicationLog[CASE_FIELD.fieldApiName]
				   }))
				   .sort(sortBy(this.sortBy, reverse, '')) : [];
	}

	//noinspection JSUnresolvedFunction
	/**
	 * @description Show toast Error notification
	 * @param errorMessage Message to be displayed
	 * @param header Error header
	 * @returns {*}
	 */
	showToastError = (errorMessage, header = 'Error') =>
			this.template.querySelector('c-cmn-lwc-toast').customNotification(header, errorMessage, 'error');

	/**
	 * @description method is invoked onload of the component to get all the Cases related to Account
	 *
	 */
	@wire(getCases, {accountId: '$recordId'})
	getCases(result)
	{
		if(result.data)
		{
			this.foundCasesOnAccount = result.data;
			this.foundCasesOnAccount.forEach(val => this.foundCaseIds.push(val.Id));
			if(this.foundCasesOnAccount)
			{
				this.getCommunicationLogsOnCases();
			}
		}
		else if(result.error)
		{
			this.isLoading = false;
			let errorMessage = reduceErrors(result.error).join(' // ');
			this.showToastError(errorMessage);
		}
	}

	/**
	 * @description method return all the communication log records for the given caseId's else logs an error message
	 *
	 */
	getCommunicationLogsOnCases()
	{
		getCommunicationLogs
		({
			caseIds: this.foundCaseIds
		})
		.then((result) =>
		{
			this.isLoading = false;
			this.foundCommunicationLogs = result;
		})
		.catch(error =>
		{
			this.isLoading = false;
			let errorMessage = reduceErrors(error).join(' // ');
			this.showToastError(errorMessage);
		});
	}
}