/**
 * @description Inbound Apex REST Api for inserting and updating cases received from pinball
 *
 * @see SC_API_AppointmentCaseSync
 * @see SC_API_AppointmentCaseSync_TEST
 *
 * @author mthobisi.ndlovu@accenture.com
 *
 * @date December 2022
 */
@RestResource(UrlMapping='/v1/appointment/*')
global inherited sharing class SC_URL_AppointmentCaseSync
{
	/**
	 * @description Method to process the inbound call to sync nurse case data
	 */
	@HttpPost
	global static void syncCase()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(SC_API_AppointmentCaseSync.SERVICE_NAME);
	}
}