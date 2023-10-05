/**
 * @description Test class for AW_API_TransUnionData
 *
 * @see AW_API_TransUnionData @story 168885
 *
 * @author sukhdeep.b.singh@accenture.com vishakha.saini@liberty.co.za jason.van.beukering@accenture.com
 *
 * @date August 2021, March 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_API_TransUnionData_TEST
{
	private static final Integer NUMBER_OF_LEADS_TO_CREATE = 1;

	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, NUMBER_OF_LEADS_TO_CREATE, adviser.Id).iterator().next();
		}
	}

	/**
	 * @description Will execute common code required for running successful test
	 *
	 * @param triggeringObjectId Id of triggering object
	 * @param isSuccessful flag to check if successful
	 *
	 * @return The webservice handler
	 */
	private static AW_API_TransUnionData executeTest(Id triggeringObjectId, Boolean isSuccessful)
	{
		AW_API_TransUnionData handler;

		if(isSuccessful)
		{
			handler = (AW_API_TransUnionData)CMN_API_RestBaseOutboundTestHelper.successfulCall(AW_API_TransUnionData.SERVICE_NAME, triggeringObjectId);
		}
		else
		{
			handler = (AW_API_TransUnionData)CMN_API_RestBaseOutboundTestHelper.abortedCall(AW_API_TransUnionData.SERVICE_NAME, triggeringObjectId);
		}

		return handler;
	}

	/**
	 * @description Check that the service call is successful and the correct data is stored on the lead record
	 */
	@IsTest
	private static void successfulCallWithIdentityNumber()
	{
		Lead leadRecord = AW_DAL_Lead.getAll().iterator().next();

		AW_API_TransUnionData handler = executeTest(leadRecord.Id, true);

		Lead updatedLead = AW_DAL_Lead.findById(leadRecord.Id);
		AW_API_TransUnionData.DTO_Response dtoResponse = (AW_API_TransUnionData.DTO_Response)handler.baseResponseDTO;

		assertAddressDetails(updatedLead, dtoResponse);
		assertEmploymentDetails(updatedLead, dtoResponse);
	}

	/**
	 * @description Check that the service call is successful for lead with Passport as Identification Type
	 */
	@IsTest
	private static void successfulCallWithPassportNumber()
	{
		Lead leadRecord = AW_DAL_Lead.getAll().iterator().next();
		leadRecord.AW_IdentificationType__c = AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT;
		leadRecord.AW_IdentificationNumber__c = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		update leadRecord;

		CMN_API_RestBaseOutboundTestHelper.successfulCall(AW_API_TransUnionData.SERVICE_NAME, leadRecord.Id);
	}

	/**
	 * @description Check that Address details are correctly mapped to lead
	 *
	 * @param updatedLead Updated lead record
	 * @param dtoResponse Response DTO
	 */
	private static void assertAddressDetails(Lead updatedLead, AW_API_TransUnionData.DTO_Response dtoResponse)
	{
		List <AW_API_TransUnionData.DTO_AddressDetails> dtoAddressDetails = dtoResponse.address;
		dtoAddressDetails.sort();

		String previousInformationDate = dtoAddressDetails.iterator().next().informationDate;

		//This loop ensures that dtoAddressDetails is sorted in descending order of informationDate
		for(AW_API_TransUnionData.DTO_AddressDetails address : dtoAddressDetails)
		{
			System.assert(previousInformationDate >= address.informationDate, 'Addresses not sorted in descending order of informationDate');
			previousInformationDate = address.informationDate;
		}

		System.assertEquals(updatedLead.AW_CreditBureauAddress1Line1__c, dtoAddressDetails.get(0).line1, 'Address1 is not sorted by information date');
		System.assertEquals(updatedLead.AW_CreditBureauAddress2Line1__c, dtoAddressDetails.get(1).line1, 'Address2 is not sorted by information date');
	}

	/**
	 * @description Check that Employment details are correctly mapped to lead
	 *
	 * @param updatedLead Updated lead record
	 * @param dtoResponse Response DTO
	 */
	private static void assertEmploymentDetails(Lead updatedLead, AW_API_TransUnionData.DTO_Response dtoResponse)
	{
		List <AW_API_TransUnionData.DTO_EmploymentDetails> dtoEmploymentDetails = dtoResponse.employmentNM04;
		dtoEmploymentDetails.sort();

		String previousInformationDate = dtoEmploymentDetails.iterator().next().informationDate;

		//This loop ensures that dtoEmploymentDetails is sorted in descending order of informationDate
		for(AW_API_TransUnionData.DTO_EmploymentDetails employmentDetail : dtoEmploymentDetails)
		{
			System.assert(previousInformationDate >= employmentDetail.informationDate, 'Employment Details not sorted in descending order of informationDate');
			previousInformationDate = employmentDetail.informationDate;
		}

		System.assertEquals(updatedLead.AW_CreditBureauOccupation1__c, dtoEmploymentDetails.get(0).occupation, 'EmploymentDetail1 is not sorted by information date');
		System.assertEquals(updatedLead.AW_CreditBureauOccupation2__c, dtoEmploymentDetails.get(1).occupation, 'EmploymentDetail2 is not sorted by information date');
	}

	/**
	 * @description Check that the service aborts if the Id provided does not find lead
	 *
	 * @see AW_API_TransUnionData.abortRequest
	 */
	@IsTest
	private static void abortedCallItemNotFound()
	{
		executeTest(UserInfo.getUserId(), false);
	}

	/**
	 * @description Check that the service aborts if the lead provided does not have Identification Number
	 *
	 * @see AW_API_TransUnionData.abortRequest
	 */
	@IsTest
	private static void abortedCallWithoutIdentificationNumber()
	{
		Lead foundLead = AW_DAL_Lead.getAll().iterator().next();
		foundLead.AW_IdentificationNumber__c = CMN_UTIL_String.EMPTY;
		update foundLead;

		AW_API_TransUnionData handler = executeTest(foundLead.Id, false);

		foundLead = AW_DAL_Lead.getAll().iterator().next();

		System.assertEquals(handler.responseMessage, foundLead.AW_CreditBureauRequestStatusMessage__c, 'Status message not set correctly');
	}

	/**
	 * @description Check that the service aborts if the lead provided does not have First Name if IdType is Passport
	 *
	 * @see AW_API_TransUnionData.abortRequest
	 */
	@IsTest
	private static void abortedCallWithoutFirstName()
	{
		Lead foundLead = AW_DAL_Lead.getAll().iterator().next();
		foundLead.AW_IdentificationType__c = AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT;
		foundLead.AW_IdentificationNumber__c = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		foundLead.FirstName = null;
		update foundLead;

		AW_API_TransUnionData handler = executeTest(foundLead.Id, false);

		foundLead = AW_DAL_Lead.getAll().iterator().next();

		System.assertEquals(handler.responseMessage, foundLead.AW_CreditBureauRequestStatusMessage__c, 'Status message not set correctly');
	}

	/**
	 * @description Check that the service aborts if the lead provided does not have Date of Birth if IdType is Passport
	 *
	 * @see AW_API_TransUnionData.abortRequest
	 */
	@IsTest
	private static void abortedCallWithoutDateOfBirth()
	{
		Lead foundLead = AW_DAL_Lead.getAll().iterator().next();
		foundLead.AW_IdentificationType__c = AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT;
		foundLead.AW_IdentificationNumber__c = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		foundLead.AW_DateOfBirth__c = null;
		update foundLead;

		AW_API_TransUnionData handler = executeTest(foundLead.Id, false);

		foundLead = AW_DAL_Lead.getAll().iterator().next();

		System.assertEquals(handler.responseMessage, foundLead.AW_CreditBureauRequestStatusMessage__c, 'Status message not set correctly');
	}

	/**
	 * @description This method Will check the failed call
	 */
	@IsTest
	private static void failedCall()
	{
		Lead leadRecord = AW_DAL_Lead.getAll().iterator().next();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_TransUnionData.SERVICE_NAME, leadRecord.Id);

		Test.startTest();

		CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;
		//With CMN_API_RestBaseOutboundTestHelper.failedCall() method, existing Assertion(second) in method is failing due to different structure of error response in case of Transunion
		AW_API_TransUnionData handler = (AW_API_TransUnionData)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c>
		{
				queueItem
		}).iterator().next();

		Test.stopTest();

		Lead foundLead = AW_DAL_Lead.getAll().iterator().next();

		System.assertEquals(true, handler.callResult.failed, 'Status invalid. Response Call Result JSON: ' + JSON.serialize(handler.callResult));
		System.assertEquals(handler.responseMessage, foundLead.AW_CreditBureauRequestStatusMessage__c, 'Status message not set correctly');
	}

	/**
	 * @description This method Will check the system errors are handled
	 */
	@IsTest
	private static void errorCall()
	{
		Lead leadRecord = AW_DAL_Lead.getAll().iterator().next();
		leadRecord.AW_IdentificationType__c = null;
		update leadRecord;

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_TransUnionData.SERVICE_NAME, leadRecord.Id);

		Test.startTest();

		AW_API_TransUnionData handler = (AW_API_TransUnionData)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c>
		{
				queueItem
		}).iterator().next();

		Test.stopTest();

		Lead foundLead = AW_DAL_Lead.getAll().iterator().next();

		System.assertEquals(true, handler.callResult.failed, 'Status invalid. Response Call Result JSON: ' + JSON.serialize(handler.callResult));
		System.assertEquals(handler.responseMessage, foundLead.AW_CreditBureauRequestStatusMessage__c, 'Status message not set correctly');
	}
}