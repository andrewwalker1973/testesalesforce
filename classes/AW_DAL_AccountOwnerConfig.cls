/**
 * @description Advisor workbench specific methods not to be confused with common methods
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_AccountOwnerConfig
{
	private static final String MASTER_ACCOUNT_OWNER_INFO = 'AW_MasterAccountOwnerInfo';

	/**
	 * @description Will return the master account owner information
	 *
	 * @return nul or item
	 */
	public static AW_AccountOwnerConfig__mdt findMasterAccountOwnerInfo()
	{
		return AW_AccountOwnerConfig__mdt.getInstance(MASTER_ACCOUNT_OWNER_INFO);
	}
}