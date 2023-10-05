import {sortBy} from 'c/cmnLwcUtil';
import {api, LightningElement} from 'lwc';

/**
 * @description Paginated Lightning Datatable
 * @event rowselection When a row is selected, this event emits all the rows selected across pages.
 * @event pagechange When the page is changed, this event emits the current page.
 * @event columnsort When the user clicks on the row sort button, this event emits the column's field name and sorting direction. Sorting is handled by the
 * parent component.
 */
export default class CmnLwcPaginatedTable extends LightningElement
{
	defaultSortDirection = 'asc';
	selectedRowsPerPage = {};
	page = 1;
	sortDirection;
	sortedBy;
	// List of Selected Row Ids
	allSelectedRows = [];

	errorMessage = '';
	/**
	 * @description Rows to display on the table. Uses the same form as lightning-datatable.
	 * @type {[]}
	 */
	@api rows = [];
	/**
	 * @description Table Title
	 * @type {string}
	 */
	@api title = '';
	/**
	 * @description Table column configuration. Uses the same form as lightning-datatable.
	 * @type {[]}
	 */
	@api columns = [];
	/**
	 * @description Decides how many results are displayed per page.
	 * @type {number}
	 */
	@api resultsPerPage = 10;

	get dataTable()
	{
		return this.template.querySelector('lightning-datatable');
	}

	get data()
	{
		let rows = [...this.rows].sort(sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1, null));
		const start = this.page === 1 ? 0 : this.page * this.resultsPerPage - 1;
		const end = start + this.resultsPerPage;
		return rows.slice(start, end);
	}

	get numberOfRows()
	{
		return this.rows.length;
	}

	get totalPages()
	{
		return Math.ceil(this.numberOfRows / this.resultsPerPage);
	}

	get showPagination()
	{
		return this.totalPages > 1;
	}

	/**
	 * @description Returns the current state of the table. Will only return which rows are visibly selected on the table. To see all rows selected across pages,
	 * listen for the 'rowselection' event.
	 * @returns {*[]}
	 */
	@api get selectedTableRows()
	{
		//noinspection JSUnresolvedVariable
		return this.dataTable ? this.dataTable.selectedRows : [];
	}

	/**
	 * @description Directly sets the table with a list of values
	 * @param value
	 */
	set selectedTableRows(value)
	{
		if(this.dataTable)
		{
			this.dataTable.selectedRows = [...value];
		}
	}

	get disablePreviousButton()
	{
		return this.page <= 1;
	}

	get disableNextButton()
	{
		return this.page >= this.totalPages;
	}

	/**
	 * @description Shows error message for table
	 * @param message
	 */
	@api showError(message)
	{
		let toast = this.template.querySelector('c-cmn-lwc-toast');
		if(toast)
		{
			//noinspection JSUnresolvedFunction
			toast.customNotification('Error', message, 'error');
		}
		else
		{
			console.error('Error:', message);
		}
	}

	/**
	 * @description Handles Previous page button click
	 */
	previousHandler()
	{
		this.page--;
		this.setPreselectedRows();
		this.dispatchPageChangeEvent();
	}

	/**
	 * @description Handles Next page button click
	 */
	nextHandler()
	{
		this.page++;
		this.setPreselectedRows();
		this.dispatchPageChangeEvent();
	}

	/**
	 * @description Emits an event requesting for the table data to be sorted. Sorting must be handled by the parent component, in order to support both client-
	 * side and server-side sorting.
	 * @param event
	 */
	sortColumns(event)
	{
		const {fieldName: sortedBy, sortDirection} = event.detail;
		this.sortedBy = sortedBy;
		this.sortDirection = sortDirection;
		this.dispatchEvent(new CustomEvent('columnsort', {detail: {sortedBy, sortDirection}}));
	}

	/**
	 * @description Dispatches a 'pagechange' event to alert the parent component that the page has changed.
	 */
	dispatchPageChangeEvent()
	{
		this.dispatchEvent(new CustomEvent('pagechange', {detail: {pageNumber: this.page}}));
	}

	/**
	 * @description Handles selection of rows across all pages. Saves it to a consolidated list across all pages.
	 */
	selectRows()
	{
		const rows = this.selectedTableRows;
		this.selectedRowsPerPage[this.page] = [...rows];
		let allRows = [];

		for(let key in this.selectedRowsPerPage)
		{
			if(this.selectedRowsPerPage[key])
			{
				allRows = allRows.concat(this.selectedRowsPerPage[key]);
			}
		}

		this.allSelectedRows = [...allRows];
		this.dispatchEvent(new CustomEvent('rowselection', {detail: {rows: allRows}}));
	}

	/**
	 * @description Sets the table rows to the currently selected rows. Used to re-render the table.
	 */
	setPreselectedRows()
	{
		this.template.querySelector('lightning-datatable').selectedRows = this.allSelectedRows;
	}
}