/**
 * @description Used by Lightning Component to retrieve the atWork URL
 *
 * @see AW_TEST_CTR_GetAtWorkURL @story ST-2374
 * @see AW_API_RestOutboundGetAtWorkURL
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date November 2021
 */
public inherited sharing class AW_CTR_GetAtWorkURL
{
	private static final String ERROR_UNEXPECTED = 'An unexpected error occurred.';

	/**
	 * @description Returns an "secure" Url which can be used to access atWork
	 *
	 * @param recordId Either an Opportunity or Account Id
	 * @param atWorkUserId The atWork User Identifier
	 *
	 * @return A Dto which will indicate if call was successful and either an error message or url
	 */
	@AuraEnabled
	public static DTO_GetAtWorkUrlResponse getAtWorkURL(Id recordId, String atWorkUserId)
	{
		Id accountId;

		accountId = getAccountId(recordId);

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundGetAtWorkURL.SERVICE_NAME, accountId);
		queueItem.CMN_SourceID__c = atWorkUserId;

		List<CMN_API_HttpBase> webserviceHandlers = CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});

		AW_API_RestOutboundGetAtWorkURL urlHandler = (AW_API_RestOutboundGetAtWorkURL)webserviceHandlers.iterator().next();

		CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult = urlHandler.callResult;

		DTO_GetAtWorkUrlResponse dtoResponse = new DTO_GetAtWorkUrlResponse();

		//There is a scenario where atWork does not throw an HTTP error response (i.e. 200) but the call actually has failed
		dtoResponse.callSuccessful = callResult.completed && urlHandler.success;

		if(callResult.completed)
		{
			//Call may complete; i.e. HTTP response 200, but atWork has returned an error response
			dtoResponse.secureUrlOrErrorMessage = dtoResponse.callSuccessful ? urlHandler.secureUrl : urlHandler.message;
		}
		else
		{
			//If we get here the call failed; i.e. HTTP response was not 200, therefore return error captured
			dtoResponse.secureUrlOrErrorMessage = callResult.errors.size() > 0 ? CMN_UTIL_String.joinStrings(callResult.errors, CMN_UTIL_String.LF) : ERROR_UNEXPECTED;
		}

		//If we do have a successful response, make sure we update the user record with the atWork username
		if(dtoResponse.callSuccessful)
		{
			Account foundAccount = AW_DAL_Account.findById(accountId);

			User updateUser = new User();

			updateUser.Id = foundAccount.OwnerId;
			updateUser.AW_AtWorkUsername__c = atWorkUserId;

			//Bypass sharing as the user executing this method (such as a PA) may not have access to the user record normally
			new UserUpdateProxy().updateUser(updateUser);
		}

		return dtoResponse;
	}

	/**
	 * @description Retrieves the Account Owner User record
	 *
	 * @param recordId Id of the Account or Opportunity record
	 *
	 * @return User record of the Account Owner (could be null if the accountId is invalid)
	 */
	@AuraEnabled(Cacheable=true)
	public static User getUserDetails(String recordId)
	{
		Id accountId = getAccountId(recordId);
		Account foundAccount = AW_DAL_Account.findById(accountId);
		return AW_DAL_User.findById(foundAccount?.OwnerId);
	}

	/**
	 * @description Will retrieve the account id from a record id which maybe be an account or opportunity
	 *
	 * @param recordId Id of the Account or Opportunity record
	 *
	 * @return Returns the related account record from opportunity if opportunity record is passed
	 */
	private static Id getAccountId(Id recordId)
	{
		Id accountId = recordId;
		if(Opportunity.SObjectType == CMN_UTIL_System.getSObjectTypeById(recordId))
		{
			//getting the current Account record linked to this opportunity
			accountId = AW_DAL_Opportunity.findById(recordId)?.AccountId;
		}
		return accountId;
	}

	/**
	 * @description Retrieves base login URL for atWork
	 *
	 * @return Returns the base login URL for atWork from named credentials
	 */
	@AuraEnabled
	public static String getBaseUrl()
	{
		AW_API_RestOutboundGetAtWorkURL service = new AW_API_RestOutboundGetAtWorkURL();
		return service.getBaseUrl();
	}

	/**
	 * @description Nested class use to bypass sharing for updating user record
	 */
	private without sharing class UserUpdateProxy
	{
		private void updateUser(User updateUser)
		{
			update updateUser;
		}
	}

	/**
	 * @description Provides the outcome of the get Secure atWork URL
	 */
	public class DTO_GetAtWorkUrlResponse
	{
		@AuraEnabled
		public Boolean callSuccessful;
		@AuraEnabled
		public String secureUrlOrErrorMessage;
	}
}