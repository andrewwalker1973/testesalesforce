/**
 * @description Public class to return the records of Financial Account Role
 *
 * @see SC_DAL_FinancialAccountRole @story ST-225189
 *
 * @author aakriti.a.goyal@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date October 2022, February 2023
 */
public inherited sharing class SC_DAL_FinancialAccountRole
{
	private static final String FIELD_ACCOUNT_NAME = 'FinServ__FinancialAccount__r.Name';
	private static final String FIELD_ACCOUNT_NUMBER = 'FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c';
	private static final String FIELD_ACTIVE = FinServ__FinancialAccountRole__c.FinServ__Active__c.getDescribe().getLocalName();
	private static final String FIELD_FINANCIAL_ACCOUNT_SOURCE_SYSTEM = 'FinServ__FinancialAccount__r.CMN_PolicySourceSystem__c';
	private static final String FIELD_RELATED_ACCOUNT = FinServ__FinancialAccountRole__c.FinServ__RelatedAccount__c.getDescribe().getLocalName();
	private static final String FIELD_ROLE = FinServ__FinancialAccountRole__c.FinServ__Role__c.getDescribe().getLocalName();
	/**
	 * @description Variable used to store the Object API name
	 */
	public static final String OBJECT_NAME = FinServ__FinancialAccountRole__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description Variable to store the Relation To Life Assured Field API name
	 */
	public static final String FIELD_RELATION_TO_ASSURED = FinServ__FinancialAccountRole__c.CMN_RelationshipToLifeAssured__c.getDescribe().getLocalName();
	/**
	 * @description Parent Financial Account Field
	 */
	public static final String FIELD_PARENT = FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c.getDescribe().getLocalName();
	/**
	 * @description Constant used to identify the beneficiary role of the Financial Account
	 */
	public static final String ROLE_BENEFICIARY = 'Beneficiary';
	/**
	 * @description Constant used to identify the owner role of the Financial Account
	 */
	public static final String ROLE_OWNER = AW_DAL_FinancialAccountRole.PICK_OWNER;
	/**
	 * @description Primary Owner Role
	 */
	public static final String PRIMARY_OWNER_ROLE = 'Primary Owner';
	/**
	 * @description Set used to store the required roles for Beneficiary
	 */
	public static final Set<String> BENEFICIARY_ROLES = new Set<String>
	{
			SC_DAL_FinancialAccountRole.ROLE_BENEFICIARY,
			SC_DAL_FinancialAccountRole.ROLE_OWNER
	};
	/**
	 * @description Financial Account Role record type id that should be used
	 */
	public static final Id RT_LIBERTY_FINANCIAL_ACCOUNT_ROLE_ID =
			CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName
					(
							FinServ__FinancialAccountRole__c.SObjectType,
							AW_DAL_FinancialAccountRole.RT_LIBERTY_FINANCIAL_ACCOUNT_ROLE
					);

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_ACCOUNT_NAME,
				FIELD_ACCOUNT_NUMBER,
				FIELD_FINANCIAL_ACCOUNT_SOURCE_SYSTEM,
				FIELD_PARENT,
				FIELD_RELATION_TO_ASSURED,
				FinServ__FinancialAccountRole__c.AW_RoleDOB__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.AW_RoleFirstName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.AW_RoleIdentificationNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.AW_RoleInitials__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.AW_RoleLastName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_DateOfIncorporation__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_Email__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_FifthName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_FourthName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_Gender__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_MaritalStatus__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_Mobile__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_OrganizationName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_PDBID__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_PassportNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_PercentageSplit__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_PhoneNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_RegistrationNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_RelationshipToOwner__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_SecondName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_ThirdName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_WorkPhoneNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.FinServ__Active__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.FinServ__Role__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.RSC_PartyName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.RecordTypeId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Retrieves the Financial Account Role record by parent Ids and the role.
	 *
	 * @param parentRecordIds The recordId to which this item is associated
	 * @param role The role selected
	 *
	 * @return a list of items
	 */
	public static List<FinServ__FinancialAccountRole__c> findByParentIdAndRole(Set<Id> parentRecordIds, String role)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_PARENT, CMN_UTIL_System.convertIdSetToStringSet(parentRecordIds), getDefaultFields());
		searchParameters.searchConditions.equalsX(FIELD_ROLE, role);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Retrieves the Financial Account Role records by Parent Id.
	 *
	 * @param parentRecordIds The recordId to which this item is associated
	 *
	 * @return a list of FinServ__FinancialAccountRole__c
	 */
	public static List<FinServ__FinancialAccountRole__c> findByParentId(Set<Id> parentRecordIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PARENT, parentRecordIds, getDefaultFields());
	}


	/**
	 * @description Retrieves the inactive Financial Account Roles record by Parent Ids.
	 *
	 * @param parentIds The recordIds to which this item is associated
	 *
	 * @return a list of items
	 */
	public static List<FinServ__FinancialAccountRole__c> findInactiveByParentIds(Set<Id> parentIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.searchConditions.inX(FIELD_PARENT, CMN_UTIL_System.setToList(parentIds));
		searchParameters.searchConditions.equalsX(FIELD_ACTIVE, false);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Retrieves the Financial Account Role record by Parent Ids and the roles.
	 *
	 * @param parentRecordIds The recordIds to which this item is associated
	 * @param roles The selected roles
	 *
	 * @return a list of items
	 */
	public static List<FinServ__FinancialAccountRole__c> findByParentIdsAndRoles(Set<Id> parentRecordIds, Set<String> roles)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_PARENT, CMN_UTIL_System.convertIdSetToStringSet(parentRecordIds), getDefaultFields());
		searchParameters.searchConditions.inX(FIELD_ROLE, CMN_UTIL_System.setToList(roles));

		return CMN_DAL_Search.getObjects(searchParameters);
	}

}