/**
 * @description Controller for retrieving all Communication logs for the cases related to Account
 *
 * @see RSC_CTRL_ViewCommunicationLogs_TEST @story ST-259693
 *
 * @author jayanth.kumar.s@accenture.com jason.van.beukering@accenture.com
 *
 * @date February 2022
 */
public inherited sharing class RSC_CTRL_ViewCommunicationLogs
{
	/**
	 * @description Will retrieve all cases related to given account Id
	 *
	 * @param accountId The Id of the account to which the case is associated to
	 *
	 * @return list of found Cases
	 */
	@AuraEnabled(Cacheable=true)
	public static List<Case> getCases(Id accountId)
	{
		return SC_DAL_Case.findByAccountId(accountId);
	}

	/**
	 * @description Will retrieve all communication logs related to given caseIds
	 *
	 * @param caseIds The Cases from which the communication log has to be found
	 *
	 * @return list of found Communication log records
	 */
	@AuraEnabled(Cacheable=true)
	public static List<CMN_CommunicationLog__c> getCommunicationLogs(List<Id> caseIds)
	{
		return CMN_DAL_CommunicationLog.findByCaseId(new Set<Id> (caseIds));
	}
}