/**
 * @description Used by Lightning Component to retrieve the Avalon URL
 *
 * @see AW_CTR_GetAvalonURL_TEST @story US-27805
 *
 * @author Wilmotte Lucien
 *
 * @date August 2020
 */
public inherited sharing class AW_CTR_GetAvalonURL
{
	@TestVisible
	private static final String URL_FORMAT = '{0}?clientid={1}&context=fna&uacfid={2}';
	/**
	 * @description Retrieves base login URL for avalon
	 *
	 * @param recordId Id of the Account or Opportunity record
	 *
	 * @return Returns the base login URL for avalon from custom settings
	 */
	@AuraEnabled(Cacheable=true)
	public static String getAvalonBaseUrl(Id recordId)
	{
		AW_embeddedURL__c avalonURL = AW_embeddedURL__c.getValues(AW_DAL_FNA.URL_NAME);
		String url = avalonURL.AW_External_Services__c;

		if(String.isNotBlank(recordId))
		{
			String skfId;
			String ownerUacfId;

			SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(recordId);

			if(Account.SObjectType == objectType)
			{
				Account foundAccount = AW_DAL_Account.findById(recordId);
				skfId = foundAccount?.AW_SKF_Id__c;
				ownerUacfId = foundAccount?.AW_Owner_UACFID__c;
			}
			else if(Opportunity.SObjectType == objectType)
			{
				Opportunity foundOpportunity = AW_DAL_Opportunity.findById(recordId);
				skfId = foundOpportunity?.Account?.AW_SKF_Id__c;
				ownerUacfId = foundOpportunity?.Account?.AW_Owner_UACFID__c;
			}

			url = String.isNotBlank(skfId) ? String.format(URL_FORMAT, new List<String> {url, skfId, ownerUacfId}) : url;
		}

		return url;
	}
}