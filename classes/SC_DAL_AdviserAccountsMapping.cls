/**
 * @description Public class to return the records of Adviser Account Mapping Metadata
 *
 * @author m.sudharkar.rokde@accenture.com jason.van.beukering@accenture.com
 *
 * @date February 2022
 */
public inherited sharing class SC_DAL_AdviserAccountsMapping
{
    /**
     * @description The specific custom metadata that should be used to determine account mapping
     */
    private static final String ACTIVE_PRACTICE_ACCOUNT = 'SC_ActiveAdviserName';

    /**
     * @description Will return the name of the Active Practice Account based on settings in metadata
     *
     * @return Name of the Account
     */
	public static String findActivePracticeAccountName()
	{
		return SC_AdviserAccountMapping__mdt.getInstance(ACTIVE_PRACTICE_ACCOUNT).MasterLabel;
	}

}