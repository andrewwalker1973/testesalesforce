/**
 * @description Test class for AW_FLOW_BotGetSnapInsPreChatData
 *
 * @see AW_FLOW_BotGetSnapInsPreChatData @story ST-1900
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_TEST_FLOW_BotGetSnapInsPreChatData
{
	private static final Integer NUMBER_REQUEST_RECORD_TO_CREATE = 3;

	@IsTest
	private static void getSnapInsPrechatData()
	{
		List<AW_FLOW_BotGetSnapInsPreChatData.DTO_PreChatInput> tranScript = AW_DAL_TestDataFactory.createChatScript(NUMBER_REQUEST_RECORD_TO_CREATE);

		Test.startTest();

		List<AW_FLOW_BotGetSnapInsPreChatData.DTO_PreChatOut> dtoPreChatOuts = AW_FLOW_BotGetSnapInsPreChatData.getSnapInsPrechatData(tranScript);

		Test.stopTest();

		System.assertNotEquals(true, dtoPreChatOuts.isEmpty(), 'No chats retrieved');

	}
}