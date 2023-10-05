/**
 * @description An apex page controller that supports self registration of users in communities that allow self registration
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_CTR_CommunitiesSelfReg
{

	public String firstName { get; set; }
	public String lastName { get; set; }
	public String email { get; set; }
	public String password { get; set {password = value == null ? value : value.trim();} }
	public String confirmPassword { get; set {confirmPassword = value == null ? value : value.trim();} }
	public String communityNickname { get; set {communityNickname = value == null ? value : value.trim();} }

	/**
	 * @description Class Constructor
	 */
	public AW_CTR_CommunitiesSelfReg()
	{
		String expid = ApexPages.currentPage().getParameters().get('expid');
		if(expid != null)
		{
			Site.setExperienceId(expid);
		}
	}

	/**
	 * @description Methos to check Passowrd
	 *
	 * @return
	 */
	private Boolean isValidPassword()
	{
		return password == confirmPassword;
	}

	/**
	 * @description Code we will invoke on page load for resgister the user in community
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

		String profileId = null; // To be filled in by customer.
		String accountId = CMN_UTIL_String.EMPTY; // To be filled in by customer.

		String userName = email;

		User u = new User();
		u.Username = userName;
		u.Email = email;
		u.FirstName = firstName;
		u.LastName = lastName;
		u.CommunityNickname = communityNickname;
		u.ProfileId = profileId;

		String userId;

		try
		{
			userId = Site.createExternalUser(u, accountId, password);
		}
		catch(Site.ExternalUserCreateException ex)
		{
			List<String> errors = ex.getDisplayMessages();
			for(String error : errors)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
			}

		}

		if(userId != null)
		{
			if(password != null && password.length() > 1)
			{
				return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
			}
			else
			{
				PageReference page = System.Page.AW_VF_CommunitiesSelfRegConfirm;
				page.setRedirect(true);
				return page;
			}
		}
		return null;
	}
}