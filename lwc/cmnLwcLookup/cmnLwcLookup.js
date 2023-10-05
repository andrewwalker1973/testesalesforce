/**
 * @description Common component to provide a lookup search on SObject
 *
 * @author aakriti.a.goyal@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date January 2022, June 2023
 */
import findById from '@salesforce/apex/CMN_CTRL_Lookup.findById';
import lookUp from '@salesforce/apex/CMN_CTRL_Lookup.findSObjectBySearchTerm';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {api, LightningElement, wire} from 'lwc';

const DELAY = 300; // delay apex callout timing in milliseconds
const DOWN_KEY = 40;
const ENTER_KEY = 13;
const ESCAPE_KEY = 27;
const MINIMUM_INPUT_CHARACTERS_TO_SEARCH = 3;
const NUMBER_OF_SHOWN_RESULTS = 20;
const SEARCH_RESULT_INITIAL_INDEX = -1;
const UP_KEY = 38;

export default class CmnLwcLookup extends LightningElement
{
	preselectedRecordId;
	/**
	 * @description SObject API Name
	 * @type {string}
	 */
	@api objectName;
	/**
	 * @description Provide a custom label that overrides the default field Label
	 */
	@api fieldLabelName;
	@api readOnly = false;
	/**
	 * @description Field API Name
	 * @type {string}
	 */
	@api fieldApiName;
	/**
	 * @description Provide a custom placeholder text for lookup search
	 * @type {string}
	 */
	@api placeholder = 'Search';
	/**
	 * @description Comma seperated list of field API names e.g. 'FirstName,LastName'
	 * @type {string}
	 */
	@api displayFields = 'Name';
	/**
	 * @description Format for lookup item display e.g. 'Mr. LastName'
	 * @type {string}
	 */
	@api displayFormat;
	/**
	 * @description SLDS Icon name for result items
	 * @type {string} slds-icon name
	 * @see https://www.lightningdesignsystem.com/icons/
	 */
	@api iconName;
	@api isRequired = false;
	@wire(getObjectInfo, {objectApiName: '$objectName'})
	objectInfo;
	searchOptions = [];
	searchTerm = '';
	isSearchLoading = false;
	/**
	 * @description Class variable to store record
	 * @type {{Id, Name}}
	 */
	record;
	hasRecords = false;
	currentFocusedSearchOption = SEARCH_RESULT_INITIAL_INDEX;

	//noinspection JSUnusedGlobalSymbols
	get defaultRecordId()
	{
		return this.preselectedRecordId;
	}

	/**
	 * @description Record Id passed in to preselect lookup field
	 */
	@api set defaultRecordId(value)
	{
		this.preselectedRecordId = value;
		if(!value)
		{
			this.handleRemove();
		}
	}

	get fieldLabelClass()
	{
		return this.isRequired ? 'slds-form-element__label required-field' : 'slds-form-element__label';
	}

	get selectedRecord()
	{
		return this.record;
	}

	set selectedRecord(value)
	{
		this.record = value;
		this.preselectedRecordId = Boolean(this.selectedRecord) ? this.preselectedRecordId : undefined;
		this.dispatchValueSelectEvent(this.record ? this.record.Id : '', this.fieldApiName);
		if(value)
		{
			this.handleSelectRecordHelper();
		}
	}

	/**
	 * @see findDefaultRecordById
	 * @returns {string} SObject record Id
	 */
	get recordId()
	{
		return this.selectedRecord ? this.selectedRecord.Id : this.preselectedRecordId;
	}

	get icon()
	{
		return this.objectInfo && this.objectInfo.data && this.objectInfo.custom ? this.iconName || '' : `standard:${this.objectName.toLowerCase()}`;
	}

	get pillLabel()
	{
		return this.selectedRecord ? this.generateRecordLabel(this.selectedRecord) : '';
	}

	get displayFieldFormat()
	{
		return this.displayFormat || this.displayFields.split(',')[0];
	}

	get lookupInputContainerClassList()
	{
		return this.template.querySelector('.lookupInputContainer').classList;
	}

	/**
	 * wired method to get the SObject records based on provided search term
	 **/
	@wire(lookUp, {
		searchTerm: '$searchTerm', objectName: '$objectName', selectFields: '$displayFields', maximumNumberOfResults: NUMBER_OF_SHOWN_RESULTS
	}) wiredRecords({error, data})
	{
		this.isSearchLoading = false;
		if(data)
		{
			this.currentFocusedSearchOption = SEARCH_RESULT_INITIAL_INDEX;
			this.searchOptions = [...data]
			.map(item =>
			{
				let option = {...item};
				option.label = this.generateRecordLabel(option);
				return option;
			});

			this.hasRecords = this.searchOptions.length > 0;
			if(this.searchTerm)
			{
				this.showResults();
				this.selectSearchOptionUI();
			}
		}
		else if(error)
		{
			this.isSearchLoading = false;
			this.hasRecords = false;
			this.searchOptions = [];
			console.error(error.body.message);
		}
	}

	@wire(findById, {recordId: '$recordId', objectName: '$objectName', selectFields: '$displayFields'})
	findDefaultRecordById({error, data})
	{
		if(data)
		{
			this.selectedRecord = data;
		}
		else if(error)
		{
			this.showErrorToast(error.body.message);
		}

	}

	generateRecordLabel(record)
	{
		let label = this.displayFieldFormat;
		this.displayFields.split(',').forEach(originalField =>
		{
			let field = originalField.trim();
			let value = record[field];
			label = value ? label.replace(field, value) : label.replace(field, '');
		});
		return label;
	}

	dispatchValueSelectEvent = (selectedId, key) => this.dispatchEvent(new CustomEvent('valueselect', {detail: {selectedId, key}}));

	//noinspection JSUnresolvedFunction
	showErrorToast = (message = '', header = 'Error') =>
		this.template.querySelector('c-cmn-lwc-toast').customNotification(header, message, 'error');

	/**
	 * Function to call the wire method based on provided search term and show the searched results on the UI
	 **/
	handleKeyChange(event)
	{
		// Debouncing this method: Do not update the reactive property as long as this function is
		// being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
		this.isSearchLoading = true;
		window.clearTimeout(this.delayTimeout);
		const searchKey = event.target.value;
		if(searchKey.length >= MINIMUM_INPUT_CHARACTERS_TO_SEARCH)
		{
			this.delayTimeout = setTimeout(() =>
			{
				this.searchTerm = searchKey;
			}, DELAY);
		}
		else if(!searchKey)
		{
			this.hideResults();
			this.isSearchLoading = false;
			this.hasRecords = false;
		}
		else if(searchKey.length < MINIMUM_INPUT_CHARACTERS_TO_SEARCH)
		{
			this.isSearchLoading = false;
			this.searchOptions = [];
			this.hasRecords = false;
			this.showResults();
		}
	}

	showResults()
	{
		const classList = this.lookupInputContainerClassList;
		classList.add('slds-is-open');
	}

	hideResults()
	{
		const classList = this.lookupInputContainerClassList;
		classList.remove('slds-is-open');
	}

	handleRemove()
	{
		this.searchTerm = '';
		this.selectedRecord = undefined;

		// remove selected pill and display input field again
		//noinspection DuplicatedCode
		const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
		if(searchBoxWrapper)
		{
			searchBoxWrapper.classList.remove('slds-hide');
			searchBoxWrapper.classList.add('slds-show');
		}
		const pillDiv = this.template.querySelector('.pillDiv');
		if(pillDiv)
		{
			pillDiv.classList.remove('slds-show');
			pillDiv.classList.add('slds-hide');
		}
	}

	handleSelectedRecord({target})
	{
		const objId = target.getAttribute('data-recid');
		this.selectedRecord = this.searchOptions.find(option => option.Id === objId);
	}

	// helper function to show/hide lookup result container on UI
	//noinspection DuplicatedCode
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

	handleKeyDown(event)
	{
		let keyCode = event.keyCode;
		switch(keyCode)
		{
			case ESCAPE_KEY:
				event.preventDefault();
				this.hideResults();
				break;
			case ENTER_KEY:
				event.preventDefault();
				this.selectedRecord = this.searchOptions[this.currentFocusedSearchOption];
				break;
			case UP_KEY:
				event.preventDefault();
				this.previousSearchResult();
				this.selectSearchOptionUI();
				break;

			case DOWN_KEY:
				event.preventDefault();
				this.nextSearchResult();
				this.selectSearchOptionUI();
				break;

			default:
				break;
		}
	}

	nextSearchResult()
	{
		if(this.currentFocusedSearchOption < this.searchOptions.length)
		{
			this.currentFocusedSearchOption += 1;
		}
	}

	previousSearchResult()
	{
		if(this.currentFocusedSearchOption > 0)
		{
			this.currentFocusedSearchOption -= 1;
		}
	}

	selectSearchOptionUI()
	{
		const searchOptions = this.template.querySelectorAll('.search-options');
		searchOptions.forEach((element, index) =>
		{
			element.classList.remove('search-option-selected');
			if(this.currentFocusedSearchOption === index)
			{
				element.classList.add('search-option-selected');
			}
		});
	}
}