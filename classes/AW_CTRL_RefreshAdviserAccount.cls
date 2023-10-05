/**
 * @description Controller Class for awLwcMasterAccountDetails
 *
 * @see AW_CTRL_RefreshAdviserAccount_TEST @story AW-434365
 *
 * @author jason.van.beukering@accenture.com, pavan.t@lntinfotech.com
 *
 * @date July 2023
 */
public inherited sharing class AW_CTRL_RefreshAdviserAccount
{
	/**
	 * @description this method returns true if  account has financial accounts or insurance policies
	 *
	 * @param accountId Id of the account record
	 *
	 * @return A boolean variable to indicate account has policies or not
	 */
	@AuraEnabled(Cacheable=true)
	public static Boolean checkForAccountPolicies(Id accountId)
	{
		Account foundAccount = AW_DAL_Account.findByIdWithPolicyDetails(new Set<Id> {accountId}).iterator().next();
		if(!foundAccount.FinServ__ClientFinancialAccounts__r.isEmpty() || !foundAccount.Insurance_Policies__r.isEmpty())
		{
			return true;
		}

		return false;
	}
	/**
	 * @description this method returns list of CMN_CTRL_FieldSet.DTO_FieldSetMember
	 *
	 * @param accountIds Id of the account record and its parent record
	 *
	 * @return List of CMN_CTRL_FieldSet.DTO_FieldSetMember
	 */
	@AuraEnabled
	public static Map<Id, Map<String, List<CMN_CTRL_FieldSet.DTO_FieldSetMember>>> getFieldDetailsForRecord(List<Id> accountIds)
	{
		Map<Id, List<String>> recordIdToFieldSetListMap = new Map<Id, List<String>>();

		for(Id accountId : accountIds)
		{
			recordIdToFieldSetListMap.put(accountId, AW_DAL_Account.ACCOUNT_FIELD_SETS);
		}
		return CMN_CTRL_FieldSet.getFieldSetsForRecord(recordIdToFieldSetListMap);
	}

	/**
	 * @description Will retrieve and update the child account with selected fields from parent account
	 *
	 * @param selectedFields list of selected fields from parent account
	 * @param parentAccountId The Id of the parent account which needs to be retrieved
	 * @param childAccountId The Id of the child account which needs to be updated
	 */
	@AuraEnabled
	public static void updateChildAccount(List<String> selectedFields, Id parentAccountId, Id childAccountId)
	{
		if(String.isNotBlank(parentAccountId) && String.isNotBlank(childAccountId) && !selectedFields.isEmpty())
		{
			Account foundAccountParent = AW_DAL_Account.findByIdWithoutSharing(parentAccountId, new Set<String>(selectedFields));

			if(foundAccountParent != null)
			{
				Account updateAccountChild = new Account(Id = childAccountId);

				for(String fieldAPIName : selectedFields)
				{
					updateAccountChild.put(fieldAPIName, foundAccountParent.get(fieldAPIName));
				}

				CMN_DAL_SObjectDomain.updateDBObject(updateAccountChild);
			}
		}
	}
}