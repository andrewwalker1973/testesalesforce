/**
 * @author Accenture
 * @description An apex page controller that exposes the site login functionality
 * @date 2019
 */

global with sharing class AW_CTR_SiteLogin
{
	global String username { get; set; }
	global String password { get; set; }

	/**
	 * @description global method to load the login page
	 *
	 * @return site login
	 */
	global PageReference login()
	{
		String startUrl = System.currentPageReference().getParameters().get('startURL');
		return Site.login(username, password, startUrl);
	}

	/**
	 * @description NA
	 */
	global AW_CTR_SiteLogin()
	{
	}
}