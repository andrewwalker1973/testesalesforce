/**
 * @description An apex page controller that exposes the site forgot password functionality
 *
 * @author Accenture
 *
 * @date 2019
 */
public with sharing class AW_CTR_ForgotPasswordController
{
	public String username { get; set; }

	/**
	 * @description Constructor
	 */
	public AW_CTR_ForgotPasswordController()
	{
	}

	/**
	 * @description Code we will invoke on page load
	 *
	 * @return boolean to check the forgot page has succesfully loaded
	 */
	public PageReference forgotPassword()
	{
		Boolean success = Site.forgotPassword(username);
		PageReference pr = Page.AW_VF_ForgotPasswordConfirm;
		pr.setRedirect(true);

		return success ? pr : null;
	}
}