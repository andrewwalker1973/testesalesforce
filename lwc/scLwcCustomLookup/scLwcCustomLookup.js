/**
 * @description JavaScript to handle events of rscLwcServiceTypeSelector component
 * Generic component to be used to select a lookup value for a given object.
 *
 * @author Accenture
 *
 * @date June 2021
 */
import fetchLookupRecords from '@salesforce/apex/SC_CTRL_CustomLookup.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/SC_CTRL_CustomLookup.fetchDefaultRecord';
import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

const DELAY = 300; // delay apex callout timing in milliseconds
export default class ScCustomLookup extends LightningElement
{
	@api label;
	@api placeholder = 'Search';
	@api sObjectApiName;
	@api sobjectFieldName;
	@api defaultRecordId;
	@api filterCriteria;
	@api enforceFilterCriteria = false; //No lookup results will be displayed if filter criteria is not selected & this flag is set as true

	sobjectRecords = [];
	hasRecords = true;
	searchKey='';
	isSearchLoading = false;
	delayTimeout;
	selectedRecord = {};
	error;
	@api themeInfo;


    // function to populate default selected lookup record if defaultRecordId provided
	@wire(fetchDefaultRecord,
		{
			recordId: '$defaultRecordId',
			searchField: '$sobjectFieldName'
		})
	wiredDefault({ error, data })
	{
		if (data)
		{
			let tempRecord = Object.assign({}, data);
			if(tempRecord[this.sobjectFieldName] != undefined && tempRecord[this.sobjectFieldName] != null)
			{
				tempRecord = {
				   Id: tempRecord['Id'],
				   Name: tempRecord[this.sobjectFieldName]
				}
			}
			this.error = undefined;
			this.selectedRecord = tempRecord;
			this.handleSelectRecordHelper();
		}
		else if (error)
        {
			this.error = error;
			this.selectedRecord = {};
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', error.body.message, 'error');
		}
	}

	// wire function property to search records based on user input
	@wire(fetchLookupRecords,
		{
			searchTerm: '$searchKey',
			sObjectName: '$sObjectApiName',
			searchField: '$sobjectFieldName',
			filterCriteria: '$filterCriteria'
		})
 	searchResult(value)
	{
		const { data, error } = value;
		this.isSearchLoading = false;
		if (data)
		{
		    if(this.enforceFilterCriteria && (this.filterCriteria == null || this.filterCriteria == undefined || this.filterCriteria == ''))
		    {
		        // Do nothing since filter criteria is not provided
		    }
			else
			{
				 this.hasRecords = data.length == 0 ? false : true;
				 var tempRecordList = [];
				 for (var i = 0; i < data.length; i++)
				 {
					let tempRecord = Object.assign({}, data[i]);
					if(tempRecord[this.sobjectFieldName] != undefined && tempRecord[this.sobjectFieldName] != null)
					{
						let recordObject = {
						   Id: tempRecord['Id'],
						   Name: tempRecord[this.sobjectFieldName]
						}
						tempRecordList.push(recordObject);
					}
				}
				this.sobjectRecords = tempRecordList;
				this.error = undefined;
			}
		 }
		 else if (error) {
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', error.body.message, 'error');
		 }
	};

	// function will be called from parent to update selected service type
	@api updateSelectedRecord(){
		this.handleRemove();
  	}

	@wire(getObjectInfo, { objectApiName: "$sObjectApiName" })
	handleObjectResult({error, data})
	{
		if(data)
		{
		    let objectInformation = data;
			this.themeInfo = data.themeInfo || {};
			this.placeholder += ' ' + (objectInformation && objectInformation.labelPlural ?
                                objectInformation.labelPlural + '...' : '');
            this.label = objectInformation.label;
		}
		if(error)
		{
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', error.body.message, 'error');
		}
	}

  	// function to update searchKey property on input field change
	handleKeyChange(event)
	{
		// Debouncing this method: Do not update the reactive property as long as this function is
		// being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
		this.isSearchLoading = true;
		window.clearTimeout(this.delayTimeout);
		const searchKey = event.target.value;
		this.delayTimeout = setTimeout(() => {
			this.searchKey = searchKey;
		}, DELAY);
	}

	// method to toggle lookup result section on UI
	toggleResult(event)
	{
		const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
		const clsList = lookupInputContainer.classList;
		const whichEvent = event.target.getAttribute('data-source');
		switch(whichEvent)
		{
			case 'searchInputField':
				clsList.add('slds-is-open');
			   break;
			case 'lookupContainer':
				clsList.remove('slds-is-open');
			break;
	   	}
	}

	// method to clear selected lookup record
	handleRemove()
	{
		this.searchKey = '';
		this.selectedRecord = {};
		this.lookupUpdateHandler(undefined);

		// remove selected pill and display input field again
		const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
		searchBoxWrapper.classList.remove('slds-hide');
		searchBoxWrapper.classList.add('slds-show');
		const pillDiv = this.template.querySelector('.pillDiv');
		pillDiv.classList.remove('slds-show');
		pillDiv.classList.add('slds-hide');

		const oEvent = new CustomEvent('lookupupdate',
			{
				'detail': {selectedRecord: null}
			}
		);
		this.dispatchEvent(oEvent);
	}

  	// method to update selected record from search result
	handleSelectedRecord(event)
	{
		// get selected record Id
		var objId = event.target.getAttribute('data-recid');

		// find selected record from list
		this.selectedRecord = this.sobjectRecords.find(data => data.Id === objId);

		// update value on parent component as well from helper function
		this.lookupUpdateHandler(this.selectedRecord);

		// helper function to show/hide lookup result container on UI
		this.handleSelectRecordHelper();
	}

 	// helper function to show/hide lookup result container on UI
	handleSelectRecordHelper()
	{
		this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
		const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
		searchBoxWrapper.classList.remove('slds-show');
		searchBoxWrapper.classList.add('slds-hide');
		const pillDiv = this.template.querySelector('.pillDiv');
		pillDiv.classList.remove('slds-hide');
		pillDiv.classList.add('slds-show');
	}

	// send selected lookup record to parent component using custom event
	lookupUpdateHandler(value)
	{
	    if(value != undefined)
	    {
			const oEvent = new CustomEvent('lookupupdate',
				{
					'detail': {selectedRecord: value}
				}
			);
			this.dispatchEvent(oEvent);
		}
	}

	 get iconColor() {
		let color = "background-color: " +
			(this.themeInfo && this.themeInfo.color ?
				("#" + this.themeInfo.color) : "") +
			";";
		return color;
	}
}