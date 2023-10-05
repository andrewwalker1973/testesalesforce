/**
 * @description LWC Component used to display the vaulted documents on Account from the DocumentCheckList Item.
 *
 * @author Futureform
 *
 * @see 
 *
 * @date October 2022
 */
import {api, LightningElement, track, wire} from 'lwc';
import {reduceErrors, sortBy} from 'c/cmnLwcUtil';
import uId from '@salesforce/user/Id';
import {refreshApex} from '@salesforce/apex';
import {NavigationMixin} from 'lightning/navigation';
import {getObjectInfo, getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';

import {loadStyle} from 'lightning/platformResourceLoader';
import slcLwcVaultedDocumentsAccountDatatableStyle from '@salesforce/resourceUrl/slcLwcVaultedDocumentsAccountDatatableStyle'

import DOCUMENT_CHECK_LIST_ITEM_OBJECT from '@salesforce/schema/DocumentChecklistItem';

import getAccountOptions from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getAccountOptions';
import getDocuments from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getDocuments';
import getOnboardingDocumentTypes from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getOnboardingDocumentTypes';
import getLegalSubtypes from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getLegalSubtypes';
import getLegalSubtypeOptions from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getLegalSubtypeOptions';
import getReportSubtypes from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getReportSubtypes';
import getReportSubtypeOptions from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getReportSubtypeOptions';
import getCommunicationSubtypes from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getCommunicationSubtypes';
import getCommunicationSubtypeOptions from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getCommunicationSubtypeOptions';
import getPresentationSubtypes from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getPresentationSubtypes';
import getPresentationSubtypeOptions from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getPresentationSubtypeOptions';
import deLinkDocumentItem from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.deLinkDocumentItem';
import saveRecord from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.saveRecord';
import getDocumentDownloadUrl from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getDocumentDownloadUrl';
import getVaultedDocuments from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getVaultedDocuments';
import getDocumentTypeByCode from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getDocumentTypeByCode';
import uploadDocuments from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.uploadDocuments';
import createContentVersion from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.createContentVersion';

import getDocumentDateTime from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getDocumentDateTime';
import getDocumentTypeByName from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getDocumentTypeByName';
import getDocumentTypeByIds from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getDocumentTypeByIds';
import getPortalUserDetails from '@salesforce/apex/SLC_CTRL_VaultedDocuments_Account.getPortalUserDetails';

import deleteMessage from '@salesforce/label/c.RSC_DeleteDocumentCheckListItem';
import validationMessage from '@salesforce/label/c.RSC_DocumentChecklistItemMandatoryMessage';
import selectReasonHeading from '@salesforce/label/c.RSC_DelinkDocumentsSelectReasonHeading';
import selectReasonInputHeading from '@salesforce/label/c.RSC_DelinkDocumentReasonInputHeading';
import createSuccessMessage from '@salesforce/label/c.RSC_DocumentChecklistItemSuccessMessage';
import updateSuccessMessage from '@salesforce/label/c.RSC_DocumentChecklistItemUpdateMessage';
import fileSizeLimitMessage from '@salesforce/label/c.RSC_FileSizeLimit';
import selectChecklistItemMessage from '@salesforce/label/c.RSC_SelectDocumentChecklistItem';
import deleteChecklistItemWarningMessage from '@salesforce/label/c.RSC_DeleteChecklistWarningMessage';
import currentDocumentMessage from '@salesforce/label/c.RSC_CurrentDocumentMessage';
import previewMessage from '@salesforce/label/c.RSC_PreviewMessage';
import warningHeaderMessage from '@salesforce/label/c.RSC_WarningHeader';
import documentsVaultedMessage from '@salesforce/label/c.RSC_AllDocumentsVaulted';
import documentTypeNotFoundMessage from '@salesforce/label/c.RSC_DocumentTypeNotFound';
import NoClientMessage from '@salesforce/label/c.RSC_NoClientData';
import NoClientDataMessage from '@salesforce/label/c.RSC_NoVaultedDocumentsForClient';
import spinnerMessage from '@salesforce/label/c.RSC_SpinnerContent';
import problemInFetchingMessage from '@salesforce/label/c.RSC_ProblemInFetchingDocuments';
import noFilesMessage from '@salesforce/label/c.RSC_NoFilesToDisplay';
import noDocumentsToLinkMessage from '@salesforce/label/c.RSC_NoDocumentsToLink';
import uploadFileMandatory from '@salesforce/label/c.RSC_UploadFile';
import reasonForRejectMandatory from '@salesforce/label/c.RSC_ReasonForRejectingDocumentMandatory';

import TIME_ZONE from '@salesforce/i18n/timeZone';

const MAX_FILE_SIZE = 300000000; //30mb
const recordTypeName = 'Case Document';
const RECORD_NAME = 'recordName';
const REJECTED = 'Rejected';
const ASC = 'asc';
const NAME = 'Name';
const MASTER_LABEL = 'MasterLabel';
const DEVELOPER_NAME = 'DeveloperName';
const NULL = null;
const ZERO = 0;
const BLANK = '';
const FALSE = false;
const TRUE = true;
const ACCEPTED_STATUS = 'Accepted';
const FUND_DOCS = 'Fund Documents';
const VAULTED_DOCUMENT_TABLE_DATA_ID = 'DocumentList';
const LEGAL_TYPE = 'Legal';
const REPORTS_TYPE = 'Reports';
const COMMUNICATION_TYPE = 'Communication';
const PRESENTATIONS_TYPE = 'Presentations';
const INSUFFICIENT_ACCESS = 'INSUFFICIENT_ACCESS';

//for the Opportunity record page level (insto client onboarding)
const onboardingColumns = [
	{
		label: 'Document Name', sortable: true, fieldName: 'recordName', type: 'url',
		typeAttributes: {label: {fieldName: 'Name'}, tooltip: 'Name', target: '_self'}
	},
	{
		label: 'Document Status', sortable: true, fieldName: 'Status'
	},
	{
		label: 'Document Type', sortable: true, fieldName: 'DocumentType.MasterLabel'
	},
	{
		label: 'Time of Upload',
		fieldName: 'AW_DateVaulted__c',
		type: 'date',
		typeAttributes: {
			year: 'numeric',
			month: 'short',
			day: 'numeric',
			hour: '2-digit',
			minute: '2-digit',
			second: '2-digit',
			hour12: false,
			timeZone: TIME_ZONE
		}
	},
	{
		label: 'Saved', fieldName: 'AW_Vaulted__c', type: 'boolean'
	},
	{
		label: 'Required?', fieldName: 'IsRequired', type: 'boolean'
	}
];

//for displaying Vaulted Docs from horizon system
const vaultedColumns = [
	{label: 'Document Type', sortable: true, fieldName: 'documentType', 
		cellAttributes:{
        	class:'datatable-doctype-CellColor slds-no-row-hover'
    	}
	},
	{label: 'Document Id', sortable: true, fieldName: 'documentId', 
		cellAttributes:{
        	class:'datatable-docid-CellColor slds-no-row-hover'
    	}
	},
	{label: 'Document Date', fieldName: 'documentDate', sortable: true, type: 'date',
		typeAttributes: {
			year: 'numeric',
			month: 'short',
			day: 'numeric'
		},
		cellAttributes:{
			class:'datatable-entrydate-CellColor slds-no-row-hover'
		}
	}
];
export default class slcLwcVaultedDocumentsAccount extends NavigationMixin(LightningElement){
    @track data;
    @track error;
	isCssLoaded = false;

	label =
		{
			deleteMessage,
			validationMessage,
			createSuccessMessage,
			updateSuccessMessage,
			fileSizeLimitMessage,
			selectChecklistItemMessage,
			deleteChecklistItemWarningMessage,
			currentDocumentMessage,
			previewMessage,
			warningHeaderMessage,
			selectReasonHeading,
			selectReasonInputHeading,
			documentsVaultedMessage,
			documentTypeNotFoundMessage,
			NoClientMessage,
			NoClientDataMessage,
			spinnerMessage,
			problemInFetchingMessage,
			noFilesMessage,
			noDocumentsToLinkMessage,
			uploadFileMandatory,
			reasonForRejectMandatory
		};
	onboardingColumns = onboardingColumns;
	vaultedColumns = vaultedColumns;
	deleteColumns = vaultedColumns;
	@api helpText = spinnerMessage;
	@api recordId;
	@api userUACF;
	@api createOrEditModal = false;
	@api isEdit = false;
	@api userId = uId;
	@api caseServiceType;
	@api currentListItemId;
	@api currentListItemName = '';
	@api currentListItemType;
	@api currentListItemTypeId;
	@api currentListItemStatus;
	@api currentListItemRequiredStatus;
	@api currentListItemReason;
	@api currentListItemTypeLabel;
	@api defaultRecordType;
	@api vaultedRecordType;
	@api statusValues;
	@api selectedStatus;
	@api selectedRowToDelete = new Map();
	@api uniqueSelectedRowToDelete = [];
	@api selectedCheckListItems = [];
	@api selectedItemsToDelete = [];
	@api recordsCount;
	@api baseUrl;
	@api documentResult = [];
	@api selectedDocumentCode;
	@api documentURL = [];
	@api vaultedDocumentToInsert = [];
	@api isCallUpload = false;
	@api isCallReclassify = false;
	@track newDocumentChecklistItemId = [];
	isConfirmation = false;
	isReasonSelection = false;
	isLink = false;
	isDelink = false;
	isSave = false;
	isPreview = false;
	isLoading = true;
	isLoadingReclassify = false;
	documentItemList = [];
	clientDocumentList = [];
	filteredDocumentList = [];
	onboardingDocumentTypes = [];
	refreshDocumentList = [];
	defaultSortDirection = ASC;
	sortDirection = ASC;
	sortedBy;
	@api uploadFileName;
	uploadedFiles = [];
	file;
	fileContents;
	fileReader;
	content;
	fileName;
	delinkReason;
	@api isUpload = false;
	@api documentItemId;
	@track showReason = false;
	@api documentRequired = false;
	@api documentRequiredUpdated = false;
	@api currentListItemDocumentCode;
	@api currentListItemVaulted;
	@api currentListItemVaultedDate;
	@api currentListItemVaultedId;
	existingListItemDocumentCode;
	onlyRequiredUpdated = false;
	replacedDocumentChecklistItem = {};
	callPostCaseComments = false;
	calledReclassify = false;

	@api docDateTime;
	@api internalVault;
	@api enableFilter;
	@api enableUpload;
	@api docTypesList;
	@api docTypesOptions = [];
	@api delinkDocTypesAllowed = '';
	@api externalVault;
	@api legalDocsTab;
	@api reportsTab;
	@api clientOnboarding;
	@api tabName;
	isFundDoc;
	legalSubtypes = [];
	reportSubtypes = [];
	communicationSubtypes = [];
	presentationSubtypes = [];
	pageNumber = 1;
	recordsPerPageOptions = [
		{label: '10', value: '10'},
		{label: '50', value: '50'},
		{label: '100', value: '100'},
		{label: '200', value: '200'},
		{label: 'All', value: 'All'}
	];
	recordsPerPage = this.recordsPerPageOptions[0].value;
	accountOptions = [];
	@api showAccountDropbox;
	legalSubtypeOptions;
	reportSubtypeOptions;
	communicationSubtypeOptions;
	presentationSubtypeOptions;
	documentTypeOption = '';

	get isLegalType(){
		return this.tabName === LEGAL_TYPE;
	}
	get isReportType(){
		return this.tabName === REPORTS_TYPE;
	}
	get isCommunicationType(){
		return this.tabName === COMMUNICATION_TYPE;
	}
	get isPresentationType(){
		return this.tabName === PRESENTATIONS_TYPE;
	}
	get documentsToDisplay() {
		if (!this.filteredDocumentList) {
			return [];
		}
		if (this.recordsPerPage === 'All') {
			return this.filteredDocumentList;
		}
		return this.filteredDocumentList.slice((this.pageNumber - 1) * this.recordsPerPage, this.pageNumber * this.recordsPerPage);
	}
	get pageCount() {
		if (this.recordsPerPage === 'All') {
			return 1;
		}
		return Math.ceil(this.filteredDocumentList?.length / this.recordsPerPage);
	}

	changeRecordPerPage(event) {
		this.recordsPerPage = event.target.value;
		this.pageNumber = 1;
	}

	get disablePrior() {
		return this.pageNumber === 1;
	}

	get disableNext() {
		return this.pageNumber === this.pageCount;
	}

    //loads upon init - appends 3 actions, calls getActions to see if we need to add Delete
	constructor()
	{
		super();

		this.columns = [...this.vaultedColumns,
			{
				type: 'action',
				typeAttributes: {rowActions: this.getActions},
				cellAttributes:{ class:'datatable-rowaction-CellColor slds-no-row-hover' }
			}
		];

		this.onboardingColumns = [...this.onboardingColumns,
			{
				type: 'action',
				typeAttributes: {rowActions: (row, doneCallBack) => {
						const actions = [];

						let code = row['DocumentType.Description'];
						let isExternal = this.onboardingDocumentTypes[code].Onboarding_Accessibility__c === 'External';

						if (row.AW_Vaulted__c) // check if there are file to download
						{
							actions.push({label: 'Download', name: 'download'},);
						}
						if (!this.externalVault || isExternal) // check if doc type external
						{
							actions.push({label: 'Upload', name: 'upload'});
						}

						doneCallBack(actions);
					}}
			}
		];
	}

    renderedCallback(){ 
		if(this.isCssLoaded){
            return
        } 
 
        this.isCssLoaded = true;
 
        loadStyle(this, slcLwcVaultedDocumentsAccountDatatableStyle)
		.then(() => {
            console.log("CSS Loaded Successfully")
        })
		.catch(error => { 
            console.log(error)
        });
    }

	connectedCallback(){
		//If lwc renders on Experience Cloud portal, recordId will be null so we must set it to the user's accountid
		if(this.externalVault){
			getPortalUserDetails({ userId : uId})
				.then(result => {
					this.recordId = result.AccountId;
					this.wireDocuments();
					this.getAccountDropdownOptions();
				})
				.catch(error => {
					this.error = error;
				})
		} else {
			this.externalVault = false;
			this.wireDocuments();
			this.getAccountDropdownOptions();
		}
	}

	//Retrieve all docs, get doc types from list of docs, pass these as the filterOptions
    get filterOptions(){
		if (!this.filteredDocumentList?.length) {
			return [];
		}

		return [
			{label: '--All--', value: ''},
			...[...new Set(this.filteredDocumentList.reduce((acc, cur) => {
				return [...acc, cur.documentType];
			}, []))].map(value => {
				return {label: value, value: value};
			})
		];
    }

	get delinkDocuments() {
		return this.documentItemList.filter(doc => this.delinkDocTypesAllowed.includes(doc.documentType));
	}
	getActions(row, doneCallBack)
	{
		const actions = [{label: 'Download', name: 'download'}];
		doneCallBack(actions);
	}

	@wire(getLegalSubtypeOptions, {})
	wireLegalSubtypeOptions({data, error}) {
		if (data) {
			this.legalSubtypeOptions = [
				{label: '--All--', value: ''},
				...data.map(option => {
					return {label: option, value: option};
				})
			];
		} else if (error) {
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	@wire(getReportSubtypeOptions, {})
	wireReportSubtypeOptions({data, error}) {
		if (data) {
			this.reportSubtypeOptions = [
				{label: '--All--', value: ''},
				...data.map(option => {
					return {label: option, value: option};
				})
			];
		} else if (error) {
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	@wire(getCommunicationSubtypeOptions, {})
	wireCommunicationSubtypeOptions({data, error}) {
		if (data) {
			this.communicationSubtypeOptions = [
				{label: '--All--', value: ''},
				...data.map(option => {
					return {label: option, value: option};
				})
			];
		} else if (error) {
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	@wire(getPresentationSubtypeOptions, {})
	wirePresentationSubtypeOptions({data, error}) {
		if (data) {
			this.presentationSubtypeOptions = [
				{label: '--All--', value: ''},
				...data.map(option => {
					return {label: option, value: option};
				})
			];
		} else if (error) {
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

    //get object info of document checklist item object
	@wire(getObjectInfo, {objectApiName: DOCUMENT_CHECK_LIST_ITEM_OBJECT})
	wireObjectInfo({data, error})
	{
		if(data)
		{
			this.defaultRecordType = data.defaultRecordTypeId;
			let recordTypeInfo = data.recordTypeInfos;
			for(let eachRecordtype in recordTypeInfo)
			{
				if(recordTypeInfo[eachRecordtype].name === recordTypeName) //case document
				{
					this.vaultedRecordType = recordTypeInfo[eachRecordtype].recordTypeId; //assigning recordtypeid of Case Document rt to then use in method below
					break;
				}

			}
		}
		else if(error)
		{
			let errorMessage = reduceErrors(error);
			if (error.body.errorCode !== INSUFFICIENT_ACCESS) {
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
			}
		}
	}

    //when click on 'New', this method gives us the 'Status' picklist on the screen
	@wire(getPicklistValuesByRecordType, {
		recordTypeId: '$vaultedRecordType',
		objectApiName: DOCUMENT_CHECK_LIST_ITEM_OBJECT
	})
	wireRecordtypeValues({data, error})
	{
		if(data)
		{
			this.statusValues = data.picklistFieldValues.Status.values;
			let options = [];
			if(this.statusValues)
			{
				for(let i = 0; i < this.statusValues.length; i++)
				{
					options.push({
						label: this.statusValues[i].label,
						value: this.statusValues[i].value
					});
				}
				this.statusValues = options;
			}
		}
		else if(error)
		{
			console.error(error);
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	@wire(getOnboardingDocumentTypes, {})
	wireOnboardingDocumentTypes({data, error}) {
		if (data) {
			this.onboardingDocumentTypes = data;
		} else if (error) {
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	@wire(getLegalSubtypes, {})
	wireLegalSubtypes({data, error}) {
		if (data) {
			this.legalSubtypes = data;
		} else if (error) {
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	@wire(getReportSubtypes, {})
	wireReportSubtypes({data, error}) {
		if (data) {
			this.reportSubtypes = data;
		} else if (error) {
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	@wire(getCommunicationSubtypes, {})
	wireCommunicationtSubtypes({data, error}) {
		if (data) {
			this.communicationSubtypes = data;
		} else if (error) {
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	@wire(getPresentationSubtypes, {})
	wirePresentationSubtypes({data, error}) {
		if (data) {
			this.presentationSubtypes = data;
		} else if (error) {
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		}
	}

	wireDocuments()
	{
		if (!this.recordId) {
			return;
		}
		this.isLoading = true;
		if (this.clientOnboarding) {
			getDocuments
			({
				recordId: this.recordId
			})
				.then(result => {
					let newDocumentList = [];

					if (result) {

						for (let row of result) {
							const flattenedRow = {};

							let rowKeys = Object.keys(row);

							rowKeys.forEach((rowKey) => {
								const singleNodeValue = row[rowKey];
								if (singleNodeValue.constructor === Object) {
									this.parse(singleNodeValue, flattenedRow, rowKey);
								} else {
									if (rowKey === NAME) {
										flattenedRow[RECORD_NAME] = '/' + row['Id'];
									}
									flattenedRow[rowKey] = singleNodeValue;
								}
							});
							newDocumentList.push(flattenedRow);
						}
					}

					this.documentItemList = [...newDocumentList];
					this.filteredDocumentList = newDocumentList;
					this.isLoading = false;
				})
				.catch(error => {
					this.isLoading = false;
					this.documentItemList = [];
					this.filteredDocumentList = [];
					let errorMessage = reduceErrors(error);
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
				});
		} else {
			getVaultedDocuments
			({
				recordId: this.recordId,
				tabTypes: this.tabName,
				isFundDoc: this.isFundDoc
			})
				.then(result => {
					this.documentItemList = [];

					if (result && result.callSuccessful && result.vaultedDocuments?.length) {
						this.documentItemList = [...result.vaultedDocuments];
					}

					this.filteredDocumentList = [...this.documentItemList];

					this.template.querySelectorAll('.subtype-filter').forEach(filter => filter.value = '');
					this.template.querySelectorAll('.document-type-filter').forEach(filter => filter.value = '');

					this.isLoading = false;
				})
				.catch(error => {
					this.isLoading = false;
					this.documentItemList = [];
					this.filteredDocumentList = [];
					let errorMessage = reduceErrors(error);
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
				});
		}

	}

	getAccountDropdownOptions(){
		if(!this.clientOnboarding){
			getAccountOptions({ recordId : this.recordId, isExternal : this.externalVault })
				.then(result => {
					this.accountOptions = [
						...Object.entries(result).map(([id, title]) => {
							return {label: title, value: title === FUND_DOCS ? FUND_DOCS : id};
						})
					];
					this.accountOptions.sort((a,b) => a.label > b.label ? 1 : -1);	
				})
				.catch(error => {
					let errorMessage = reduceErrors(error);
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');				
				})
		}
	}

	parse = (nodeValue, flattenedRow, nodeName) =>
	{
		let rowKeys = Object.keys(nodeValue);
		rowKeys.forEach((key) =>
		{
			let finalKey = nodeName + '.' + key; //acknowledging dot notation is returned: case.docchecklistitem.name
			flattenedRow[finalKey] = nodeValue[key];
			if(key === MASTER_LABEL)
			{
				flattenedRow[MASTER_LABEL] = nodeValue[key];
			}
			if(key === DEVELOPER_NAME)
			{
				flattenedRow[DEVELOPER_NAME] = nodeValue[key];
			}
		});
	};

	priorPage() {
		this.pageNumber -= 1;
	}

	nextPage() {
		this.pageNumber += 1;
	}

	handleChangePage(event) {
		this.pageNumber = event.target.value;
	}

	handleChangeAccount(event) {
		if (event.target.value === FUND_DOCS) {
			this.isFundDoc = true;
		} else {
			this.recordId = event.target.value;
			this.isFundDoc = false;
		}
		this.wireDocuments();
	}

	handleLegalSubtype(event) {
		if (!this.documentItemList?.length) {
			return;
		}
		this.pageNumber = 1;
		let documentType = event.detail.value;
		this.filteredDocumentList = this.documentItemList.filter(item => (item?.documentTypeCode &&  this.legalSubtypes[item.documentTypeCode] === event.detail.value) || !documentType);
		this.template.querySelectorAll('.document-type-filter').forEach(filter => filter.value = '');
	}

	handleReportSubtype(event) {
		if (!this.documentItemList?.length) {
			return;
		}
		this.pageNumber = 1;
		let documentType = event.detail.value;
		this.filteredDocumentList = this.documentItemList.filter(item => (item?.documentTypeCode && this.reportSubtypes[item.documentTypeCode] === event.detail.value) || !documentType);
		this.template.querySelectorAll('.document-type-filter').forEach(filter => filter.value = '');
	}

	handleCommunicationSubtype(event) {
		if (!this.documentItemList?.length) {
			return;
		}
		this.pageNumber = 1;
		let documentType = event.detail.value;
		this.filteredDocumentList = this.documentItemList.filter(item => (item?.documentTypeCode && this.communicationSubtypes[item.documentTypeCode] === event.detail.value) || !documentType);
		this.template.querySelectorAll('.document-type-filter').forEach(filter => filter.value = '');
	}

	handlePresentationSubtype(event) {
		if (!this.documentItemList?.length) {
			return;
		}
		this.pageNumber = 1;
		let documentType = event.detail.value;
		this.filteredDocumentList = this.documentItemList.filter(item => (item?.documentTypeCode && this.presentationSubtypes[item.documentTypeCode] === event.detail.value) || !documentType);
		this.template.querySelectorAll('.document-type-filter').forEach(filter => filter.value = '');
	}

    //functions to invoke each row action
	handleRowAction(event)
	{
		const actionName = event.detail.action.name;
		const row = event.detail.row;
		switch(actionName)
		{
			case 'upload':
				this.handleDocumentUpload(row);
				break;
			case 'download':
				this.handleDownload(row);
				break;
		}
	}

    //sorts each column by clicking on column header
	handleOnSort(event)
	{
		// const {fieldName: sortedBy, sortDirection} = event.detail;

		this.sortDirection = event.detail.sortDirection;
		this.sortedBy = event.detail.fieldName;

		let cloneData = [...this.filteredDocumentList];
		cloneData.sort(sortBy(this.sortedBy === RECORD_NAME ? NAME : this.sortedBy, this.sortDirection === ASC ? 1 : -1));

		this.filteredDocumentList = cloneData;
	}

    //event to handle when user changes Status picklist
	handleStatusChange(event)
	{
		this.selectedStatus = event.detail.value;
		this.currentListItemStatus = this.selectedStatus;
		this.showReason = this.currentListItemStatus === REJECTED; //if Status = rejected, show new 'Reason' field, else don't render this field
	}

    //when we check a document for 'Delink', this method is invoked
    //create a set to store the document checklist item id and another list to store the entire document records
    //we pass the id to apex to delink the record from the document
    //we need the entire records to display them in the 'Warning' table before you delink
	handleSelection(event)
	{
		const selectedRows = event.detail.selectedRows;
		this.recordsCount = event.detail.selectedRows.length;
		let uniqueChecklistId = new Set();
		for(let i = 0; i < selectedRows.length; i++)
		{
			uniqueChecklistId.add(selectedRows[i].documentId); //unique set of ids
		}
		this.selectedCheckListItems = Array.from(uniqueChecklistId);
		this.selectedItemsToDelete = selectedRows; //entire records
	}

    //whenever we click on 'Link', the selected documents are handled with this method
	handleVaultedSelection(event)
	{
		const selectedRows = event.detail.selectedRows;
		this.handleGetDocumentCode(selectedRows);
	}

    //edge case - checks if doc code is present in SF
    //if it is present, user can proceed, else error is thrown and user cant continue
	handleGetDocumentCode(selectedRows)
	{
		this.vaultedDocumentToInsert = [];
		let codeMap = new Map();
		let documentsMap = new Map();
		let codeList = [];
		let duplicateList = [];
		let listToInsert = [];
		for(let i = 0; i < selectedRows.length; i++)
		{
			codeList.push('DocumentCode_' + selectedRows[i].sourceId);
		}

		getDocumentTypeByCode
		({
			documentCodes: codeList
		})
		.then(result =>
		{
			console.log('getDocumentTypeByCode')
			for(let key in result)
			{
				let code = result[key].DeveloperName;
				code = code.replace('DocumentCode_', BLANK);
				codeMap.set(code, result[key].Id);
			}

			for(let j = selectedRows.length - 1; j >= ZERO; j--)
			{
				for(let k = 0; k < this.documentResult.length; k++)
				{
					let docCode = this.documentResult[k].DocumentType.DeveloperName;
					docCode = docCode.replace('DocumentCode_', BLANK);
					if(selectedRows[j] && (selectedRows[j].sourceId === docCode) && this.documentResult[k].AW_Vaulted__c === FALSE) // && this.documentResult[k].IsRequired == true
					{
						documentsMap.set(selectedRows[j].sourceId, this.documentResult[k].Id);
					}
				}
			}
			for(let i = 0; i < selectedRows.length; i++)
			{
				let documentChecklistItem = {'sobjectType': DOCUMENT_CHECK_LIST_ITEM_OBJECT.objectApiName};
				documentChecklistItem.Name = selectedRows[i].documentType;
				if(documentsMap.get(selectedRows[i].sourceId) !== undefined && !duplicateList.includes(selectedRows[i].sourceId))
				{
					documentChecklistItem.Id = documentsMap.get(selectedRows[i].sourceId);
					duplicateList.push(selectedRows[i].sourceId);
				}
				else
				{
					documentChecklistItem.Id = null;
				}
				documentChecklistItem.ParentRecordId = this.recordId;
				documentChecklistItem.Status = 'New';
				documentChecklistItem.DocumentTypeId = codeMap.get(selectedRows[i].sourceId);

				if(documentChecklistItem.DocumentTypeId === undefined)
				{
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', documentTypeNotFoundMessage, 'error');
					break;
				}
				documentChecklistItem.CMN_VaultedId__c = selectedRows[i].documentId;
				documentChecklistItem.AW_Vaulted__c = true;
				let dateTime = new Date(selectedRows[i].entryDate);
				documentChecklistItem.AW_DateVaulted__c = dateTime;

				listToInsert.push(documentChecklistItem);
			}

			this.vaultedDocumentToInsert = listToInsert;
		})
		.catch(error =>
		{
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		});
	}

	//delink modal
	handleDelink(){
		this.isDelink = true;
	}

    //enter Reason as to why you are delinking a document
	handleReasonSelection()
	{ 
		if(this.selectedCheckListItems.length === ZERO)
		{
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', selectChecklistItemMessage, 'error');
		}
		else
		{
			let delinkAllowList = this.delinkDocTypesAllowed;
			const delinkArray = delinkAllowList.split(",");
			let typeListAllowed = [];
			let typeListUnallowed = [];
			let delinkUnAllowedError = false;
	
			//get Document Types by their child checklist item ids
			getDocumentTypeByIds({ checklistIds : this.selectedCheckListItems })
			.then(result => {
				for(var i=0; i<result.length; i++){
					if(delinkArray.includes(result[i].MasterLabel)){
						typeListAllowed.push(result[i].MasterLabel);
					} else {
						typeListUnallowed.push(result[i].MasterLabel);
						delinkUnAllowedError = true;
					}
				}
				if(delinkUnAllowedError){
					let delinkUnAllowedErrorMessage = 'You do not have permission to delink the selected Document Types: ' + typeListUnallowed.join(', ');
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', delinkUnAllowedErrorMessage, 'error');
				} else { 
					this.isDelink = false;
					this.isReasonSelection = true; //based on this, the 'Provide a Reason' model popup will be visible on html
				}
			})
			.catch(error =>	{
					let errorMessage = reduceErrors(error);
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
			});		
		}
	}

    //to display the confirmation 'warning!' screen before you delink
	handleConfirmation()
	{
		this.delinkReason = this.template.querySelector('[data-field=\'delink-reason\']').value;
		const allValid = [...this.template.querySelectorAll('[data-field=\'delink-reason\']')]
		.reduce((validSoFar, inputFields) =>
		{
			inputFields.reportValidity();
			return validSoFar && inputFields.checkValidity(); //validate whether Reason is filled out, if not then throw error
		}, true);

		if(allValid) //if validity passed
		{
			this.isReasonSelection = false; //reason screen disappeared
			this.isConfirmation = true; //show confirmation screen
		}
		else
		{
			this.template.querySelector('c-cmn-lwc-toast').requiredFieldsNotification();
		}
	}

    //when you click Confirm that you want to delink the documents, this method is called
	handleDelete()
	{
		this.isConfirmation = false;
		this.isLoading = true;
		deLinkDocumentItem({
			documentIds: this.selectedCheckListItems,
			recordId: this.recordId,
			deLinkReason: this.delinkReason
		}) //pass doc ids and delink reason to apxc
		.then((result) =>
		{
			if(result === 'Success')
			{
				this.isLoading = false;
				this.template.querySelector('lightning-datatable').selectedRows = []; //empty the list post deletion of records
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', this.recordsCount + ' ' + deleteMessage, 'success');
				this.selectedCheckListItems = []; //if success, document delinked, and commemt posted to Case Comment section
			}
			else
			{
				this.isLoading = false;
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', result, 'error');
			}
			this.wireDocuments(); // refresh the list on deleting a record
		})
		.catch(error =>
		{
			this.isLoading = false;
			let errorMessage = reduceErrors(error);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		});
	}

	handleTypeChange(event)
	{
		this.existingListItemDocumentCode = event.target.value;
		if(this.existingListItemDocumentCode !== undefined && this.existingListItemDocumentCode !== BLANK)
		{
			this.handleGetDocumentType(this.existingListItemDocumentCode);
		}
	}

	handleGetDocumentType(docCode)
	{		
		getDocumentTypeByCode({ documentCodes: docCode })
		.then(result => {
			this.currentListItemName = result[0].MasterLabel;
			this.currentListItemTypeId = result[0].Id;
		})
		.catch(error =>
			{
				let errorMessage = reduceErrors(error);
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
			});
	}

	handleNew()
	{
		this.isLoading = true;
		this.isEdit = false;
		this.createOrEditModal = true;
		this.currentListItemId = BLANK;    // reset record details to null for new records
		this.currentListItemName = BLANK;
		this.currentListItemType = BLANK;
		this.currentListItemStatus = 'New';
		this.currentListItemReason = BLANK;
		this.showReason = false;
		this.isLoading = this.handleTime();
		this.isCallReclassify = false;
		this.handleDocTypesField();
		return refreshApex(this.refreshDocumentList); // refresh the list on deleting a record
	}

	handleDocTypesField(){
		let typeList = this.docTypesList;
		const typeArray = typeList.split(",");

		getDocumentTypeByName({ masterLabels : typeArray })
		.then(result => {
			let typeArray = [];
			for(var i=0; i<result.length; i++){
				typeArray.push(
					{ label: result[i].MasterLabel, value: result[i].DeveloperName }
				);
			}
			this.docTypesOptions = typeArray;
		})
		.catch(error =>
			{
				let errorMessage = reduceErrors(error);
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
			});
	}

	handleFileUpload(event)
	{
		if(event.target.files.length > ZERO)
		{
			this.uploadedFiles = event.target.files;
			this.fileName = event.target.files[0].name;
			this.uploadFileName = this.fileName;
			this.file = this.uploadedFiles[0];
			if(this.file.size > this.MAX_FILE_SIZE)
			{
				this.template.querySelector('c-cmn-lwc-toast').customNotification(fileSizeLimitMessage, MAX_FILE_SIZE, 'error');
			}
		}
	}

	handleFilterDocuments(event) //filters to show only the documents that by document type
	{
		this.pageNumber = 1;
		let documentType = event.detail.value;
		this.filteredDocumentList = this.documentItemList.filter(item => item.documentType === documentType || !documentType);
	}

	//new/upload or reclassify is only one doc at a time
    //link can be multiple documents
    //handleSave is a common save method for all 3 situations
	handleSave(){

		this.isLoading = true;
		if(this.uploadedFiles.length !== ZERO)
		{
			this.fileReader = new FileReader();
			this.fileReader.onloadend = (() =>
			{
				this.fileContents = this.fileReader.result;
				let base64 = 'base64,';
				this.content = this.fileContents.indexOf(base64) + base64.length;
				this.fileContents = this.fileContents.substring(this.content);
				this.isCallUpload = true;
				this.handleSaveRecord();
			});
			this.fileReader.readAsDataURL(this.file);
		}
		else
		{
			//only when Required value is changed under Edit action
			if(this.documentRequiredUpdated)
			{
                //when you edit a doc check item, you cannot change the Required checkbox
                //can only change this when you create new one - or delete a document and recreate it
                //this method handles this 
				this.handleSaveOnRequiredUpdated();
			}
			else
			{
				this.handleSaveRecord();
			}
		}

	}

	handleSaveRecord(){ //this part performs the actual DML operation to insert into Salesforce Files 
		console.log('handleSaveRecord')
		this.isSave = false;
		if(this.isLink) {
			this.isLoading = true;
			this.currentListItemId = NULL;
			this.fileContents = BLANK;
			this.fileName = BLANK;
			this.isSave = true;
			this.handleFinalSave();
		} else if(this.template.querySelector('[data-field=\'current-listitem-name\']').value !== BLANK && this.currentListItemTypeId !== BLANK){
			let singleListToInsert = [];
			let pushDataToSave = false;

			if(this.currentListItemId === BLANK)
			{
				//new doc from new button
				this.currentListItemId = NULL;
				//required true for new items created by default
				this.documentRequired = true;
			}

			getDocumentDateTime({ docDate : this.template.querySelector('[data-field=\'documentdate-input\']').value})
			.then(result => {
				this.docDateTime = result;

				let documentChecklistItem = {
						'sobjectType': DOCUMENT_CHECK_LIST_ITEM_OBJECT.objectApiName,
						'Name': this.template.querySelector('[data-field=\'current-listitem-name\']').value,
						'Id': this.currentListItemId,
						'ParentRecordId': this.recordId,
						'Status': this.currentListItemStatus,
						'IsRequired': this.documentRequired,
						'DocumentTypeId': this.currentListItemTypeId,
						'AW_DateVaulted__c': this.docDateTime
					};
				
					console.log(documentChecklistItem);
				if(this.currentListItemStatus !== REJECTED) {
					documentChecklistItem['CMN_Reason__c'] = BLANK;
					pushDataToSave = true;
				} else if(this.currentListItemStatus === REJECTED && this.template.querySelector('[data-field=\'current-listitem-reason\']').value.trim()) {
					documentChecklistItem['CMN_Reason__c'] = this.template.querySelector('[data-field=\'current-listitem-reason\']').value.trim();
					pushDataToSave = true;
				} else {
					this.isLoading = false;
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', reasonForRejectMandatory, 'error');
				}

				if(pushDataToSave) {
					singleListToInsert.push(documentChecklistItem);
					this.vaultedDocumentToInsert = singleListToInsert;
					this.isSave = true;

					if(this.isSave && this.isCallReclassify === FALSE)
					{
						this.handleFinalSave();
						this.isCallReclassify = true;
					}
					else
					{
						this.isLoadingReclassify = true;
					}
				}
		})
		.catch(error =>{
				console.log(error)
		})
		} else {
			this.isLoading = false;
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', validationMessage, 'error');
		}


	}

	handleFinalSave()
	{
		this.isLoading = true;

		if(this.vaultedDocumentToInsert.length > ZERO)
		{
            //invokes apxc
			saveRecord
			({
				checklistItems: this.vaultedDocumentToInsert, //list of doc check items to insert
				file: encodeURIComponent(this.fileContents),
				fileName: this.fileName
			})
			.then(result =>
			{
				if(result)
				{
					this.newDocumentChecklistItemId = result;

					this.handleClose();
					if(this.currentListItemId === NULL && this.isCallUpload === FALSE)
					{
						this.isCallReclassify = false;
						this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', createSuccessMessage, 'success');
					}
					else if(this.currentListItemId !== NULL && this.isCallReclassify === TRUE)
					{
						this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', updateSuccessMessage, 'success');
					}

					this.fileName = BLANK;
					this.uploadFileName = BLANK;
					this.uploadedFiles = [];
					this.vaultedDocumentToInsert = [];
					this.documentRequired = false;
					if(this.isCallUpload)
					{
						this.handleUpload(this.newDocumentChecklistItemId);
					}

					this.handleCloseLink();
					this.isLoadingReclassify = false;
				}
			})
			.catch(error =>
			{
				console.log('saveRecord')
				console.log(error)
				this.isLoading = false;
				this.isLoadingReclassify = false;
				let errorMessage = reduceErrors(error);
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
			});
		}
		else
		{
			this.isLoading = false;
			this.isLoadingReclassify = false;
			if(this.isLink)
			{
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', noDocumentsToLinkMessage, 'error');
			}
		}

	}

    /** didnt cover any of these functions in the video session **/
	handleDocumentUpload(rowToUpload)
	{
		this.isUpload = true;
		this.documentItemId = rowToUpload.Id;
	}

	handleFetchFiles()
	{
		console.log('handleFetchFiles')
		this.isLoading = true;
		if(this.uploadedFiles.length !== ZERO)
		{
			let reader = new FileReader();
			let fileContents;
			let contentData;
			reader.onloadend = (() =>
			{
				fileContents = reader.result;
				let base64 = 'base64,';
				contentData = fileContents.indexOf(base64) + base64.length;
				fileContents = fileContents.substring(contentData);
				this.handleCreateContentDocument(this.file, fileContents);
			});
			reader.readAsDataURL(this.file);
		}
		else
		{
			this.isLoading = false;
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', uploadFileMandatory, 'error');
		}
	}

	handleCreateContentDocument(file, fileContents)
	{
		console.log('handleCreateContentDocument')
		createContentVersion
		({
			documentCheckListId: this.documentItemId,
			file: encodeURIComponent(fileContents),
			fileName: this.fileName
		})
		.then(result =>
		{
			if(result)
			{
				this.handleUpload(this.documentItemId);
				return refreshApex(this.refreshDocumentList);
			}
		})
		.catch(error =>
		{
			console.log(error)
			this.isLoading = false;
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', error, 'error');
		});
	}

	handleUpload(documentId)
	{
		console.log('handleUpload')
		uploadDocuments
		({
			documentCheckList: documentId
		})
		.then(uploadResult =>
		{
			if(uploadResult)
			{
				this.isLoading = false;
				if(uploadResult.callSuccessful)
				{
					this.handleClose();
					this.handleUploadClose();
					this.isCallUpload = false;
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', uploadResult.callMessage, 'success');
					this.wireDocuments();
				}
				else
				{
					this.isLoading = false;
					this.handleClose();
					this.handleUploadClose();
					this.isCallUpload = false;
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', uploadResult.callMessage, 'error');
				}
			}
		})
		.catch(uploadError =>
		{
			this.isLoading = false;
			this.isCallUpload = false;
			let errorMessage = reduceErrors(uploadError);
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
		});
	}

	handleDownload(rowToPreview)
	{
		this.isLoading = true;
		getDocumentDownloadUrl
		({
			recordId: this.clientOnboarding ? rowToPreview.Id : this.recordId,
			vaultedId: this.clientOnboarding ? rowToPreview.CMN_VaultedId__c : rowToPreview.documentId,
			isExternal: this.externalVault
		})
			.then((result) =>
			{
				this.isLoading = false;

				this[NavigationMixin.Navigate]({
						type: 'standard__webPage',
						attributes: {
							url: result,
						}
					});
			})
			.catch(error =>
			{
				this.isLoading = false;
				let errorMessage = reduceErrors(error);
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', errorMessage, 'error');
			});
	}

	handleClose()
	{
		this.createOrEditModal = false;
		this.fileName = BLANK;
		this.file = BLANK;
		this.uploadFileName = BLANK;
		this.uploadedFiles = [];
		this.isUpload = false;
	}

	handleCloseDelink(){
		this.isDelink = false;
	}

	handleCloseConfirmation()
	{
		this.isConfirmation = false;
		this.isReasonSelection = false;
	}

	handleCloseLink()
	{
		this.isLink = false;
		this.isLoading = false;
	}

	handleClosePreview()
	{
		this.documentURL = []; //clearing the url list on close
		this.isPreview = false;
	}

	handleTime()
	{
		setInterval(function()
		{
			this.isLoading = false;
		}.bind(this), 5000);
		return this.isLoading;
	}

	handleUploadClose()
	{
		this.fileName = BLANK;
		this.file = BLANK;
		this.uploadFileName = BLANK;
		this.uploadedFiles = [];
		this.isUpload = false;
	}

	/**
	 * @description Method invoked on change of Required checkbox
	 */
	handleRequired(event)
	{
		this.documentRequired = event.target.checked;
		this.documentRequiredUpdated = true;
	}

	/**
	 * @description Method invoked when the required checkbox has been updated under Edit action, when the required checkbox has been updated
	 */
	handleSaveOnRequiredUpdated()
	{
		console.log('handleSaveOnRequiredUpdated')
		this.isSave = false;

		if(this.template.querySelector('[data-field=\'current-listitem-name\']').value !== BLANK && this.template.querySelector(
			'[data-field=\'current-listitem-type\']').value !== NULL)
		{
			let newDocumentChecklistItemCreated =
				{
					'sobjectType': DOCUMENT_CHECK_LIST_ITEM_OBJECT.objectApiName,
					'Name': this.template.querySelector('[data-field=\'current-listitem-name\']').value,
					'ParentRecordId': this.recordId,
					'Status': this.currentListItemStatus,
					'IsRequired': this.documentRequired,
					'DocumentTypeId': this.template.querySelector('[data-field=\'current-listitem-type\']').value,
					'AW_Vaulted__c': this.currentListItemVaulted,
					'AW_DateVaulted__c': this.currentListItemVaultedDate,
					'CMN_VaultedId__c': this.currentListItemVaultedId
				};

			this.replacedDocumentChecklistItem = newDocumentChecklistItemCreated;

			this.handleReasonForStatus(newDocumentChecklistItemCreated);
		}
		else
		{
			this.isLoading = false;
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', validationMessage, 'error');
		}
	}

	/**
	 * @description Method to display the and make the Reason field mandatory when Status = Rejected
	 * @param checklistItem
	 */
	handleReasonForStatus(checklistItem)
	{
		if(this.currentListItemStatus !== REJECTED)
		{
			checklistItem['CMN_Reason__c'] = BLANK;
		}
		else if(this.currentListItemStatus === REJECTED && this.template.querySelector('[data-field=\'current-listitem-reason\']').value.trim())
		{
			checklistItem['CMN_Reason__c'] = this.template.querySelector('[data-field=\'current-listitem-reason\']').value.trim();
		}
		else
		{
			this.isLoading = false;
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', reasonForRejectMandatory, 'error');
		}
	}
}