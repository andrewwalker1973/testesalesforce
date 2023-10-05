//noinspection CssInvalidHtmlTagReference

/**
 * @description LWC Component that fetches the vaulted documents that have been placed securely in the vault.
 *              Available on four objects  Person Accounts, Leads, Opportunities & Outstanding Requirements.
 *
 * @author nihal.desai@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @see storyNo: 118603, #178029
 *
 * @date May 2021,January 2022
 */
import getContentDocument from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.getContentDocument';
import getVaultedDocuments from '@salesforce/apex/RSC_CTRL_GetVaultedDocuments.getVaultedDocuments';
import blockVisitor from '@salesforce/label/c.RSC_BlockVisitor';
import clickToView from '@salesforce/label/c.RSC_ClickToView';

import noFilesMessage from '@salesforce/label/c.RSC_NoFilesToDisplay';
import problemInFetchingMessage from '@salesforce/label/c.RSC_ProblemInFetchingDocuments';
import spinnerMessage from '@salesforce/label/c.RSC_SpinnerContent';

import uId from '@salesforce/user/Id';
import {reduceErrors} from 'c/cmnLwcUtil';
import {NavigationMixin} from 'lightning/navigation';
import {api, LightningElement} from 'lwc';

const NULL = null;
const ZERO = 0;
const BLANK = '';

const columns = [
	{label: 'Source', fieldName: 'source'},
	{label: 'Document Id', fieldName: 'documentId'},
	{label: 'Document Type', fieldName: 'documentType'},
	{label: 'Document Type Code', fieldName: 'sourceId'},
	{label: 'Entry Date', fieldName: 'entryDate'},
	{
		label: 'View', type: 'button-icon', initialWidth: 60,
		typeAttributes:
			{
				iconName: {fieldName: 'iconName'},
				title: {fieldName: 'titleMessage'},
				variant: 'border-filled',
				alternativeText: 'View'
			}
	}
];

export default class ScLwcVaultedDocuments extends NavigationMixin(LightningElement)
{
	label =
		{
			noFilesMessage,
			spinnerMessage,
			clickToView,
			blockVisitor,
			problemInFetchingMessage
		};

	columns = columns;
	@api userId = uId;
	@api recordId;
	@api toolTip;
	@api currentUserUACFId;
	@api currentUserConsultantCode;
	@api requesterType;
	@api currentUserName;
	@api helpText = spinnerMessage;
	isLoading = true;
	documentList = [];

	//noinspection JSUnresolvedFunction
	/**
	 * @description Show toast Error notification
	 * @param errorMessage Message to be displayed
	 * @param header Error header
	 * @returns {*}
	 */
	showToastError = (errorMessage, header = 'Error') =>
		this.template.querySelector('c-cmn-lwc-toast').customNotification(header, errorMessage, 'error');

	connectedCallback()
	{
		getVaultedDocuments
		({
			recordId: this.recordId
		})
		.then(({callSuccessful, vaultedDocuments, callMessage}) =>
		{
			if(callSuccessful)
			{
				this.isLoading = false;

				// As we are unable to display the reason for disabling the button on hovering,
				//we made the buttons to change dynamically so that we can see the reason for blocked icon on hovering

				if(vaultedDocuments !== NULL && vaultedDocuments.length > ZERO)
				{
					this.documentList = vaultedDocuments.map(val =>
					{
						if(val.readOnly !== NULL && val.readOnly !== undefined)
						{
							if(val.readOnly)
							{
								val.iconName = 'utility:preview';
								val.titleMessage = clickToView;
							}
							else
							{
								val.iconName = 'utility:block_visitor';
								val.titleMessage = blockVisitor;
							}
						}
						else
						{
							val.readOnly = false;
							val.iconName = 'utility:block_visitor';
							val.titleMessage = blockVisitor;
						}
						return val;
					});
				}
			}
			else
			{
				this.isLoading = false;
				let errorMessage = callMessage ? callMessage : problemInFetchingMessage;

				this.showToastError(errorMessage);
			}
		})
		.catch(error =>
		{
			this.isLoading = false;
			this.documentList = [];
			let errorMessage = reduceErrors(error).join(' // ');
			this.showToastError(errorMessage);
		});
	}

	handleRowAction(event)
	{
		const row = event.detail.row;

		if(row.readOnly)
		{
			this.isLoading = true;
			this.handleView(row);
		}
	}

	handleView({documentId})
	{
		getContentDocument
		({
			recordId: this.userId,
			vaultedId: documentId
		})
		.then(({callSuccessful, contentDocumentId}) =>
		{
			if(callSuccessful && contentDocumentId !== BLANK)
			{
				this.isLoading = false;
				this[NavigationMixin.Navigate]
				({
					type: 'standard__recordPage',
					attributes:
						{
							recordId: contentDocumentId,
							actionName: 'view'
						}
				});
			}
			else
			{
				this.isLoading = false;
				this.showToastError(noFilesMessage);
			}
		})
		.catch(error =>
		{
			this.isLoading = false;
			let errorMessage = reduceErrors(error).join(' // ');
			this.showToastError(errorMessage);
		});
	}
}