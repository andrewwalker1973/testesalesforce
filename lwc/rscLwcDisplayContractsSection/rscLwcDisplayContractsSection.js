/**
 * @description LWC component used to display Contracts to Link/Delink Policies
 *
 * @see @story 347193
 *
 * @author rajpal.singh@accenture.com, aakriti.a.goyal@accenture.com, aditya.kumar.nanda@accenture.com
 *
 * @date August 2022
 */
/*jshint esversion: 6 */

import getContractsFromAccount from '@salesforce/apex/RSC_CTRL_LinkContractsToCase.getContractsFromAccount';
import {api, LightningElement} from 'lwc';

const COLS = [

	{label: 'Policy Number', fieldName: 'policyNumber', type: 'text'},
	{label: 'Policy Type', fieldName: 'type', type: 'text'},
	{label: 'Product Type', fieldName: 'productType', type: 'text'},
	{label: 'Commencement Date', fieldName: 'commencementDate', type: 'text'},
	{label: 'Status', fieldName: 'status', type: 'text'},
	{label: 'Premium', fieldName: 'premium', type: 'decimal'},
	{label: 'Cessionary Name', fieldName: 'cessionaryName', type: 'text'},
	{label: 'Cessionary Type', fieldName: 'cessionaryType', type: 'text'}
];

export default class RscLwcDisplayContractsSection extends LightningElement
{

	@api recordId;
	@api iconName = 'standard:account';
	@api title = 'Policies to Link';
	@api clientId = null;

	contractList = [];
	cols = COLS;
	@api preSelectedRows;
	@api policyId = [];
	preSelected = [];
	@api preselectFetchedRows = false;

	/**
	 * @description method to fetch the latest Contracts for Client and Select Contracts related to the Case
	 */
	connectedCallback()
	{
		this.fetchContractsForClient();
	}

	/**
	 * @description getter method to get data table
	 */
	get dataTable()
	{
		return this.template.querySelector('lightning-datatable');
	}

	/**
	 * @description method to return the selected row data
	 */
	@api returnSelectedRowData()
	{
		//noinspection JSUnresolvedFunction
		return this.dataTable.getSelectedRows();
	}


	/**
	 * @description method to fetch Contracts for Clients and add the selected policies for a Case
	 */
	fetchContractsForClient()
	{
		getContractsFromAccount({parentRecordId: this.recordId, clientId: this.clientId})
		.then(({dtoContracts, selectedPolicyIds}) =>
		{
			this.contractList = dtoContracts;
			if(this.preSelectedRows)
			{
				this.preSelected = this.preSelectedRows;
			}
			else if(this.preselectFetchedRows)
			{
				let selectedPolicyIdsFromController = selectedPolicyIds ? [...selectedPolicyIds] : [];
				this.preSelected = selectedPolicyIdsFromController || [];
			}
		}).catch(error =>
		{
			this.showToastError(error.body.message);
		});
	}

	showToastError(message)
	{
		//noinspection JSUnresolvedFunction
		this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', message, 'error');
	}

}