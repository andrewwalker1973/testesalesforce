/**
 * @description REST Endpoint wrapper class for inbound echo test service
 *
 * @see CMN_API_RestInboundEcho_TEST
 *
 * @author Accenture
 *
 * @date 2019
 */
@RestResource(UrlMapping='/echo/*')
global class CMN_URL_Echo
{
	/**
	 * @description post method for echo service (inbound)
	 */
	@HttpPost
	global static void echo()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(CMN_API_RestInboundEcho.class.getName());
	}
}