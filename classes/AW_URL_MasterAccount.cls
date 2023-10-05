/**
 * @description REST Endpoint for performing actions on an Master Account.
 *
 * @see AW_API_UpsertMasterAccount
 * @see AW_API_UpsertMasterAccount_TEST
 *
 * @author Accenture
 *
 * @date May 2021
 */
@RestResource(UrlMapping='/v1/masteraccount/*')
global inherited sharing class AW_URL_MasterAccount
{
	/**
	 * @description Will match the inbound UUID based on request and then sync master account data
	 */
	@HttpPost
	global static void masterAccountSync()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(AW_API_UpsertMasterAccount.SERVICE_NAME);
	}
}