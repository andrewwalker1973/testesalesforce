//noinspection DuplicatedCode
/**
 * @description LWC Component used to display the vaulted documents from the DocumentCheckList Item.
 *
 * @author jayanth.kumar.s@accenture.com aakriti.a.goyal@accenture.com
 *
 * @see storyNo: 146010
 *
 * @date January 2023
 */

import {refreshApex} from '@salesforce/apex';
import deleteNonVaultedDocuments from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.deleteNonVaultedDocuments';
import deLinkDocumentItem from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.deLinkDocumentItem';
import getContentDocument from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.getContentDocument';
import uploadDocuments from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.uploadDocuments';

import getDocuments from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.getDocuments';
import getDocumentType from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.getDocumentType';
import getDocumentTypeByCode from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.getDocumentTypeByCode';
import getVaultedDocuments from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.getVaultedDocuments';
import postCaseComments from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.postCaseComments';
import reclassifyDocuments from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.reclassifyDocuments';
import replaceDocumentChecklist from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.replaceDocumentChecklist';
import saveRecord from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.saveRecord';

import TIME_ZONE from '@salesforce/i18n/timeZone';
import documentsVaultedMessage from '@salesforce/label/c.RSC_AllDocumentsVaulted';
import currentDocumentMessage from '@salesforce/label/c.RSC_CurrentDocumentMessage';
import deleteChecklistItemWarningMessage from '@salesforce/label/c.RSC_DeleteChecklistWarningMessage';

import deleteMessage from '@salesforce/label/c.RSC_DeleteDocumentCheckListItem';
import selectReasonInputHeading from '@salesforce/label/c.RSC_DelinkDocumentReasonInputHeading';
import delinkDocumentsErrorMessage from '@salesforce/label/c.RSC_DelinkDocumentsErrorMessage';
import selectReasonHeading from '@salesforce/label/c.RSC_DelinkDocumentsSelectReasonHeading';
import validationMessage from '@salesforce/label/c.RSC_DocumentChecklistItemMandatoryMessage';
import createSuccessMessage from '@salesforce/label/c.RSC_DocumentChecklistItemSuccessMessage';
import updateSuccessMessage from '@salesforce/label/c.RSC_DocumentChecklistItemUpdateMessage';
import documentTypeNotFoundMessage from '@salesforce/label/c.RSC_DocumentTypeNotFound';
import fileSizeLimitMessage from '@salesforce/label/c.RSC_FileSizeLimit';
import NoClientMessage from '@salesforce/label/c.RSC_NoClientData';
import noDocumentsToLinkMessage from '@salesforce/label/c.RSC_NoDocumentsToLink';
import noFilesMessage from '@salesforce/label/c.RSC_NoFilesToDisplay';
import NoClientDataMessage from '@salesforce/label/c.RSC_NoVaultedDocumentsForClient';
import previewMessage from '@salesforce/label/c.RSC_PreviewMessage';
import problemInFetchingMessage from '@salesforce/label/c.RSC_ProblemInFetchingDocuments';
import reasonForRejectMandatory from '@salesforce/label/c.RSC_ReasonForRejectingDocumentMandatory';
import selectChecklistItemMessage from '@salesforce/label/c.RSC_SelectDocumentChecklistItem';
import spinnerMessage from '@salesforce/label/c.RSC_SpinnerContent';
import uploadFileMandatory from '@salesforce/label/c.RSC_UploadFile';
import warningHeaderMessage from '@salesforce/label/c.RSC_WarningHeader';

import ACCOUNT_ID_FIELD from '@salesforce/schema/Case.AccountId';
import SERVICE_TYPE_ID_FIELD from '@salesforce/schema/Case.RSC_ServiceType__c';

import DOCUMENT_CHECK_LIST_ITEM_OBJECT from '@salesforce/schema/DocumentChecklistItem';
import uId from '@salesforce/user/Id';
import {reduceErrors, sortBy} from 'c/cmnLwcUtil';
import {NavigationMixin} from 'lightning/navigation';
import {getObjectInfo, getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import {getFieldValue, getRecord} from 'lightning/uiRecordApi';
import {api, LightningElement, track, wire} from 'lwc';

const recordTypeName = 'Case Document';
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
const VAULTED_DOCUMENT_TABLE_DATA_ID = 'DocumentList';

const rowActions = [
	{label: 'Edit', name: 'edit'},
	{label: 'View', name: 'view'},
	{label: 'Upload', name: 'upload'}
];

const acceptedFormats = [
	'.pdf'
];

const columns = [
	{
		label: 'Document Name', sortable: true, fieldName: 'recordName', type: 'url', typeAttributes: {label: {fieldName: 'Name'}, tooltip: 'Name', target: '_self'}
	},
	{
		label: 'Document Status', sortable: true, fieldName: 'Status'
	},
	{
		label: 'Document Type', sortable: true, fieldName: 'DocumentType.MasterLabel'
	},
	{
		label: 'Document Vaulted Time', fieldName: 'AW_DateVaulted__c', type: 'date', typeAttributes: {
			year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false, timeZone: TIME_ZONE
		}
	},
	{
		label: 'Vaulted?', fieldName: 'AW_Vaulted__c', type: 'boolean'
	},
	{
		label: 'Required?', fieldName: 'IsRequired', type: 'boolean'
	}
];

const vaultedColumns = [
	{label: 'Document Type', sortable: true, fieldName: 'documentType'},
	{label: 'Document Id', sortable: true, fieldName: 'documentId'},
	{label: 'Entry Date', fieldName: 'entryDate'},
	{label: 'Source Id', fieldName: 'sourceId'}
];

const deleteColumns = [
	{label: 'Document Name', fieldName: 'Name'},
	{label: 'Document Status', fieldName: 'Status'},
	{label: 'Document Type', fieldName: 'DocumentType.MasterLabel'},
	{
		label: 'Document Vaulted Time', fieldName: 'AW_DateVaulted__c', type: 'date', typeAttributes: {
			year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false, timeZone: TIME_ZONE
		}
	}
];

export default class RscLwcVaultedDocuments extends NavigationMixin(LightningElement)
{
	label = {
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
	columns = columns;
	acceptedFormats = acceptedFormats;
	vaultedColumns = vaultedColumns;
	deleteColumns = deleteColumns;
	@api helpText = spinnerMessage;
	@api recordId;
	@api userUACF;
	@api createOrEditModal = false;
	@api isEdit = false;
	@api userId = uId;
	@api caseAccount;
	@api caseServiceType;
	@api currentListItemId;
	@api currentListItemName;
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
	isSave = false;
	isLoading = true;
	isLoadingReclassify = false;
	@track documentItemList = [];
	clientDocumentList = [];
	filteredDocumentList = [];
	refreshDocumentList = [];
	defaultSortDirection = ASC;
	sortDirection = ASC;
	sortedBy;
	uploadedFiles = [];
	file;
	fileContents;
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
	isFileUploaded = false;
	isNew = false;

	/**
	 * @description method to display the toast message using the common toast
	 */
	showToastError = (errorMessage, header = 'Error') => this.template.querySelector('c-cmn-lwc-toast').customNotification(header, errorMessage, 'error');

	constructor()
	{
		super();
		this.columns = [
			...this.columns,
			{
				type: 'action', typeAttributes: {rowActions: this.getActions}
			}
		];
	}

	/**
	 * @description Method used to add the row actions dynamically based on specific conditions
	 *
	 * @return A List of selected documents
	 **/

	@api get selectedDocuments()
	{
		let table;
		this.template.querySelectorAll('lightning-datatable').forEach(tableElement =>
		{
			let id = tableElement.getAttribute('data-id') || '';
			if(id === VAULTED_DOCUMENT_TABLE_DATA_ID)
			{
				table = tableElement;
			}
		});
		return this.documentItemList.filter(document => table.selectedRows.includes(document.Id));
	}

	/**
	 * @description Getter method to verify if the documentItemList contains any document record
	 *
	 * @return If the length of the list is > 0 it returns true else false
	 */
	@api get isDocumentItemListPresent()
	{
		return this.documentItemList.length > 0;
	}

	/**
	 * @description Getter method to verify if the status of all the documents is Accepted
	 *
	 * @return If the status of all the documents is Accepted it returns true else false
	 */
	@api get isAllDocumentStatusAccepted()
	{
		return this.documentItemList.length > 0 && !this.documentItemList.some(document => document.Status !== ACCEPTED_STATUS);
	}

	/**
	 * @description Getter method to verify if the status of all the documents that are Required is Accepted
	 *
	 * @return If the status of all the documents that are Required is Accepted it returns true else false
	 */
	@api get isAllRequiredDocumentStatusAccepted()
	{
		return this.documentItemList.length > 0 && !this.documentItemList.filter(document => document.IsRequired)
		.some(document => document.Status !== ACCEPTED_STATUS);
	}

	getActions(row, doneCallBack)
	{
		const actions = [...rowActions];
		if(row.AW_Vaulted__c !== TRUE)
		{
			actions.push({label: 'Delete', name: 'delete'});
		}
		doneCallBack(actions);
	}

	/**
	 * @description function is used to get the information of Document Checklist Item object
	 *
	 * @param objectApiName Name of the Document Checklist Item object
	 */
	@wire(getObjectInfo, {objectApiName: DOCUMENT_CHECK_LIST_ITEM_OBJECT}) wiredObjectInfo({data, error})
	{
		if(data)
		{
			this.defaultRecordType = data.defaultRecordTypeId;
			let recordTypeInfo = data.recordTypeInfos;
			for(let eachRecordtype in recordTypeInfo)
			{
				if(recordTypeInfo[eachRecordtype].name === recordTypeName)
				{
					this.vaultedRecordType = recordTypeInfo[eachRecordtype].recordTypeId;
					break;
				}
			}
		}
		else if(error)
		{
			this.showToastError(reduceErrors(error));
		}
	}

	/**
	 * @description function is used to return the picklist values for the provided object and record type
	 *
	 */
	@wire(getPicklistValuesByRecordType, {
		recordTypeId: '$vaultedRecordType', objectApiName: DOCUMENT_CHECK_LIST_ITEM_OBJECT
	}) wiredRecordtypeValues({data, error})
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
						label: this.statusValues[i].label, value: this.statusValues[i].value
					});
				}
				this.statusValues = options;
			}
		}
		else if(error)
		{
			this.showToastError(reduceErrors(error));
		}
	}

	@wire(getRecord, {
		recordId: '$recordId', fields: [
			ACCOUNT_ID_FIELD,
			SERVICE_TYPE_ID_FIELD
		]
	}) wiredCase({error, data})
	{
		if(data)
		{
			this.caseAccount = getFieldValue(data, ACCOUNT_ID_FIELD);
			this.caseServiceType = getFieldValue(data, SERVICE_TYPE_ID_FIELD);
		}
		else if(error)
		{
			this.showToastError(reduceErrors(error.body.message));
		}
	}

	@wire(getDocuments, {recordId: '$recordId'}) getDocuments(result)
	{
		this.refreshDocumentList = result;
		if(result.data)
		{
			this.isLoading = false;
			let data = result.data;
			let newDocumentList = [];

			for(let row of data)
			{
				const flattenedRow = {};

				let rowKeys = Object.keys(row);

				rowKeys.forEach((rowKey) =>
				{
					const singleNodeValue = row[rowKey];
					if(singleNodeValue.constructor === Object)
					{
						this.parse(singleNodeValue, flattenedRow, rowKey);
					}
					else
					{
						if(rowKey === NAME)
						{
							flattenedRow['recordName'] = '/' + row['Id'];
						}
						flattenedRow[rowKey] = singleNodeValue;
					}
				});
				newDocumentList.push(flattenedRow);
			}
			this.documentItemList = newDocumentList;
		}
		else if(result.error)
		{
			this.isLoading = false;
			this.documentItemList = [];
			this.showToastError(reduceErrors(result.error));
		}
	}

	parse = (nodeValue, flattenedRow, nodeName) =>
	{
		let rowKeys = Object.keys(nodeValue);
		rowKeys.forEach((key) =>
		{
			let finalKey = nodeName + '.' + key;
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

	handleRowAction(event)
	{
		const actionName = event.detail.action.name;
		const row = event.detail.row;
		switch(actionName)
		{
			case 'edit':
				this.handleEdit(row);
				break;
			case 'view':
				this.handleView(row);
				break;
			case 'upload':
				this.handleDocumentUpload(row);
				break;
			case 'delete':
				this.handleDeleteNonVaultedDocument(row);
				break;
		}
	}

	handleOnSort(event)
	{
		const {fieldName: sortedBy, sortDirection} = event.detail;
		let cloneData;
		if(this.isLink)
		{
			cloneData = [...this.filteredDocumentList];
		}
		else
		{
			cloneData = [...this.documentItemList];
		}
		cloneData.sort(sortBy(sortedBy, sortDirection === ASC ? 1 : -1, ''));
		if(this.isLink)
		{
			this.filteredDocumentList = cloneData;
		}
		else
		{
			this.documentItemList = cloneData;
		}
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;
	}

	handleStatusChange(event)
	{
		this.selectedStatus = event.detail.value;
		this.currentListItemStatus = this.selectedStatus;
		this.showReason = this.currentListItemStatus === REJECTED;
	}

	handleSelection(event)
	{
		const selectedRows = event.detail.selectedRows;
		this.recordsCount = event.detail.selectedRows.length;
		let uniqueChecklistId = new Set();
		for(let i = 0; i < selectedRows.length; i++)
		{
			uniqueChecklistId.add(selectedRows[i].Id);
		}
		this.selectedCheckListItems = Array.from(uniqueChecklistId);
		this.selectedItemsToDelete = selectedRows;
	}

	handleVaultedSelection(event)
	{
		const selectedRows = event.detail.selectedRows;
		this.handleGetDocumentCode(selectedRows);
	}

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

		getDocumentTypeByCode({
			documentCodes: codeList
		})
		.then(result =>
		{
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
					this.showToastError(documentTypeNotFoundMessage);
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
			this.showToastError(reduceErrors(error));
		});
	}

	handleReasonSelection()
	{
		if(this.selectedCheckListItems.length === ZERO)
		{
			this.showToastError(selectChecklistItemMessage);
		}
		else
		{
			this.isReasonSelection = true;
		}
	}

	handleConfirmation()
	{
		this.delinkReason = this.template.querySelector('[data-field=\'delink-reason\']').value;
		const allValid = [...this.template.querySelectorAll('[data-field=\'delink-reason\']')]
		.reduce((validSoFar, inputFields) =>
		{
			inputFields.reportValidity();
			return validSoFar && inputFields.checkValidity();
		}, true);

		if(allValid)
		{
			this.isReasonSelection = false;
			this.isConfirmation = true;
		}
		else
		{
			this.template.querySelector('c-cmn-lwc-toast').requiredFieldsNotification();
		}
	}

	handleDelete()
	{
		this.isConfirmation = false;
		this.isLoading = true;
		deLinkDocumentItem({documentIds: this.selectedCheckListItems, deLinkReason: this.delinkReason})
		.then((result) =>
		{
			if(result)
			{
				this.isLoading = false;
				this.template.querySelector('lightning-datatable').selectedRows = []; //empty the list post deletion of records
				this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', this.recordsCount + ' ' + deleteMessage, 'success');
				this.selectedCheckListItems = [];
			}
			else
			{
				this.isLoading = false;
				this.showToastError(delinkDocumentsErrorMessage);
			}
			return refreshApex(this.refreshDocumentList); // refresh the list on deleting a record
		})
		.catch(error =>
		{
			this.isLoading = false;
			this.showToastError(reduceErrors(error));
		});
	}

	handleTypeChange(event)
	{
		this.currentListItemTypeId = event.target.value;
		if(this.currentListItemTypeId !== undefined && this.currentListItemTypeId !== BLANK)
		{
			this.handleGetDocumentType();
		}
	}

	handleGetDocumentType()
	{
		getDocumentType({recordId: this.currentListItemTypeId})
		.then(result =>
		{
			if(result)
			{
				this.currentListItemName = result.MasterLabel;
				this.existingListItemDocumentCode = result.DeveloperName;
			}
		})
		.catch(error =>
		{
			this.showToastError(reduceErrors(error));
		});
	}

	handleLink()
	{
		if(this.caseAccount === NULL)
		{
			this.showToastError(NoClientMessage);
		}
		else
		{
			this.isLoading = true;
			this.handleGetVaultedDocuments();
		}
	}

	handleEdit(rowToEdit)
	{
		this.isCallReclassify = false;
		this.isFileUploaded = false;
		this.isLoading = true;
		this.isEdit = true;
		this.createOrEditModal = true;
		this.currentListItemTypeLabel = rowToEdit.MasterLabel;
		this.currentListItemId = rowToEdit.Id;   // need to pass recordId when editing a record
		this.currentListItemName = rowToEdit.Name;
		this.currentListItemStatus = rowToEdit.Status;
		this.currentListItemType = rowToEdit.DocumentTypeId;
		this.currentListItemDocumentCode = rowToEdit.DeveloperName;
		this.documentRequired = rowToEdit.IsRequired;
		this.isLoading = this.handleTime();
		this.currentListItemReason = rowToEdit.CMN_Reason__c || BLANK;
		//to store vault details
		this.currentListItemVaulted = rowToEdit.AW_Vaulted__c;
		this.currentListItemVaultedDate = rowToEdit.AW_DateVaulted__c;
		this.currentListItemVaultedId = rowToEdit.CMN_VaultedId__c;

		if(rowToEdit.AW_Vaulted__c)
		{
			this.isCallReclassify = true;
		}
		this.showReason = rowToEdit.Status === REJECTED;
		return refreshApex(this.refreshDocumentList); // refresh the list on deleting a record
	}

	handleNew()
	{
		this.isLoading = true;
		this.isNew = true;
		this.isEdit = false;
		this.createOrEditModal = true;
		this.currentListItemId = BLANK;    // reset record details to null for new records
		this.currentListItemName = BLANK;
		this.currentListItemType = BLANK;
		this.currentListItemStatus = 'New';
		this.currentListItemReason = BLANK;
		this.showReason = false;
		this.isCallReclassify = false;
		this.isLoading = this.handleTime();
		return refreshApex(this.refreshDocumentList); // refresh the list on deleting a record
	}

	handleGetVaultedDocuments()
	{
		getVaultedDocuments({
			recordId: this.caseAccount
		})
		.then(result =>
		{
			if(result)
			{
				if(result.callSuccessful)
				{
					this.isLoading = false;
					if(result.vaultedDocuments !== NULL && result.vaultedDocuments.length > ZERO)
					{
						this.clientDocumentList = result.vaultedDocuments;
						this.handleFilterDocuments();
					}
					else
					{
						this.isLoading = false;
						this.showToastError(NoClientDataMessage);
					}
				}
				else
				{
					this.isLoading = false;
					let errorMessage = result.callMessage;

					if(errorMessage === BLANK)
					{
						errorMessage = problemInFetchingMessage;
					}
					this.showToastError(errorMessage);
				}
			}
			else
			{
				this.isLoading = false;
				this.showToastError(NoClientDataMessage);
			}
		})
		.catch(error =>
		{
			this.isLoading = false;
			this.clientDocumentList = [];
			let errorMessage = reduceErrors(error);
			if(errorMessage === BLANK)
			{
				errorMessage = problemInFetchingMessage;
			}
			this.showToastError(errorMessage);
		});
	}

	handleFilterDocuments()
	{
		getDocuments({
			recordId: this.recordId
		})
		.then(result =>
		{
			this.documentResult = result;
			if(result.length > ZERO)
			{
				for(let i = this.clientDocumentList.length - 1; i >= ZERO; i--)
				{
					for(let j = 0; j < this.documentResult.length; j++)
					{
						if(this.clientDocumentList[i] && (this.clientDocumentList[i].documentId === this.documentResult[j].CMN_VaultedId__c))
						{
							this.clientDocumentList.splice(i, 1);
						}
					}
				}
				this.filteredDocumentList = this.clientDocumentList;
				if(this.filteredDocumentList.length > ZERO)
				{
					this.isLink = true;
				}
				else
				{
					this.isLoading = false;
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', documentsVaultedMessage, 'success');

				}
			}
			else
			{
				this.isLink = true;
				this.filteredDocumentList = this.clientDocumentList;
			}
		})
		.catch(error =>
		{
			this.showToastError(reduceErrors(error));
		});
	}

	handleSave()
	{
		this.isLoading = true;
		if(this.isNew || this.isUpload)
		{
			this.isFileUploaded = this.template.querySelector('c-cmn-lwc-file-uploader').isFileSelected;
			this.isNew = false;
		}

		if(this.isFileUploaded)
		{
			this.isCallUpload = true;
			this.handleSaveRecord();
		}
		else
		{
			//only when Required value is changed under Edit action
			if(this.documentRequiredUpdated)
			{
				this.handleSaveOnRequiredUpdated();
			}
			else
			{
				this.handleSaveRecord();
			}
		}
	}

	handleSaveRecord()
	{
		this.isSave = false;
		if(this.isLink)
		{
			this.isLoading = true;
			this.currentListItemId = NULL;
			this.fileContents = BLANK;
			this.fileName = BLANK;
			this.isSave = true;
			this.handleFinalSave();
		}

		else if(this.template.querySelector('[data-field=\'current-listitem-name\']').value !== BLANK && this.template.querySelector('[data-field=\'current-listitem-type\']').value
				!== BLANK)
		{
			let singleListToInsert = [];
			let pushDataToSave = false;
			if(this.currentListItemId === BLANK)
			{
				//new doc from new button
				this.currentListItemId = NULL;
				//required true for new items created by default
				this.documentRequired = true;
			}

			let documentChecklistItem = {
				'sobjectType': DOCUMENT_CHECK_LIST_ITEM_OBJECT.objectApiName,
				'Name': this.template.querySelector('[data-field=\'current-listitem-name\']').value,
				'Id': this.currentListItemId,
				'ParentRecordId': this.recordId,
				'Status': this.currentListItemStatus,
				'IsRequired': this.documentRequired,
				'DocumentTypeId': this.template.querySelector('[data-field=\'current-listitem-type\']').value
			};

			if(this.currentListItemStatus !== REJECTED)
			{
				documentChecklistItem['CMN_Reason__c'] = BLANK;
				pushDataToSave = true;
			}
			else if(this.currentListItemStatus === REJECTED && this.template.querySelector('[data-field=\'current-listitem-reason\']').value.trim())
			{
				documentChecklistItem['CMN_Reason__c'] = this.template.querySelector('[data-field=\'current-listitem-reason\']').value.trim();
				pushDataToSave = true;
			}
			else
			{
				this.isLoading = false;
				this.showToastError(reasonForRejectMandatory);
			}

			if(pushDataToSave)
			{
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
					this.handleReclassify(this.currentListItemId);
				}
			}
		}
		else
		{
			this.isLoading = false;
			this.showToastError(validationMessage);
		}

	}

	handleFinalSave()
	{
		this.isLoading = true;

		if(this.vaultedDocumentToInsert.length > ZERO)
		{
			saveRecord({
				checklistItems: this.vaultedDocumentToInsert
			})
			.then(result =>
			{
				this.isLoading = false;
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
					this.isFileUploaded = false;
					this.uploadedFiles = [];
					this.vaultedDocumentToInsert = [];
					this.documentRequired = false;
					if(this.isCallUpload)
					{
						this.template.querySelector('c-cmn-lwc-file-uploader').createContentVersion(this.newDocumentChecklistItemId[0]);
					}

					if(this.isCallReclassify && this.calledReclassify)
					{
						this.handlePostCaseComments();
					}
					this.handleCloseLink();
					this.isLoading = false;
					this.isLoadingReclassify = false;
					this.handleClose();
					return refreshApex(this.refreshDocumentList);
				}
			})
			.catch(error =>
			{
				this.isLoading = false;
				this.isLoadingReclassify = false;
				this.showToastError(reduceErrors(error));
			});
		}
		else
		{
			this.isLoading = false;
			this.isLoadingReclassify = false;
			if(this.isLink)
			{
				this.showToastError(noDocumentsToLinkMessage);
			}
		}

	}

	/**
	 * @description event handler when the file is uploaded and content version is created
	 * @param event
	 */
	handleFileUploaderEvent(event)
	{
		if(event.detail.contentVersionId)
		{
			this.handleUpload(event.detail.firstPublishLocationId);
		}
	}

	handleDocumentUpload(rowToUpload)
	{
		this.isUpload = true;
		this.documentItemId = rowToUpload.Id;
	}

	handleFetchFiles()
	{
		this.isLoading = true;
		this.isFileUploaded = this.template.querySelector('c-cmn-lwc-file-uploader').isFileSelected;
		if(this.isFileUploaded)
		{
			this.template.querySelector('c-cmn-lwc-file-uploader').createContentVersion(this.documentItemId);
			this.isFileUploaded = false;
			return refreshApex(this.refreshDocumentList);
		}
		else
		{
			this.isLoading = false;
			this.showToastError(uploadFileMandatory);
		}
	}

	handleUpload(documentId)
	{
		this.isLoading = true;
		uploadDocuments({
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
					return refreshApex(this.refreshDocumentList);
				}
				else
				{
					this.isLoading = false;
					this.handleClose();
					this.handleUploadClose();
					this.isCallUpload = false;
					this.showToastError(uploadResult.callMessage);
				}
			}
		})
		.catch(uploadError =>
		{
			this.isLoading = false;
			this.isCallUpload = false;
			this.showToastError(uploadError);
		});
	}

	handleReclassify(documentId)
	{
		reclassifyDocuments({
			checklistId: documentId, documentTypeId: this.template.querySelector('[data-field=\'current-listitem-type\']').value
		})
		.then(reclassifyResult =>
		{
			this.isLoadingReclassify = true;
			if(reclassifyResult)
			{
				if(reclassifyResult.callSuccessful)
				{
					if(this.documentRequiredUpdated)
					{
						this.callPostCaseComments = true;
						this.handleFinalRequiredUpdated(this.replacedDocumentChecklistItem);
					}
					else
					{
						this.handleReclassifySave();
					}

					this.isLoadingReclassify = false;
					return refreshApex(this.refreshDocumentList);
				}
				else
				{
					this.isCallReclassify = false;
					this.isLoadingReclassify = false;
					this.handleClose();
					this.showToastError(reclassifyResult.callMessage);
				}
			}
		})
		.catch(reclassifyError =>
		{
			this.isLoadingReclassify = false;
			this.isCallReclassify = false;
			this.handleClose();
			this.showToastError(reduceErrors(reclassifyError));
		});
	}

	handleReclassifySave()
	{
		//this.isCallReclassify = false;
		this.calledReclassify = true;
		this.handleFinalSave();
	}

	handlePostCaseComments()
	{
		postCaseComments({
			checklistId: this.currentListItemId, documentTypeId: this.currentListItemType
		})
		.then(() =>
		{
			this.isCallReclassify = false;
			this.calledReclassify = false;
		})
		.catch(error =>
		{
			this.isCallReclassify = false;
			this.calledReclassify = false;
			this.showToastError(reduceErrors(error));
		});
	}

	handleView(rowToPreview)
	{
		this.isLoading = true;
		getContentDocument({
			recordId: rowToPreview.Id, vaultedId: rowToPreview.CMN_VaultedId__c
		})
		.then((result) =>
		{
			this.isLoading = false;
			if(result.callSuccessful && result.contentDocumentId !== BLANK)
			{
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage', attributes: {
						recordId: result.contentDocumentId, actionName: 'view'
					}
				});
			}
			else
			{
				this.showToastError(noFilesMessage);
			}
		})
		.catch(error =>
		{
			this.isLoading = false;
			this.showToastError(reduceErrors(error));
		});
	}

	handleClose()
	{
		this.createOrEditModal = false;
		this.isUpload = false;
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

	handleUploadClose()
	{
		this.fileName = BLANK;
		this.file = BLANK;
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
		this.isSave = false;
		if(this.template.querySelector('[data-field=\'current-listitem-name\']').value !== BLANK && this.template.querySelector('[data-field=\'current-listitem-type\']').value
				!== NULL)
		{
			let newDocumentChecklistItemCreated = {
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
			this.handleRequiredUpdated(newDocumentChecklistItemCreated);

			this.handleReasonForStatus(newDocumentChecklistItemCreated);
		}
		else
		{
			this.isLoading = false;
			this.showToastError(validationMessage);
		}
	}

	/**
	 * @description Method to check whether the Reclassify API needs to be invoked or not
	 * @param newDocumentChecklistItemCreated
	 */
	handleRequiredUpdated(newDocumentChecklistItemCreated)
	{
		if(this.existingListItemDocumentCode !== this.currentListItemDocumentCode && this.currentListItemVaulted)
		{
			//call reclassify api
			this.handleReclassify(this.currentListItemId);
		}
		else
		{
			this.onlyRequiredUpdated = true;
			this.handleFinalRequiredUpdated(newDocumentChecklistItemCreated);
			this.isLoading = true;
		}
	}

	/**
	 * @description Method to invoke the replaceDocumentChecklist from the controller
	 * @param newDocumentChecklistItemCreated
	 */
	handleFinalRequiredUpdated(newDocumentChecklistItemCreated)
	{
		replaceDocumentChecklist({
			documentChecklistId: this.currentListItemId, newChecklistItem: newDocumentChecklistItemCreated
		})
		.then(result =>
		{
			this.isLoading = false;
			if(result)
			{
				this.currentListItemId = result;

				if(this.onlyRequiredUpdated)
				{
					//if no change in document type and then only the record needs to be updated without API callout
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', updateSuccessMessage, 'success');
					this.onlyRequiredUpdated = false;
				}
				if(this.callPostCaseComments)
				{
					this.handlePostCaseComments();
					this.callPostCaseComments = false;
					this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', updateSuccessMessage, 'success');
				}

				this.handleClose();
				this.documentRequiredUpdated = false;
				return refreshApex(this.refreshDocumentList);
			}
		})
		.catch(error =>
		{
			this.isLoading = false;
			this.documentRequiredUpdated = false;
			this.onlyRequiredUpdated = false;
			this.callPostCaseComments = false;
			this.showToastError(reduceErrors(error));
		});
	}

	handleTime()
	{
		setInterval(function()
		{
			this.isLoading = false;
		}.bind(this), 5000);
		return this.isLoading;
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
			this.showToastError(reasonForRejectMandatory);
		}
	}

	handleDeleteNonVaultedDocument(currentRow)
	{
		this.isLoading = true;
		deleteNonVaultedDocuments({documentId: currentRow.Id})
		.then(() =>
		{
			this.isLoading = false;
			return refreshApex(this.refreshDocumentList);
		})
		.catch(error =>
		{
			this.isLoading = false;
			this.showToastError(reduceErrors(error));
		});
	}
}