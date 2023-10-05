/**
 * @description An apex class that create a portal user
 *
 * @author Accenture
 *
 * @date 2019
 */
public with sharing class AW_CTR_SiteRegister
{
	// PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
	// you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.
	private static Id PORTAL_ACCOUNT_ID = '001x000xxx35tPN';

	/**
	 * @description This is the constructor
	 */
	public AW_CTR_SiteRegister()
	{
	}

	public String username { get; set; }
	public String email { get; set; }
	public String password { get; set {password = value == null ? value : value.trim();} }
	public String confirmPassword { get; set {confirmPassword = value == null ? value : value.trim();} }
	public String communityNickname { get; set {communityNickname = value == null ? value : value.trim();} }

	private Boolean isValidPassword()
	{
		return password == confirmPassword;
	}

	/**
	 * @description Code we will invoke on page load
	 *
	 * @return null
	 */
	public PageReference registerUser()
	{
		// it's okay if password is null - we'll send the user a random password in that case
		if(!isValidPassword())
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Site.passwords_dont_match);
			ApexPages.addMessage(msg);
			return null;
		}

		User u = new User();
		u.Username = username;
		u.Email = email;
		u.CommunityNickname = communityNickname;

		String accountId = PORTAL_ACCOUNT_ID;

		// lastName is a required field on user, but if it isn't specified, we'll default it to the username
		String userId = Site.createPortalUser(u, accountId, password);
		if(userId != null)
		{
			if(password != null && password.length() > 1)
			{
				return Site.login(username, password, null);
			}
			else
			{
				PageReference page = System.Page.AW_VF_SiteRegisterConfirm;
				page.setRedirect(true);
				return page;
			}
		}
		return null;
	}
}