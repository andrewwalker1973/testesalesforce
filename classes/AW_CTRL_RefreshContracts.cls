/**
 * @description Controller to refresh contract
 *
 * @see AW_CTRL_RefreshContracts_TEST
 *
 * @author jayanth.kumar.s@accenture.com, jason.van.beukering@accenture.com
 *
 * @date May 2021, May 2023
 */
public inherited sharing class AW_CTRL_RefreshContracts
{
	private static final String SUCCESS_MESSAGE = 'Success';

	/**
	 * @description Will call the service to initiate refresh contract and get the information back
	 *
	 * @param accountId The Id of the account record for which to retrieve contracts
	 *
	 * @return DTO response which indicates the call was success or failed
	 */
	@AuraEnabled
	public static DTO_Response triggerRefreshContract(Id accountId)
	{
		List<String> errorMessages = new List<String>();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RefreshContracts.SERVICE_NAME, accountId);
		List<CMN_API_HttpBase> handlers = CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});
		AW_API_RefreshContracts refreshHandlers = (AW_API_RefreshContracts)handlers.iterator().next();

		if(!refreshHandlers.callResult.completed)
		{
			List<String> errors = refreshHandlers.callResult.errors;
			String errorMessage = String.join(errors, CMN_UTIL_String.LF);
			errorMessages.add(errorMessage);
		}

		DTO_Response dtoResponse = new DTO_Response();
		dtoResponse.callSuccessful = errorMessages.size() > 0 ? false : true;
		dtoResponse.callMessage = dtoResponse.callSuccessful ? SUCCESS_MESSAGE : errorMessages.iterator().next();

		return dtoResponse;
	}

	/**
	 * @description This method is used to update the policy refresh status and date on Account
	 *
	 * @param accountToUpdate The account to be updated
	 *
	 * @return A list containing the ids of the updated items
	 */
	@AuraEnabled
	public static List<String> accountToUpdate(List<Account> accountToUpdate)
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType> {Account.SObjectType});
		unitOfWork.registerDirty(accountToUpdate);
		unitOfWork.commitWork(false);

		return CMN_UTIL_System.extractListValues(accountToUpdate, CMN_DAL_SObjectDomain.FIELD_ID);
	}

	/**
	 * @description Provides the outcome of the API callout
	 */
	public class DTO_Response
	{
		/**
		 * @description stores API callout status
		 */
		@AuraEnabled
		public Boolean callSuccessful;
		/**
		 * @description stores API callout message
		 */
		@AuraEnabled
		public String callMessage;
	}
}