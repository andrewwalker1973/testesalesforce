/**
 * @description Inbound Apex REST Api for inserting/ updating cases received from the workflow system
 *
 * @see RSC_API_UpsertAdvisers @story ST-146274
 * @see RSC_API_UpsertAdvisers_TEST
 *
 * @author m.sudhakar.rokde@accenture.com
 *
 * @date Nov 2021
 */
@RestResource(UrlMapping='/v1/advisers/*')
global inherited sharing class RSC_URL_AdviserSync
{
    /**
     * @description Will  based on request and then sync the advisor data
     */
    @HttpPost
    global static void adviserSync()
    {
        CMN_FACTORY_WebserviceManager.processInboundService(RSC_API_UpsertAdvisers.SERVICE_NAME);
    }
}