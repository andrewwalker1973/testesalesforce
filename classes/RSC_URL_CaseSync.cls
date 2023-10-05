/**
 * @description Inbound Apex REST Api for inserting/ updating cases received from the workflow system
 *
 * @see RSC_API_UpsertCase @story ST-145996
 * @see RSC_API_UpsertCase_TEST
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date July 2021
 */
@RestResource(UrlMapping='/v1/cases/*')
global inherited sharing class RSC_URL_CaseSync
{
	/**
	 * @description Will match the Workflow case number based on request and then sync the case data
	 */
	@HttpPost
	global static void caseSync()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(RSC_API_UpsertCase.SERVICE_NAME);
	}
}