/**
 * @description Base class for all trigger handlers that must be able to link their rows to a master account and set owner to master account owner
 * It will contain base code that can be reused in descendant triggers to do the linking
 *
 * @see AW_TH_BaseLinkToMaster_TEST
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date May 2021, February 2023
 */
public inherited sharing virtual class AW_TH_BaseLinkToMaster extends CMN_TRH_BaseObject
{
	/**
	 * @description The master account lookup API name
	 */
	private static final String FIELD_MASTER_ACCOUNT_LOOKUP = 'AW_MasterAccount__c';
	/**
	 * @description The API name of the cross object formula field which gets the Id of the master account for the linked account
	 */
	private static final String FIELD_MASTER_ACCOUNT_ID_FORMULA = 'AW_MasterAccountId__c';

	/**
	 * @description Will return the name of the Master Account Lookup Field
	 *
	 * @return API field name of the master account lookup field
	 */
	protected virtual String getMasterAccountLookup()
	{
		return FIELD_MASTER_ACCOUNT_LOOKUP;
	}

	/**
	 * @description Will get the master account Id for the given object
	 *
	 * @param anObject A object that's needs to be linked to a master
	 *
	 * @return Master account Id or null
	 */
	protected virtual Id getMasterAccountId(SObject anObject)
	{
		CMN_UTIL_SObjectDescribe describeWrapper = CMN_UTIL_SObjectDescribe.getDescribe(anObject.getSObjectType());

		SObjectField masterAccountIdFormulaField = describeWrapper.getField(FIELD_MASTER_ACCOUNT_ID_FORMULA);

		Id masterAccountId;

		if(masterAccountIdFormulaField != null)
		{
			String masterAccountIdString = String.valueOf(anObject.get(masterAccountIdFormulaField.getDescribe().getLocalName()));
			masterAccountId = CMN_UTIL_String.validateId(masterAccountIdString);
		}

		return masterAccountId;
	}

	/**
	 * @description Will get the master account record type name if exists
	 *
	 * @param objects List of objects from which to extract master Id and get the master account details
	 *
	 * @return A map populated with items found
	 */
	protected Map<Id, Account> getMasterAccountDetails(List<SObject> objects)
	{
		Map<Id, Account> accountMap = new Map<Id, Account>();

		if(Trigger.isInsert || Trigger.isUpdate)
		{
			Set<Id> masterAccountIds = CMN_UTIL_System.extractListIds(objects, FIELD_MASTER_ACCOUNT_ID_FORMULA, true);
			accountMap.putAll(AW_DAL_Account.findById(masterAccountIds, new Set<String> {AW_DAL_Account.FIELD_RECORD_TYPE_NAME}));
		}

		return accountMap;
	}

	/**
	 * @description Will process an object given and set it's master account lookup
	 *
	 * @param so Object given
	 */
	private void setMasterAccountLookup(SObject so)
	{
		if(String.isNotBlank(getMasterAccountLookup()))
		{
			Id masterAccountId = getMasterAccountId(so);

			if(masterAccountId != null)
			{
				so.put(getMasterAccountLookup(), masterAccountId);
			}
		}
	}

	/**
	 * @description Will process an object given and set it's master account lookup
	 *
	 * @param so Object given
	 */
	public override virtual void beforeInsert(SObject so)
	{
		super.beforeInsert(so);
		setMasterAccountLookup(so);
	}

}