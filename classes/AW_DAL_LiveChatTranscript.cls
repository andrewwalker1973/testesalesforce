/**
 * @description Public class is return the chat transcript data from the bot
 *
 * @see AW_FLOW_BotGetSnapInsPreChatData
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_LiveChatTranscript
{
	public static final String FIELD_CHAT_KEY = LiveChatTranscript.ChatKey.getDescribe().getLocalName();
	private static final String OBJECT_NAME = LiveChatTranscript.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_CHAT_KEY,
				LiveChatTranscript.AW_Username__c.getDescribe().getLocalName(),
				LiveChatTranscript.CaseId.getDescribe().getLocalName(),
				LiveChatTranscript.ContactId.getDescribe().getLocalName(),
				LiveChatTranscript.Id.getDescribe().getLocalName()
		};
	}

	/**
	 * @description This method is use to get the list of LiveChatTranscript
	 *
	 * @param chatKeys keys to search against
	 *
	 * @return List of LiveChatTranscript
	 */
	public static List<LiveChatTranscript> getCommunityChatTranscript(Set<String> chatKeys)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_CHAT_KEY, chatKeys, getDefaultFields());
	}
}