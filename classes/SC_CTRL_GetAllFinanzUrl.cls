/**
 * @description Used by a Lightning Component to retrieve an Interview Url from the AllFinanz system,
 * will be used by Nurses during underwriting
 *
 * @see SC_CTRL_GetAllFinanzUrl_TEST
 * @see SC_API_GetAllFinanzUrl
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date August 2021
 */
public inherited sharing class SC_CTRL_GetAllFinanzUrl
{
	/**
	 * @description Will get an interview Url from AllFinanz
	 *
	 * @param identityNumber The Identification number of the client (could be either passport or national identification number)
	 * @param contractNumber The number of the contract being underwritten
	 *
	 * @return A dto indicating whether the call was successful and either interviewUrl or Error message
	 */
	@AuraEnabled
	public static DTO_Response getUrl(String identityNumber, String contractNumber)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SC_API_GetAllFinanzUrl.SERVICE_NAME);

		queueItem.CMN_ClientIDNumber__c = identityNumber;
		queueItem.CMN_PartnerIDNumber__c = contractNumber;

		SC_API_GetAllFinanzUrl service = (SC_API_GetAllFinanzUrl)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		DTO_Response dtoResponse = new DTO_Response();
		dtoResponse.callSuccessful = service.callResult.completed;
		dtoResponse.interviewUrlOrErrorMessage = dtoResponse.callSuccessful ? service.interviewUrl : service.errorMessage;

		return dtoResponse;
	}

	/**
	 * @description Provides the outcome of the request to AllFinanz to get an interview Url for a client
	 */
	public class DTO_Response
	{
		@AuraEnabled
		public Boolean callSuccessful;
		@AuraEnabled
		public String interviewUrlOrErrorMessage;
	}
}