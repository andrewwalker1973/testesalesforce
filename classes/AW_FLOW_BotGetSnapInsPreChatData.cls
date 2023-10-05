/**
 * @description The purpose of the apex class is to retrieve the Prechat informations
 *
 * @see AW_TEST_FLOW_BotGetSnapInsPreChatData date 2019
 *
 * @author Accenture
 */
public without sharing class AW_FLOW_BotGetSnapInsPreChatData
{
	/**
	 * @description This Method to retrieve pre chat information from LiveChatTranscript Object using in Bot
	 *
	 * @param preChatInputs Get the varriable of warrepr DTO_PreChatInput
	 *
	 * @return List of <DTO_PreChatInput
	 */
	@InvocableMethod(Label='Get SnapIns Prechat Data' Description = 'Method to retrieve pre chat information from LiveChatTranscript Object')
	public static List<DTO_PreChatOut> getSnapInsPrechatData(List<DTO_PreChatInput> preChatInputs)
	{
		List<DTO_PreChatOut> preChatOutputs = new List<DTO_PreChatOut>();

		Map<String, SObject> transcripts = populateTranscriptMap(preChatInputs);

		for(DTO_PreChatInput chatInput : preChatInputs)
		{
			if(String.isNotBlank(chatInput.sChatKey))
			{
				LiveChatTranscript transcript = (LiveChatTranscript)transcripts.get(chatInput.sChatKey);

				if(transcript != null)
				{
					DTO_PreChatOut preChatOutput = new DTO_PreChatOut();
					preChatOutput.loggedInUser = transcript.AW_Username__c;

					preChatOutputs.add(preChatOutput);
				}
			}
		}

		return preChatOutputs;
	}

	/**
	 * @description Will combine the objects in all the maps list to pupulate the preinput chat in bot
	 *
	 * @param preChatInputs
	 *
	 * @return List of <DTO_PreChatInput
	 */

	private static Map<String, SObject> populateTranscriptMap(List<DTO_PreChatInput> preChatInputs)
	{
		Set<String> chatKeys = new Set<String>();
		Map<String, SObject> transcriptsMap = new Map<String, SObject>();
		List<LiveChatTranscript> transcripts = new List<LiveChatTranscript>();

		for(DTO_PreChatInput key : preChatInputs)
		{
			chatKeys.add(key.sChatKey);
		}

		if(!chatKeys.isEmpty())
		{
			transcripts = AW_DAL_LiveChatTranscript.getCommunityChatTranscript(chatKeys);
		}

		if(!transcripts.isEmpty())
		{
			transcriptsMap = CMN_UTIL_System.convertListToSingleStringMap(transcripts, AW_DAL_LiveChatTranscript.FIELD_CHAT_KEY);
		}

		return transcriptsMap;
	}

	/**
	 * @description Public class to declare invocalble variable
	 */
	public class DTO_PreChatOut
	{
		@InvocableVariable(Label = 'Logged In User')
		public String loggedInUser;
	}
	/**
	 * @description Public class to declare invocalble variable
	 */
	public class DTO_PreChatInput
	{
		@InvocableVariable(Required=true Label = 'Chat Key' Description='Variable to store session ID of chat.')
		public String sChatKey;
	}

}