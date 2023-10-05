/**
 * @description An apex page controller that takes the user to the right start page based on credentials or lack thereof
 *
 * @author Accenture
 *
 * @date 2019
 */
public with sharing class AW_CTR_CommunitiesLanding
{

	/**
	 * @description Code we will invoke on page load.
	 *
	 * @return Network.communitiesLanding
	 */
	public PageReference forwardToStartPage()
	{
		return Network.communitiesLanding();
	}

	/**
	 * @description Constructor
	 */
	public AW_CTR_CommunitiesLanding()
	{
	}
}