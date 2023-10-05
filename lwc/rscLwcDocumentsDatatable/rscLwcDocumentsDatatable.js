/**
 * @description LWC component for displaying the datatable for outstanding documents to be used in the flow
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date September 2021
 */
import {LightningElement, api} from 'lwc';

export default class RscLwcDocumentsDatatable extends LightningElement
{
	@api sObjectName;
	@api records;
	columns = [
		{label: 'Name', fieldName: 'Name'},
		{label: 'Status', fieldName: 'Status'},
		{label: 'Reason', fieldName: 'CMN_Reason__c'}
	];
}