import {api, LightningElement} from 'lwc';

const ERROR_MESSAGE = 'Please select contracts for client policy print document(s)';

export const POLICY_NUMBER = 'policyNumber';
export const PRODUCT_TYPE = 'productType';
export const START_DATE = 'startDate';
export const STATUS = 'status';
export const CONTRIBUTION = 'contribution';
export const FREQUENCY = 'frequency';
export const PAID_TO_DATE = 'paidToDate';

const columns = [{
	label: 'Policy Number',
	fieldName: POLICY_NUMBER,
	type: 'text',
	sortable: true
},
	{
		label: 'Product Type',
		fieldName: PRODUCT_TYPE,
		type: 'text',
		sortable: false
	},
	{
		label: 'Policy Start Date',
		fieldName: START_DATE,
		type: 'date',
		sortable: false
	},
	{
		label: 'Status',
		fieldName: STATUS,
		type: 'text',
		sortable: true
	},
	{
		label: 'Contribution',
		fieldName: CONTRIBUTION,
		type: 'text',
		sortable: false
	},
	{
		label: 'Frequency',
		fieldName: FREQUENCY,
		type: 'text',
		sortable: false
	},
	{
		label: 'Paid To Date',
		fieldName: PAID_TO_DATE,
		type: 'date',
		sortable: false
	}
];

export default class RscLwcChooseCppPoliciesTable extends LightningElement
{
	@api policies = [];
	@api resultsPerPage = 10;

	sortDirection = 'asc';
	sortedBy = 'Name';
	selectedPoliciesFromTable = [];

	@api get selectedPolicies()
	{
		return this.selectedPoliciesFromTable;
	}

	get policyTableData()
	{
		return this.policies;
	}

	get policyTableColumns()
	{
		return columns;
	}

	saveSelectedRows(event)
	{
		this.selectedPoliciesFromTable = [...event.detail.rows];
	}

	@api showNoPoliciesSelectedError()
	{
		//noinspection JSUnresolvedFunction
		this.template.querySelector('c-cmn-lwc-paginated-table').showError(ERROR_MESSAGE);
	}
}