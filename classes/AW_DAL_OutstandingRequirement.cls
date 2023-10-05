/**
 * @description Public class to return the records of Outstanding Requirement
 *
 * @author Accenture, vishakha.saini@accenture.com
 *
 * @date May 2021, March 2023
 */
public inherited sharing class AW_DAL_OutstandingRequirement
{
	public static final String OBJECT_NAME = AW_Outstanding_Requirement__c.SObjectType.getDescribe().getLocalName();
	/**
	 * @description API Name of the field UpdateIsn
	 */
	public static final String FIELD_UPDATE_ISN = AW_Outstanding_Requirement__c.AW_UpdateISN__c.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most queries
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_Outstanding_Requirement__c.AW_Account__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_ContractNumber__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_Description__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_IdentityNumber__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_Key__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_MasterAccount__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_Opportunity__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_Pinball_Code__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_RequirementDate__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_Role__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_Source__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_Status__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.AW_UpdateISN__c.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.Id.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.Name.getDescribe().getLocalName(),
				AW_Outstanding_Requirement__c.OwnerId.getDescribe().getLocalName(),
				FIELD_UPDATE_ISN
		};
	}

	/**
	 * @description This method is use to get a OustandingRequirement with the particular Id
	 *
	 * @param outstandingRequirementId The Id of the AW_Outstanding_Requirement__c
	 *
	 * @return A single AW_Outstanding_Requirement__c
	 */
	public static AW_Outstanding_Requirement__c findById(Id outstandingRequirementId)
	{
		return (AW_Outstanding_Requirement__c)CMN_DAL_SObjectSelector.findById(AW_Outstanding_Requirement__c.SObjectType, outstandingRequirementId, getDefaultFields());
	}

	/**
	 * @description Method to get the list of Outstanding Requirements by Owner
	 *
	 * @param ownerId The owner to filter the items by
	 *
	 * @return List of items
	 */
	public static List<AW_Outstanding_Requirement__c> findByOwnerId(Id ownerId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_OWNER_ID, new Set<Id> {ownerId}, getDefaultFields());
	}

	/**
	 * @description return all Outstanding requirements created by test classes
	 *
	 * @return A list of items
	 */
	@TestVisible
	private static List<AW_Outstanding_Requirement__c> getAll()
	{
		return CMN_DAL_Search.getAll(AW_Outstanding_Requirement__c.SObjectType, getDefaultFields());
	}
}