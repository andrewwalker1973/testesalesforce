/**
 * @description This class is the apex controller for Lightning Web Component awLwcFetchTransunionData
 *
 * @see AW_CTRL_FetchTransunionData_TEST @story ST-168885
 *
 * @author vishakha.saini@accenture.com
 *
 * @date March 2022
 */
public inherited sharing class AW_CTRL_FetchTransunionData
{
	@TestVisible
	private static final String CALL_STATUS_NONE = 'None';
	@TestVisible
	private static final String FAILED = 'Failed';

	/**
	 * @description Will make a API call AW_API_TransUnionData
	 *
	 * @param leadRecord lead record
	 *
	 * @return DTO_Response
	 */
	@AuraEnabled
	public static DTO_Response getConsentData(Lead leadRecord)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_TransUnionData.SERVICE_NAME, leadRecord.Id);

		List<CMN_API_HttpBase> handlers = CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});
		AW_API_TransUnionData transunionAPI = (AW_API_TransUnionData)handlers.iterator().next();

		return setDtoResponse(transunionAPI.responseMessage, transunionAPI.callResult.completed);
	}

	/**
	 * @description used to set the dto response
	 *
	 * @param responseMessage message to set as response
	 * @param callSuccessful Boolean to represent if call is successful
	 *
	 * @return DTO_Response
	 */
	private static DTO_Response setDtoResponse(String responseMessage, Boolean callSuccessful)
	{
		DTO_Response dtoResponse = new DTO_Response();

		dtoResponse.callSuccessful = callSuccessful;
		dtoResponse.responseMessage = responseMessage;

		return dtoResponse;
	}

	/**
	 * @description Will remove the consent data from lead record
	 *
	 * @param leadRecord lead record
	 */
	@AuraEnabled
	public static void removeConsentData(Lead leadRecord)
	{
		leadRecord.AW_CreditBureauAddress1City__c = null;
		leadRecord.AW_CreditBureauAddress1Line1__c = null;
		leadRecord.AW_CreditBureauAddress1Line2__c = null;
		leadRecord.AW_CreditBureauAddress1PostalCode__c = null;
		leadRecord.AW_CreditBureauAddress1ProvinceCode__c = null;
		leadRecord.AW_CreditBureauAddress1Province__c = null;
		leadRecord.AW_CreditBureauAddress1Suburb__c = null;
		leadRecord.AW_CreditBureauAddress2City__c = null;
		leadRecord.AW_CreditBureauAddress2Line1__c = null;
		leadRecord.AW_CreditBureauAddress2Line2__c = null;
		leadRecord.AW_CreditBureauAddress2PostalCode__c = null;
		leadRecord.AW_CreditBureauAddress2ProvinceCode__c = null;
		leadRecord.AW_CreditBureauAddress2Province__c = null;
		leadRecord.AW_CreditBureauAddress2Suburb__c = null;
		leadRecord.AW_CreditBureauAlternativeEmail__c = null;
		leadRecord.AW_CreditBureauCellNumber__c = null;
		leadRecord.AW_CreditBureauCreditScore__c = null;
		leadRecord.AW_CreditBureauDeceasedDate__c = null;
		leadRecord.AW_CreditBureauDependants__c = null;
		leadRecord.AW_CreditBureauEmployer1__c = null;
		leadRecord.AW_CreditBureauEmployer2__c = null;
		leadRecord.AW_CreditBureauEstimatedNetIncome__c = null;
		leadRecord.AW_CreditBureauForename1__c = null;
		leadRecord.AW_CreditBureauForename2__c = null;
		leadRecord.AW_CreditBureauForename3__c = null;
		leadRecord.AW_CreditBureauGender__c = null;
		leadRecord.AW_CreditBureauMaritalStatus__c = null;
		leadRecord.AW_CreditBureauOccupation1__c = null;
		leadRecord.AW_CreditBureauOccupation2__c = null;
		leadRecord.AW_CreditBureauSpouseName1__c = null;
		leadRecord.AW_CreditBureauSpouseName2__c = null;
		leadRecord.AW_CreditBureauSupplier10__c = null;
		leadRecord.AW_CreditBureauSupplier11__c = null;
		leadRecord.AW_CreditBureauSupplier12__c = null;
		leadRecord.AW_CreditBureauSupplier1__c = null;
		leadRecord.AW_CreditBureauSupplier2__c = null;
		leadRecord.AW_CreditBureauSupplier3__c = null;
		leadRecord.AW_CreditBureauSupplier4__c = null;
		leadRecord.AW_CreditBureauSupplier5__c = null;
		leadRecord.AW_CreditBureauSupplier6__c = null;
		leadRecord.AW_CreditBureauSupplier7__c = null;
		leadRecord.AW_CreditBureauSupplier8__c = null;
		leadRecord.AW_CreditBureauSupplier9__c = null;
		leadRecord.AW_CreditBureauSurname__c = null;
		leadRecord.AW_CreditBureauTelephoneNumber__c = null;
		leadRecord.AW_CreditBureauTenure1__c = null;
		leadRecord.AW_CreditBureauTenure2__c = null;
		leadRecord.AW_CreditBureauTitle__c = null;
		leadRecord.AW_CreditBureauConsent__c = false;
		leadRecord.AW_CreditBureauCallStatus__c = CALL_STATUS_NONE;
		leadRecord.AW_CreditBureauLastCallDateTime__c = System.now();
		leadRecord.AW_CreditBureauRequestStatusMessage__c = null;

		CMN_DAL_SObjectDomain.updateDBObject(leadRecord);
	}

	/**
	 * @description Used to retrieve current user record
	 *
	 * @return Returns user detail
	 */
	@AuraEnabled(Cacheable=true)
	public static User getCurrentUser()
	{
		return AW_DAL_User.getCurrentUser();
	}

	/**
	 * @description Used to retrieve lead record
	 *
	 * @param leadId lead record Id
	 *
	 * @return Returns lead record
	 */
	@AuraEnabled(Cacheable=true)
	public static Lead getLeadRecord(Id leadId)
	{
		return AW_DAL_Lead.findById(leadId);
	}

	/**
	 * @description Provides the outcome of the request
	 */
	public class DTO_Response
	{
		/**
		 * @description Indicates whether the API Callout was successful or not
		 */
		@AuraEnabled
		public Boolean callSuccessful;
		/**
		 * @description Will hold callout response
		 */
		@AuraEnabled
		public String responseMessage;
	}
}