/**
 * @description Trigger handler for the trigger AW_TRG_FinancialAccount.
 *
 * @see AW_TEST_TH_FinancialAccount @story ST-2330
 *
 * @author jayanth.kumar.s@accenture.com, jason.van.beukering@accenture.com
 *
 * @date June 2021, December 2022
 */
public inherited sharing class AW_TH_FinancialAccount extends AW_TH_BaseLinkToMaster
{
	private Map<Id, Account> accountMap = new Map<Id, Account>();
	private Map<Id, SObject> userMap = new Map<Id, User>();
	private static Map<Id, Account> masterAccountToIdMap = new Map<Id, Account>();
	private static final List<FinServ__FinancialAccount__c> FINANCIAL_ACCOUNTS_TO_PROCESS = new List<FinServ__FinancialAccount__c>();
	private static final Set<Id> PRIMARY_OWNER_ID_TO_SHARE_WITH_ADVISER = new Set<Id>();
	private static final Set<Id> PRIMARY_OWNER_ID_TO_SHARE_WITH_CLIENT = new Set<Id>();
	private static final User CURRENT_USER = AW_DAL_User.getCurrentUser();

	/**
	 * @description Before trigger will get the current user information
	 */

	public override void bulkBefore()
	{
		super.bulkBefore();
		masterAccountToIdMap = getMasterAccountDetails(Trigger.new);
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so SObject that fired the trigger
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);

		FinServ__FinancialAccount__c newFinancialAccount = (FinServ__FinancialAccount__c)so;

		checkMustSetFinancialAccountOwner(null, newFinancialAccount);
		setMasterAccountRecordTypeName(newFinancialAccount);
	}

	/**
	 * @description Will check if the record needs the master record type name set (this is used for sharing rules)
	 *
	 * @param newFinancialAccount The current version of the financial account
	 */
	private static void setMasterAccountRecordTypeName(FinServ__FinancialAccount__c newFinancialAccount)
	{
		newFinancialAccount.CMN_MasterAccountRecordTypeName__c =
				masterAccountToIdMap.get(newFinancialAccount.AW_MasterAccount__c)?.RecordType.DeveloperName;
	}

	/**
	 * @description Context method overrides will be called before update of Object.
	 *
	 * @param oldSo old version of the Sobject that fired the trigger
	 * @param so new version of the record that fired the trigger
	 */
	public override void beforeUpdate(SObject oldSo, SObject so)
	{
		super.beforeUpdate(oldSo, so);

		FinServ__FinancialAccount__c newFinancialAccount = (FinServ__FinancialAccount__c)so;
		FinServ__FinancialAccount__c oldFinancialAccount = (FinServ__FinancialAccount__c)oldSo;

		checkMustSetFinancialAccountOwner(oldFinancialAccount, newFinancialAccount);
		setMasterAccountRecordTypeName(newFinancialAccount);
	}

	/**
	 * @description Context method overrides will be called after the end of trigger executions .
	 */
	public override void andFinally()
	{
		super.andFinally();

		//If we have determined that we accounts to set owner on, then run build maps so that we can
		if(!FINANCIAL_ACCOUNTS_TO_PROCESS.isEmpty())
		{
			//Only retrieve adviser user information if necessary
			if(!PRIMARY_OWNER_ID_TO_SHARE_WITH_ADVISER.isEmpty())
			{
				accountMap = new Map<Id, Account>(AW_DAL_Account.findById(PRIMARY_OWNER_ID_TO_SHARE_WITH_ADVISER));
			}

			//Only retrieve client user information if necessary
			if(!PRIMARY_OWNER_ID_TO_SHARE_WITH_CLIENT.isEmpty())
			{
				userMap = CMN_UTIL_System.convertListToSingleMap(AW_DAL_User.findByAccountId(PRIMARY_OWNER_ID_TO_SHARE_WITH_CLIENT), CMN_DAL_User.FIELD_ACCOUNT_ID);
			}

			for(FinServ__FinancialAccount__c financialAccountToProcess : FINANCIAL_ACCOUNTS_TO_PROCESS)
			{
				setFinancialAccountOwner(financialAccountToProcess);
			}
		}
	}

	private static void checkMustSetFinancialAccountOwner(FinServ__FinancialAccount__c oldFinancialAccount, FinServ__FinancialAccount__c newFinancialAccount)
	{
		//We can't set owner to adviser or client unless primary owner field is set.
		if(newFinancialAccount.FinServ__PrimaryOwner__c != null)
		//For  new items always set the owner
		//Only change the owner if the sharing flag changes.
		{
			if(oldFinancialAccount == null || oldFinancialAccount.AW_ShareWithMyAdviser__c != newFinancialAccount.AW_ShareWithMyAdviser__c)
			{
				FINANCIAL_ACCOUNTS_TO_PROCESS.add(newFinancialAccount);

				if(newFinancialAccount.AW_ShareWithMyAdviser__c)
				{
					PRIMARY_OWNER_ID_TO_SHARE_WITH_ADVISER.add(newFinancialAccount.FinServ__PrimaryOwner__c);
				}
				else
				{
					PRIMARY_OWNER_ID_TO_SHARE_WITH_CLIENT.add(newFinancialAccount.FinServ__PrimaryOwner__c);
				}

			}
			if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(CURRENT_USER.Profile.Name))
			{
				newFinancialAccount.OwnerId = newFinancialAccount.AW_ParentAccountOwnerId__c;
			}
		}
	}

	private void setFinancialAccountOwner(FinServ__FinancialAccount__c newFinancialAccount)
	{
		//Only change the owner  if the financial account should be shared with an Adviser (usually  the owner of the client's account)
		if(newFinancialAccount.AW_ShareWithMyAdviser__c)
		{
			//Set the Financial Account Owner to the Owner  of the related Primary Owner Account
			Account foundAccount = accountMap.get(newFinancialAccount.FinServ__PrimaryOwner__c);

			if(foundAccount != null)
			{
				newFinancialAccount.OwnerId = foundAccount.OwnerId;
			}
		}
		else
		{
			//If we find an associated community  user then make the owner the community user
			SObject foundUser = userMap.get(newFinancialAccount.FinServ__PrimaryOwner__c);

			if(foundUser != null)
			{
				newFinancialAccount.OwnerId = foundUser.Id;
			}
		}
	}

	public override Boolean allowRecursion()
	{
		return false;
	}
}