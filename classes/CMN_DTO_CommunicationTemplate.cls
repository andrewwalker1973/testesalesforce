/**
 * @description DTO used to get the parameters needed for the communication template
 *
 * @author jason.van.beukering@accenture.com darrion.james.singh@accenture.com
 *
 * @date September 2021, May 2022
 */
@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
public inherited sharing class CMN_DTO_CommunicationTemplate
{
	@AuraEnabled
	@InvocableVariable(Label='Template Id' Description='Template Id' Required=true)
	public Id templateId;

	@AuraEnabled
	@InvocableVariable(Label='Record Id' Description='Record Id' Required=true)
	public Id recordId;

	@AuraEnabled
	@InvocableVariable(Label='Selected Recipients' Description='Selected Recipients')
	public List<CMN_DTO_CommunicationRecipients> recipients;

	@AuraEnabled
	@InvocableVariable(Label='Selected Attachments' Description='Selected Attachment')
	public List<CMN_DTO_CommunicationAttachment> selectedAttachments;

	@AuraEnabled
	@InvocableVariable(Label='Other Comments' Description='Other Comments')
	public String otherComments;

	@AuraEnabled
	@InvocableVariable(Label='Reply with Documents' Description='Reply with Documents' Required=true)
	public Boolean replyWithDocuments;

	@AuraEnabled
	@InvocableVariable(Label='Password Protection' Description='Password Protection' Required=true)
	public Boolean passwordProtection;

	@AuraEnabled
	@InvocableVariable(Label='Parameter Ids' Description='List of Record Ids that can be queried')
	public List<Id> parameterIds;

	@AuraEnabled
	@InvocableVariable(Label='Send Email Reminder' Description='Boolean to decide if an email reminder must be sent')
	public Boolean sendEmail;
}