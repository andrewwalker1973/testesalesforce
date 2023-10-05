/**
 * @description This class is used to update prospect response from the external systems
 *
 * @see CMN_FLOW_ProspectResponse_TEST
 *
 * @author Rohith Ballal (Deloitte), safwan.h.mohammed@accenture.com
 *
 * @date October 2020, June 2022
 */
public inherited sharing class CMN_FLOW_ProspectResponse
{
	/**
	 * @description Method to update a prospect based on response from external systems
	 *
	 * @param queueItems List of queue items
	 */
	@InvocableMethod(Label='Fetch and Update Prospect Response' Description='Method to update a prospect based on response from external systems')
	public static void updateProspect(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		String statusCompleted = 'Completed';
		List<Account> accountsList = new List<Account>();

		for(CMN_WebserviceCallQueue__c webCallQueue : queueItems)
		{
			Account updateAccount = new Account(Id = webCallQueue.CMN_TriggeringObjectId__c);

			if(webCallQueue.CMN_Status__c == statusCompleted)
			{
				updateAccount.AW_Synch_Error__c = false;
				updateAccount.AW_SyncErrorMessage__c=CMN_UTIL_String.EMPTY;
				updateAccount.AW_Last_Synch_Date__c = Datetime.now();

				if(webCallQueue.CMN_Response__c != null && webCallQueue.CMN_Response__c.contains('globalKey'))
				{
					Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(webCallQueue.CMN_Response__c);
					updateAccount.AW_SKF_Id__c = String.valueOf(m.get('globalKey'));
				}
			}
			else
			{
				updateAccount.AW_Synch_Error__c = true;
				updateAccount.AW_SyncErrorMessage__c = webCallQueue.CMN_Errors__c != null ?
						webCallQueue.CMN_Errors__c :
						((DTO_ErrorResponse)JSON.deserialize(webCallQueue.CMN_Response__c, DTO_ErrorResponse.class)).error.errorMessage;
			}
			accountsList.add(updateAccount);
		}

		CMN_DAL_SObjectDomain.updateDBObjects(accountsList);
	}
	/**
 * @description Used to parse an error response
 */
	private class DTO_ErrorResponse
	{
		public DTO_Error error;
	}

	/**
	 * @description Detail of error received
	 */
	private class DTO_Error
	{
		public String errorMessage;
	}
}