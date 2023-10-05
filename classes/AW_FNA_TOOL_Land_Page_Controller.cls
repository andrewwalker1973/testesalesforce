/**
 * @description This class is the apex controller for Lightning Component hosting the FNA Tool land Page named
 * 			AW_FNA_TOOL_Land_Page
 *
 * @see AW_TEST_FNA_TOOL_Land_Page_Controller
 *
 * @author Thirugnana Sambandam
 *
 * @date November 2020
 **/
public with sharing class AW_FNA_TOOL_Land_Page_Controller
{
	/**
	 * @description This aura enabled method returns the id of the account which is linked to
	 * 				fnaID received in parameter.
	 *
	 * @param fnaId The fna Id
	 *
	 * @return The id of the account which is linked to fnaID received in parameter.
	 **/
	@AuraEnabled(Cacheable=true)
	public static Id getAccountId(String fnaId)
	{
		return AW_DAL_FNA.findByFnaId(fnaId)?.AW_Account__c;
	}
}