/**
 * @author Accenture
 * @description An apex page controller that exposes the site login functionality
 * @date 2019
 */

global with sharing class AW_CTR_CommunitiesLogin
{

	/**
	 * @description Class constructor
	 */
	global AW_CTR_CommunitiesLogin()
	{
	}

	/**
	 * @description Code we will invoke on page load
	 *
	 * @return forwardToAuthPage
	 */
	global PageReference forwardToAuthPage()
	{
		String startUrl = System.currentPageReference().getParameters().get('startURL');
		String displayType = System.currentPageReference().getParameters().get('display');

		return Network.forwardToAuthPage(startUrl, displayType);
	}
}