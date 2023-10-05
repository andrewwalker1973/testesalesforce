/**
 * @description Inbound Apex REST Api for updating a client's contracts, removing out of force ones
 *
 * @see AW_API_SynchroniseContracts
 * @see AW_API_SynchroniseContracts_TEST
 *
 * @author Accenture
 *
 * @date May 2021
 */
@RestResource(UrlMapping='/v1/contract/*')
global inherited sharing class AW_URL_Contract
{
	/**
	 * @description Will update all the contracts for a client, remove any ones that are no longer inforce
	 */
	@HttpPost
	global static void synchroniseContracts()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(AW_API_SynchroniseContracts.SERVICE_NAME);
	}
}