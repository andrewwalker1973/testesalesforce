/**
 * @description Lightning web component is used to update policies linked to case
 *
 * @author Accenture
 *
 * @date August 2021
 */
import {refreshApex} from '@salesforce/apex';
import getContractFromCase from '@salesforce/apex/RSC_CTRL_LinkContractsToCase.getContractFromCase';
import updateContracts from '@salesforce/apex/RSC_CTRL_LinkContractsToCase.updateContracts';
import {reduceErrors, sortBy} from 'c/cmnLwcUtil';
import {NavigationMixin} from 'lightning/navigation';
import {api, LightningElement, wire} from 'lwc';

const UPDATE_SUCCESS_MESSAGE = 'Contracts linked successfully';
const columns = [
	{
		label: 'Policy Number',
		sortable: true,
		fieldName: 'recordName',
		type: 'url',
		typeAttributes: {label: {fieldName: 'SC_PolicyNumber__c'}, target: '_self'}
	},
	{label: 'Policy Type', sortable: true, fieldName: 'SC_PolicyType__c'},
	{label: 'Product Type', sortable: true, fieldName: 'SC_ProductType__c'},
	{label: 'Status', fieldName: 'SC_Status__c'},
	{label: 'Commencement Date', fieldName: 'SC_CommencementDate__c'},
	{label: 'Premium', fieldName: 'SC_Premium__c'},
	{
		type: 'button', fieldName: 'recordId', typeAttributes: {
			label: 'View', variant: 'brand'
		}

	}
];

export default class RscLwcDisplayContracts extends NavigationMixin(LightningElement)
{
	@api recordId;
	@api caseId;
	@api isUpdateContracts = false;
	@api preSelectedRowsForChildComp;
	isRefreshContractCompFromApex;
	@api selectedRowData;
	refreshContractList = [];
	columns = columns;
	contractList = [];
	isLoading;

	@wire(getContractFromCase, {parentRecordId: '$recordId'}) getContractFromCase(result)
	{
		this.caseId = this.recordId;
		this.refreshContractList = result;
		if(result.data)
		{
			this.isLoading = false;
			const data = result.data;
			const newContractList = [];

			for(let row of data)
			{
				const flattenedRow = {};
				let rowKeys = Object.keys(row);

				rowKeys.forEach((rowKey) =>
				{
					const singleNodeValue = row[rowKey];
					if(singleNodeValue.constructor === Object)
					{
						this.flatten(singleNodeValue, flattenedRow, rowKey);
					}
					else
					{
						if(rowKey === 'Name')
						{
							if(row['SC_PolicyType__c'] === 'Risk Product')
							{
								flattenedRow['recordName'] = '/' + row['SC_InsurancePolicy__c'];
							}
							else if(row['SC_PolicyType__c'] === 'Investment Product')
							{
								flattenedRow['recordName'] = '/' + row['SC_FinancialAccount__c'];
							}
						}
						else if(rowKey === 'Id')
						{
							flattenedRow['recordId'] = '/' + row['Id'];
						}
						flattenedRow[rowKey] = singleNodeValue;
					}
				});
				newContractList.push(flattenedRow);
			}
			this.contractList = newContractList;

		}
		else if(result.error)
		{
			this.isLoading = false;
			this.contractList = [];
			const errorMessage = reduceErrors(result.error).join(' // ');
			//noinspection JSUnresolvedFunction
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	flatten = (nodeValue, flattenedRow, nodeName) =>
	{
		let rowKeys = Object.keys(nodeValue);
		rowKeys.forEach((key) =>
		{
			let finalKey = nodeName + '.' + key;
			flattenedRow[finalKey] = nodeValue[key];
		});
	};

	handleUpdate()
	{
		this.isUpdateContracts = true;
		this.isRefreshContractCompFromApex = true;
	}

	handleSave()
	{
		const contractElement = this.template.querySelector('c-rsc-lwc-display-contracts-section');
		//noinspection JSUnresolvedFunction
		this.selectedRowData = contractElement ? contractElement.returnSelectedRowData() : undefined;
		let selectedRowDataContract = [];
		for(let rowData of this.selectedRowData)
		{
			selectedRowDataContract.push(rowData.id);
		}

		updateContracts({
			parentId: this.caseId, selectedPolicyIds: selectedRowDataContract
		})
		.then(async() =>
		{
			this.isLoading = false;
			//noinspection JSUnresolvedFunction
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', UPDATE_SUCCESS_MESSAGE, 'Success');
			this.isUpdateContracts = false;
			this.isRefreshContractCompFromApex = true;
			this.template.querySelector('c-rsc-lwc-display-contracts-section').preSelected = [...selectedRowDataContract];
			await refreshApex(this.refreshContractList);
		})
		.catch(error =>
		{
			this.isLoading = false;
			//noinspection JSUnresolvedFunction
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', error.body.message, 'error');
		});
	}

	handleCancel()
	{
		this.isUpdateContracts = false;
		this.isRefreshContractCompFromApex = false;
	}

	handleOnSort(event)
	{
		const {fieldName: sortedBy, sortDirection} = event.detail;
		let cloneData;

		cloneData = [...this.contractList];
		cloneData.sort(sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1, null));

		this.contractList = cloneData;
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;
	}

	handleOnRowAction(event)
	{
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage', attributes: {
				recordId: event.detail.row.Id, objectApiName: 'SC_AssociatedContract__c', actionName: 'view'
			}
		});
	}
}