/**
 * @description Controller to get the communication attachments
 *
 * @see RSC_CTRL_GetCommunicationAttachment_TEST @story ST-146941
 *
 * @author Accenture - aakriti.a.goyal@accenture.com
 *
 * @date September 2021
 */
public inherited sharing class RSC_CTRL_GetCommunicationAttachment
{
	/**
	 * @description Will retrieve the communication template attachments for specific Template Id
	 *
	 * @param templateId The Id of the selected communication template
	 *
	 * @return A list of Communication Template Attachment Wrapper
	 */
	@AuraEnabled(Cacheable=true)
	public static List<CMN_DTO_CommunicationAttachment> getAttachmentsByTemplateId(String templateId)
	{
		List<CMN_CommunicationTemplateAttachment__c> templateAttachments = CMN_DAL_CommunicationTemplateAttachment.findByTemplateId(templateId);

		List<CMN_DTO_CommunicationAttachment> communicationAttachments = new List<CMN_DTO_CommunicationAttachment>();

		for(CMN_CommunicationTemplateAttachment__c attachment : templateAttachments)
		{
			CMN_DTO_CommunicationAttachment dtoCommunicationAttachment = new CMN_DTO_CommunicationAttachment();

			dtoCommunicationAttachment.attachmentId = attachment.Id;
			dtoCommunicationAttachment.attachmentDefinitionId = attachment.SC_Definition__c;
			dtoCommunicationAttachment.definitionName = attachment.SC_Definition__r.Name;
			dtoCommunicationAttachment.isSelected = false;
			dtoCommunicationAttachment.reason = CMN_UTIL_String.EMPTY;

			communicationAttachments.add(dtoCommunicationAttachment);
		}

		return communicationAttachments;
	}
}