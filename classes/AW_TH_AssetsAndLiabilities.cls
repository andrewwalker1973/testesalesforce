/**
 * @description Trigger handler for the trigger AW_TRG_AssetsAndLiabilities.
 *
 * @author Accenture
@story ST-2330
 */
public inherited sharing class AW_TH_AssetsAndLiabilities extends AW_TH_BaseLinkToMaster
{
	private List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesToProcess = new List<FinServ__AssetsAndLiabilities__c>();
	private Map<Id, Account> accountMap = new Map<Id, Account>();
	private Map<Id, SObject> userMap = new Map<Id, User>();
	private Set<Id> primaryOwnerIdsForSharingWithAdviser = new Set<Id>();
	private Set<Id> primaryOwnerIdsForSharingWithClient = new Set<Id>();
	private User currentUser = new User();

	/**
	 * @description Before trigger will get the current user information
	 */

	public override void bulkBefore()
	{
		super.bulkBefore();
		currentUser = AW_DAL_User.getCurrentUser();
	}

	/**
	 * @description Context method overrides will be called before insertion of Object.
	 *
	 * @param so
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);

		FinServ__AssetsAndLiabilities__c newAsset = (FinServ__AssetsAndLiabilities__c)so;

		checkMustSetOwner(null, newAsset);
	}

	/**
	 * @description Context method overrides will be called before updation of Object.
	 *
	 * @param oldSo
	 * @param so
	 */
	public override void beforeUpdate(SObject oldSo, SObject so)
	{
		super.beforeUpdate(oldSo, so);

		checkMustSetOwner((FinServ__AssetsAndLiabilities__c)oldSo, (FinServ__AssetsAndLiabilities__c)so);
	}

	/**
	 * @description Context method overrides will be called after the end of trigger executions.
	 */
	public override void andFinally()
	{
		super.andFinally();

		//If we have determined that we accounts to set owner on, then run build maps so that we can
		if(!assetsAndLiabilitiesToProcess.isEmpty())
		{
			//Only retrieve adviser user information if necessary
			if(!primaryOwnerIdsForSharingWithAdviser.isEmpty())
			{
				accountMap = new Map<Id, Account>(AW_DAL_Account.findById(primaryOwnerIdsForSharingWithAdviser));
			}

			//Only retrieve client user information if necessary
			if(!primaryOwnerIdsForSharingWithClient.isEmpty())
			{
				userMap = CMN_UTIL_System.convertListToSingleMap(AW_DAL_User.findByAccountId(primaryOwnerIdsForSharingWithClient), CMN_DAL_User.FIELD_ACCOUNT_ID);
			}

			for(FinServ__AssetsAndLiabilities__c financialAccountToProcess : assetsAndLiabilitiesToProcess)
			{
				setOwner(financialAccountToProcess);
			}
		}
	}
	/**
	 * @description Private method to set the owner of Assets and Libilities
	 *
	 * @param oldAssetAndLiability
	 * @param newAssetAndLiability
	 */
	private void checkMustSetOwner(FinServ__AssetsAndLiabilities__c oldAssetAndLiability, FinServ__AssetsAndLiabilities__c newAssetAndLiability)
	{
		//We can't set owner to adviser or client unless primary owner field is set.
		if(newAssetAndLiability.FinServ__PrimaryOwner__c != null)
		//For  new items always set the owner
		//Only change the owner if the sharing flag changes.
		{
			if(oldAssetAndLiability == null || oldAssetAndLiability.AW_ShareWithMyAdviser__c != newAssetAndLiability.AW_ShareWithMyAdviser__c)
			{
				assetsAndLiabilitiesToProcess.add(newAssetAndLiability);

				if(newAssetAndLiability.AW_ShareWithMyAdviser__c)
				{
					primaryOwnerIdsForSharingWithAdviser.add(newAssetAndLiability.FinServ__PrimaryOwner__c);
				}
				else
				{
					primaryOwnerIdsForSharingWithClient.add(newAssetAndLiability.FinServ__PrimaryOwner__c);
				}
			}
			if(AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(currentUser.Profile.Name))
			{
				newAssetAndLiability.OwnerId = newAssetAndLiability.AW_ParentAccountOwnerId__c;
			}
		}
	}

	/**
	 * @description Private method to set the owner.
	 *
	 * @param newAssetAndLiability
	 */
	private void setOwner(FinServ__AssetsAndLiabilities__c newAssetAndLiability)
	{
		//Only change the owner  if the financial account should be shared with an Adviser (usually  the owner of the client's account)
		if(newAssetAndLiability.AW_ShareWithMyAdviser__c)
		{
			//Set the Financial Account Owner to the Owner  of the related Primary Owner Account
			Account foundAccount = accountMap.get(newAssetAndLiability.FinServ__PrimaryOwner__c);

			if(foundAccount != null)
			{
				newAssetAndLiability.OwnerId = foundAccount.OwnerId;
			}
		}
		else
		{
			//If we find an associated community  user then make the owner the community user
			SObject foundUser = userMap.get(newAssetAndLiability.FinServ__PrimaryOwner__c);

			if(foundUser != null)
			{
				newAssetAndLiability.OwnerId = foundUser.Id;
			}
		}
	}

	public override Boolean allowRecursion()
	{
		return false;
	}
}