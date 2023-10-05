/**
 * @description Class representing the JSON structure of attachments to be sent with the Communication API
 *
 * @author aakriti.a.goyal@accenture.com @story ST-146941
 *
 * @date September 2021
 */
public inherited sharing class CMN_DTO_CommunicationAttachment
{
	@InvocableVariable @AuraEnabled
	public String attachmentId;
	@InvocableVariable @AuraEnabled
	public String attachmentDefinitionId;
	@InvocableVariable @AuraEnabled
	public String definitionName;
	@InvocableVariable @AuraEnabled
	public Boolean isSelected;
	@InvocableVariable @AuraEnabled
	public String reason;
}