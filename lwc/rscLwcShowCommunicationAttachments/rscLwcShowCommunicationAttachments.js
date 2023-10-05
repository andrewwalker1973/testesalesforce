import getAttachments from '@salesforce/apex/RSC_CTRL_GetCommunicationAttachment.getAttachmentsByTemplateId';
import {api, LightningElement, wire} from 'lwc';

/**
 * @description LWC component for displaying the communication attachments
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date September 2021
 */
export default class RscLwcShowCommunicationAttachments extends LightningElement
{

	@api communicationTemplate;
	@api displayType;
	@api selectedAttachmentsPayload;
	communicationAttachments;
	selectedAttachments;

	attachmentList = [];

	@api get attachments()
	{
		return this.attachmentList;
	}

	get isReadOnly()
	{
		return this.displayType === 'Read';
	}

	connectedCallback()
	{
		if(this.selectedAttachmentsPayload)
		{
			this.selectedAttachments = JSON.parse(this.selectedAttachmentsPayload);
		}
	}

	/**
	 * @description Fetches communication template attachments
	 * @param {FetchResponse} error Error response
	 * @param data List of attachments
	 */
	@wire(getAttachments, {templateId: '$communicationTemplate'}) wiredAttachments({error, data})
	{
		if(data)
		{
			this.communicationAttachments = data;

			if(this.selectedAttachments != null)
			{
				for(let attachment of this.selectedAttachments)
				{
					//noinspection JSUnresolvedVariable
					this.communicationAttachments = this.communicationAttachments.map(
							attach => (attach.attachmentId === attachment.attachmentId ? {...attach, isSelected: true, reason: attachment.reason} : attach));
				}
			}
		}
		else if(error)
		{
			this.template.querySelector('c-cmn-lwc-toast').customNotification('Error', error.body.message, 'error');
		}
	}

	/**
	 * @description Handles when an attachment checkbox is checked/unchecked
	 * @param event onChange Event from checkbox
	 */
	selectAttachmentHandler(event)
	{
		let allAttachments = [...this.communicationAttachments];
		allAttachments[event.target.dataset.index] = {
			...allAttachments[event.target.dataset.index], [event.target.dataset.fieldName]: event.target.checked
		};

		this.communicationAttachments = allAttachments;
		this.processPayload();
	}

	/**
	 * @description Handles when an attachment reason is entered
	 * @param event onChange Event from text input
	 */
	selectReasonHandler(event)
	{
		let allAttachments = [...this.communicationAttachments];
		allAttachments[event.target.dataset.index] = {
			...allAttachments[event.target.dataset.index], [event.target.dataset.fieldName]: event.target.value
		};

		this.communicationAttachments = allAttachments;
		this.processPayload();
	}

	/**
	 * @description Creates attachment payload to be read by the flow
	 */
	processPayload()
	{
		let selectedForms = [];
		for(let attachment of this.communicationAttachments)
		{
			if(attachment.isSelected)
			{
				selectedForms.push(attachment);
			}
		}
		this.attachmentList = [...selectedForms];
		this.selectedAttachmentsPayload = JSON.stringify(this.attachmentList)
	}
}