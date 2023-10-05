/**
 * @description Will test the inbound service class AW_API_SetEnvelopeStatus
 *
 * @see AW_API_SetEnvelopeStatus
 *
 * @author Accenture
 *
 * @date May 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_API_SetEnvelopeStatus_TEST
{
	private static final String STATUS_SUCCESSFUL = 'SUCCESSFUL';

	/**
	 * @description Will setup the RestContext Objects of "request" and "response"
	 *
	 * @param dtoRequest The DTO that should be serialised and represents the JSON sent in a request
	 */
	private static void setupRestContext(AW_API_SetEnvelopeStatus.DTO_Request dtoRequest)
	{
		RestContext.request = new RestRequest();

		RestContext.request.headers.put(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
		RestContext.response = new RestResponse();
		RestContext.request.requestBody = Blob.valueOf(dtoRequest.serialize());
	}

	/**
	 * @description Will test that exception is thrown if a packageId not provided
	 */
	@IsTest
	private static void missingPackageId()
	{
		AW_API_SetEnvelopeStatus.DTO_Request dtoRequest = new AW_API_SetEnvelopeStatus.DTO_Request();

		setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_Envelope.updateEnvelopeStatus();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(AW_API_SetEnvelopeStatus.SERVICE_NAME, AW_API_SetEnvelopeStatus.ERROR_PACKAGE_ID_MISSING);
	}

	/**
	 * @description Will test that exception is thrown if envelope cannot be found
	 */
	@IsTest
	private static void envelopeNotFound()
	{
		AW_API_SetEnvelopeStatus.DTO_Request dtoRequest = new AW_API_SetEnvelopeStatus.DTO_Request();
		dtoRequest.packageId = CMN_DAL_SObjectDomain.generateRandomNumber();

		setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_Envelope.updateEnvelopeStatus();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(AW_API_SetEnvelopeStatus.SERVICE_NAME, AW_API_SetEnvelopeStatus.ERROR_ENVELOPE_NOT_FOUND);
	}

	/**
	 * @description Will test that envelope status is declined correctly
	 */
	@IsTest
	private static void updateEnvelopeStatusToDeclined()
	{
		AW_Envelope__c newEnvelope = AW_DAL_TestDataFactory.newEnvelope();
		newEnvelope.AW_PackageID__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newEnvelope.AW_Status__c = AW_DAL_Envelope.STATUS_NEW;
		insert newEnvelope;

		DocumentChecklistItem documentItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(newEnvelope.Id);

		//Checking Envelope Status before Test
		System.assertEquals(AW_DAL_Envelope.STATUS_NEW, newEnvelope.AW_Status__c, 'Status not set correctly');

		AW_API_SetEnvelopeStatus.DTO_Request dtoRequest = new AW_API_SetEnvelopeStatus.DTO_Request();

		dtoRequest.packageId = newEnvelope.AW_PackageID__c;
		dtoRequest.packageStatus = AW_API_SetEnvelopeStatus.STATUS_DECLINED;

		setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_Envelope.updateEnvelopeStatus();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_SetEnvelopeStatus.SERVICE_NAME);

		newEnvelope = AW_DAL_Envelope.findById(newEnvelope.Id);
		//Checking Envelope Status after test
		System.assertEquals(AW_DAL_Envelope.STATUS_DECLINED, newEnvelope.AW_Status__c, 'Status not set correctly');

	}

	/**
	 * @description Will test that envelope status is updated correctly
	 */
	@IsTest
	private static void updateEnvelopeStatus()
	{
		AW_Envelope__c newEnvelope = AW_DAL_TestDataFactory.newEnvelope();
		newEnvelope.AW_PackageID__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newEnvelope.AW_Status__c = AW_DAL_Envelope.STATUS_NEW;
		insert newEnvelope;

		DocumentChecklistItem documentItem = AW_DAL_TestDataFactory.insertDocumentCheckListItem(newEnvelope.Id);

		//Checking Envelope Status before Test
		System.assertEquals(AW_DAL_Envelope.STATUS_NEW, newEnvelope.AW_Status__c, 'Status not set correctly');

		AW_API_SetEnvelopeStatus.DTO_Request dtoRequest = new AW_API_SetEnvelopeStatus.DTO_Request();
		List<AW_API_SetEnvelopeStatus.DTO_Document> documents = new List<AW_API_SetEnvelopeStatus.DTO_Document>();

		dtoRequest.packageId = newEnvelope.AW_PackageID__c;
		dtoRequest.packageStatus = AW_API_SetEnvelopeStatus.STATUS_COMPLETED;

		//Add the DocumentChecklist data created for DTORequest documents
		documents.add(populateDocumentChecklistDtoData(documentItem));

		dtoRequest.documents = documents;

		setupRestContext(dtoRequest);

		Test.startTest();

		AW_URL_Envelope.updateEnvelopeStatus();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(AW_API_SetEnvelopeStatus.SERVICE_NAME);

		newEnvelope = AW_DAL_Envelope.findById(newEnvelope.Id);
		//Checking Envelope Status after test
		System.assertEquals(AW_DAL_Envelope.STATUS_COMPLETED, newEnvelope.AW_Status__c, 'Status not set correctly');
	}

	/**
	 * @description Will generate (DocumentChecklistItem) status update data for dto request.
	 *
	 * @param documentItem DocumentChecklistItem record
	 *
	 * @return DTO_Document
	 */
	private static AW_API_SetEnvelopeStatus.DTO_Document populateDocumentChecklistDtoData(DocumentChecklistItem documentItem)
	{
		AW_API_SetEnvelopeStatus.DTO_Document document1 = new AW_API_SetEnvelopeStatus.DTO_Document();

		//Creating document1 Data which will update the vaulted status in Salesforce
		document1.documentId = documentItem.Id;
		document1.documentStatus = STATUS_SUCCESSFUL;

		return document1;
	}
}