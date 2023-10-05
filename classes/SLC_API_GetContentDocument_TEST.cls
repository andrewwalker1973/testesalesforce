/**
 * @description Test class for SLC_API_GetContentDocument
 *
 * @author Futureform
 *
 * @date December 2022
 */
@isTest
private class SLC_API_GetContentDocument_TEST {

    /**
     * @description Test Method to validate the scenario wherein successful outbound API call is made to get the Content Document from Mulesoft
     */
    /**
	 * @description Create data required for the unit test
	 */
    @TestSetup
    private static void setup() {
        ContentVersion cv = new ContentVersion();
        cv.Description = 'test description';
        cv.PathOnClient = 'test_file.txt';
        cv.Title = 'test file ' + Datetime.now();
        cv.VersionData = Blob.valueOf('test file body');
        insert cv;
    }

    @isTest
    static void testGetContentDocumentSuccessful() {
        ContentDocument contDoc = [SELECT Id FROM ContentDocument LIMIT 1];

        Set<String> params = new Set<String>();
        params.add(SLC_API_GetContentDocument.PARAMETER_VAULTED_ID);
        params.add(SLC_API_GetContentDocument.LINKED_OBJECT_ID);

        CMN_API_RestBaseOutboundTestHelper.successfulCall(SLC_API_GetContentDocument.SERVICE_NAME, contDoc.Id, params);
    }

    /**
     * @description Check that the service aborts if the Id provided does not find a valid Content Document
     *
     * @see SLC_API_GetContentDocument.abortRequest
     */
    @IsTest
    private static void abortedGetContentDocumentCallNoItemFound() {
        CMN_API_RestBaseOutboundTestHelper.abortedCall(SLC_API_GetContentDocument.SERVICE_NAME, '06925000001flh8ADX');
    }

}