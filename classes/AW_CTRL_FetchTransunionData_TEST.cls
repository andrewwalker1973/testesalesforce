/**
 * @description Test class for AW_CTRL_FetchTransunionData
 *
 * @see AW_CTRL_FetchTransunionData @story ST-168885
 *
 * @author vishakha.saini@accenture.com jason.van.beukering@accenture.com
 *
 * @date March 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_CTRL_FetchTransunionData_TEST
{
	private static final Integer NUMBER_OF_LEADS_TO_CREATE = 1;
	/**
	 * @description Test data setup - Create a Lead
	 */
	@TestSetup
	public static void setup()
	{
		User adviser = AW_DAL_User.findRandomActiveAdviser();
		System.runAs(adviser)
		{
			AW_DAL_TestDataFactory.createLeads(AW_DAL_Lead.RECORDTYPE_DEFAULT, NUMBER_OF_LEADS_TO_CREATE, adviser.Id).iterator().next();
		}
	}

	/**
	 * @description This method Will check that the controller will get the consent data for Passport
	 *
	 * @see AW_CTRL_FetchTransunionData.getConsentData
	 */
	@IsTest
	private static void successfulCallGetConsentDataForPassport()
	{
		AW_CTRL_FetchTransunionData.DTO_Response dtoResponse = executeTest(true, AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT);
		Lead foundLead = AW_DAL_Lead.getAll().iterator().next();

		System.assertEquals(true, dtoResponse.callSuccessful, 'Transunion data not received as expected');
		System.assertEquals(AW_API_TransUnionData.SUCCESSFUL, foundLead.AW_CreditBureauCallStatus__c, 'Lead record not updated with Successful status as expected');
	}

	/**
	 * @description This method Will check that the controller will get the consent data for South African Id
	 *
	 * @see AW_CTRL_FetchTransunionData.getConsentData
	 */
	@IsTest
	private static void successfulCallGetConsentDataForSAId()
	{
		AW_CTRL_FetchTransunionData.DTO_Response dtoResponse = executeTest(true, AW_DAL_Lead.IDENTIFICATION_TYPE_SA_ID);
		Lead foundLead = AW_DAL_Lead.getAll().iterator().next();

		System.assertEquals(true, dtoResponse.callSuccessful, 'Transunion data not received as expected');
		System.assertEquals(AW_API_TransUnionData.SUCCESSFUL, foundLead.AW_CreditBureauCallStatus__c, 'Lead record not updated with Successful status as expected');
	}

	/**
	 * @description This method Will check that the controller will get the consent data
	 *
	 * @see AW_CTRL_FetchTransunionData.getConsentData
	 */
	@IsTest
	private static void successfulCallGetConsentErrorResponse()
	{
		CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;

		executeTest(false, AW_DAL_Lead.IDENTIFICATION_TYPE_SA_ID);
		Lead foundLead = AW_DAL_Lead.getAll().iterator().next();

		System.assertEquals(AW_CTRL_FetchTransunionData.FAILED, foundLead.AW_CreditBureauCallStatus__c, 'Error is not received as expected');
	}

	/**
	 * @description Will execute common code required for running successful/error test
	 *
	 * @param isSuccessful flag to check if successful
	 * @param idType identification type
	 *
	 * @return AW_CTRL_FetchTransunionData.DTO_Response
	 */
	private static AW_CTRL_FetchTransunionData.DTO_Response executeTest(Boolean isSuccessful, String idType)
	{
		Lead leadRecord = AW_DAL_Lead.getAll().iterator().next();

		String identificationType = AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT.equalsIgnoreCase(idType) ?
				AW_DAL_Lead.IDENTIFICATION_TYPE_PASSPORT : AW_DAL_Lead.IDENTIFICATION_TYPE_SA_ID;

		leadRecord.AW_IdentificationType__c = identificationType;
		leadRecord.AW_IdentificationNumber__c = AW_UTIL_IdentityNumber.generateRandomIdentityNumber();
		update leadRecord;

		AW_CTRL_FetchTransunionData.DTO_Response dtoResponse = new AW_CTRL_FetchTransunionData.DTO_Response();

		Test.startTest();

		dtoResponse = AW_CTRL_FetchTransunionData.getConsentData(leadRecord);

		Test.stopTest();

		System.assertEquals(isSuccessful, dtoResponse.callSuccessful, 'Call response not matching whats expected.');

		return dtoResponse;
	}

	/**
	 * @description This method Will check that the consent data will be removed from lead record
	 *
	 * @see AW_CTRL_FetchTransunionData.removeConsentData
	 */
	@IsTest
	private static void removeConsentDataTest()
	{
		Lead leadRecord = AW_DAL_Lead.getAll().iterator().next();

		Test.startTest();

		AW_CTRL_FetchTransunionData.removeConsentData(leadRecord);

		Test.stopTest();

		Lead updatedLeadRecord = AW_DAL_Lead.findById(leadRecord.Id);

		System.assertEquals(null, updatedLeadRecord.AW_CreditBureauTitle__c, 'Transunion data not removed as expected');
	}

	/**
	 * @description This method Will check that the lead record details are retrieved
	 *
	 * @see AW_CTRL_FetchTransunionData.getLeadRecord
	 */
	@IsTest
	private static void getLeadRecordTest()
	{
		Lead newLead = AW_DAL_Lead.getAll().iterator().next();

		Test.startTest();

		Lead foundLead = AW_CTRL_FetchTransunionData.getLeadRecord(newLead.Id);

		Test.stopTest();

		System.assertEquals(newLead.Id, foundLead.Id, 'Lead record not received as expected');
	}

	/**
	 * @description This method Will check that current user details are retrieved
	 *
	 * @see AW_CTRL_FetchTransunionData.getCurrentUser
	 */
	@IsTest
	private static void getCurrentUserTest()
	{
		User currentUser = AW_DAL_User.getCurrentUser();

		Test.startTest();

		User foundUser = AW_CTRL_FetchTransunionData.getCurrentUser();

		Test.stopTest();

		System.assertEquals(currentUser.Id, foundUser.Id, 'Current User details not retrieved as expected');
	}
}