/**
 * @description Inbound Apex REST Api for terminating the Advisors that are not synced by SRS
 *
 * @see RSC_API_NotifyAdvisorSyncCompleted @226578
 * @see RSC_API_NotifyAdvisorSyncCompleted_TEST
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date December 2021
 */
@RestResource(UrlMapping='/v1/notifyAdvisorSyncCompleted/*')
global inherited sharing class RSC_URL_NotifyAdvisorSyncCompleted
{
	/**
	 * @description Will  based on request and then sync the advisor data
	 */
	@HttpPost
	global static void notifyAdvisorSyncCompleted()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(RSC_API_NotifyAdvisorSyncCompleted.SERVICE_NAME);
	}
}