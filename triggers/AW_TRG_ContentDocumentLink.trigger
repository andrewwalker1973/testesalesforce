/**
 * @description Trigger to execute custom actions when DML event occurs on ContentDocumentLink
 *
 * @see AW_TH_ContentDocumentLink
 *
 * @author Accenture
 *
 * @date 2019
 */
trigger AW_TRG_ContentDocumentLink on ContentDocumentLink (after insert, before insert )
{
	CMN_FACTORY_TriggerHandler.createHandler(AW_TH_ContentDocumentLink.class);
}