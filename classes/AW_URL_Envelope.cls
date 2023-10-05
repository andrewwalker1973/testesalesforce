/**
 * @description REST Endpoint for performing actions on an envelope.
 *
 * @see AW_API_SetEnvelopeStatus
 * @see AW_API_SetEnvelopeStatus_TEST
 *
 * @author Accenture
 *
 * @date April 2021
 */
@RestResource(UrlMapping='/v1/envelope/*')
global inherited sharing class AW_URL_Envelope
{
	/**
	 * @description Will match the inbound envelope based on package Id and then update status as given
	 */
	@HttpPut
	global static void updateEnvelopeStatus()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(AW_API_SetEnvelopeStatus.SERVICE_NAME);
	}
}