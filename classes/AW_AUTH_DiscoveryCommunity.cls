/**
 * @description We no longer use this class; but salesforce keeps a reference to it once used in community
 * 			The NetworkDiscoverableLogin object is created when Login Discovery Page is selected as the login page type on the Login & Registration (L&R) page.
 * 			If you later switch to another login page type, such as a Visualforce Page or Community Builder Page, the object isn’t deleted.
 * 				This means you can’t delete the Apex class associated with the NetworkDiscoverableLogin object.
 * 				To delete the Apex class, return to the L&R page and change the login page type back to Login Discovery page.
 * 				Select another Apex class, and then you can delete the first one.
 *
 * @author Accenture
 *
 * @date 2019
 */
global class AW_AUTH_DiscoveryCommunity implements Auth.LoginDiscoveryHandler
{

	/**
	 * @description NA
	 *
	 * @param identifier
	 * @param startUrl
	 * @param requestAttributes
	 *
	 * @return
	 */
	global PageReference login(String identifier, String startUrl, Map<String, String> requestAttributes)
	{
		return null;
	}
}