/**
 * @description Public class to return the records of Financial Account Role
 *
 * @author bhaskar.arora@accenture.com jayanth.kumar.s@accenture.com
 *
 * @date 2021, July 2022
 */
public inherited sharing class AW_DAL_FinancialAccountRole
{
	private static final String FIELD_FINANCIAL_ACCOUNT_ID = 'FinServ__FinancialAccount__r.Id';
	private static final String FIELD_PRIMARY_OWNER_ID = 'FinServ__FinancialAccount__r.FinServ__PrimaryOwner__r.Id';
	@TestVisible
	private static final String FIELD_ROLE = FinServ__FinancialAccountRole__c.FinServ__Role__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = FinServ__FinancialAccountRole__c.SObjectType.getDescribe().getLocalName();

	/**
	 * @description The name of the  owner role used when linking party to a financial account
	 */
	public static final String PICK_OWNER = 'Owner';
	/**
	 * @description The name of the Consultant role used when linking party to a financial account
	 */
	public static final String PICK_FINANCIAL_ADVISOR = 'Consultant';
	/**
	 * @description The default record type used being used by workbench application when creating financial account roles
	 */
	public static final String RT_LIBERTY_FINANCIAL_ACCOUNT_ROLE = 'AW_LibertyFinancialAccountRole';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FinServ__FinancialAccountRole__c.AW_RoleDOB__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.AW_RoleFirstName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.AW_RoleIdentificationNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.AW_RoleInitials__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.AW_RoleLastName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.AW_RoleTitle__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_ConsultantCode__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_CountryOfCitizenship__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_CountryOfIncorporation__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_CountryOfIssue__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_DateOfIncorporation__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_Email__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_ExpiryDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_FifthName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_FourthName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_Gender__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_IssueDate__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_MaritalStatus__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_Mobile__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_OccupationRiskCategory__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_Occupation__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_OrganisationType__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_OrganizationName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_PassportNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_PercentageSplit__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_PhoneNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_Race__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_RegistrationNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_RelationshipToLifeAssured__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_RelationshipToOwner__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_SecondName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_Suffix__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_ThirdName__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_WeddingAnniversary__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.CMN_WorkPhoneNumber__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.FinServ__Active__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.FinServ__RelatedContact__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.FinServ__Role__c.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.Id.getDescribe().getLocalName(),
				FinServ__FinancialAccountRole__c.RecordTypeId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method to retrieve Financial Account Roles based on account linked to related Financial Account and Role
	 *
	 * @param accountId the Id of account linked to Related Financial Account
	 * @param roles the roles for which records are being queried
	 *
	 * @return A list of Financial Account Roles
	 */
	public static List<FinServ__FinancialAccountRole__c> findByAccountIdAndRole(Id accountId, List<String> roles)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_PRIMARY_OWNER_ID, new Set<String> {accountId}, getDefaultFields());
		searchParameters.searchConditions.inX(FIELD_ROLE, roles);

		return CMN_DAL_Search.getObjects(searchParameters);

	}

	/**
	 * @description Method to retrieve Financial Account Roles based on PolicyID and Array of Roles
	 *
	 * @param policyId the Id of account linked to Related Financial Account
	 * @param roles the role for which records are being queried
	 *
	 * @return A list of items
	 */
	public static List<FinServ__FinancialAccountRole__c> findByPolicyIdAndListOfRoles(Id policyId, List<String> roles)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_FINANCIAL_ACCOUNT_ID, new Set<String> {policyId}, getDefaultFields());
		searchParameters.searchConditions.inX(FIELD_ROLE, roles);
		return CMN_DAL_Search.getObjects(searchParameters);
	}
}