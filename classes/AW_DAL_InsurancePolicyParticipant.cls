/**
 * @description Public class to return the records of Insurance Policy Participant
 *
 * @author jayanth.kumar.s@accenture.com rajpal.singh@accenture.com
 *
 * @date 2021, October 2022
 */
public inherited sharing class AW_DAL_InsurancePolicyParticipant
{
	private static final String FIELD_INSURANCE_POLICY_ID = 'InsurancePolicyId';
	private static final String FIELD_NAME_INSURED_ID = 'InsurancePolicy.NameInsured.Id';
	@TestVisible
	private static final String FIELD_ROLE = InsurancePolicyParticipant.Role.getDescribe().getLocalName();
	private static final String OBJECT_NAME = InsurancePolicyParticipant.SObjectType.getDescribe().getLocalName();

	/**
	 * @description The primary life assured for a policy
	 */
	public static final String PRIMARY_LIFE_ASSURED = 'Primary Life Assured';
	/**
	 * @description The primary life assured's beneficiary of a policy
	 */
	public static final String PRIMARY_LIFE_ASSURED_BENEFICIARY = 'Primary Life Assured Beneficiary';
	/**
	 * @description The secondary life assured for a policy
	 */
	public static final String SECONDARY_LIFE_ASSURED = 'Secondary Life Assured';
	/**
	 * @description The secondary's life assured beneficiary
	 */
	public static final String SECONDARY_LIFE_ASSURED_BENEFICIARY = 'Secondary Life Assured Beneficiary';

	/**
	 * @description Used when linking Insurance Policy Participants to a Insurance Policy
	 */
	@TestVisible
	private static final String LIFE_ASSURED_ROLE_TYPES = PRIMARY_LIFE_ASSURED + ','
			+ PRIMARY_LIFE_ASSURED_BENEFICIARY + ',' + SECONDARY_LIFE_ASSURED + ',' + SECONDARY_LIFE_ASSURED_BENEFICIARY;
			
	/**
	 * @description The record type is being used when creating Insurance Policy Participant records
	 */
	public static final String RT_LIBERTY_INSURANCE_POLICY_PARTICIPANT = 'CMN_LibertyInsurancePolicyParticipant';

	/**
	 * @description Method to set the fields using Insurance Policy Participants
	 *
	 * @return A set of the standard fields used by queries when returning Insurance Policy Participants
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_INSURANCE_POLICY_ID,
				FIELD_ROLE,
				InsurancePolicyParticipant.AW_ConsultantCode__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_DateofBirth__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_FirstName__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_Gender__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_IdentificationNumber__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_Initials__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_LastName__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_MaritalStatus__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_Occupation__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_PDBID__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_PercentageSplit__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_RelationshipToLifeAssured__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_RoleCode__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_Salutation__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.AW_SecondName__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_CountryOfCitizenship__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_CountryOfIncorporation__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_CountryOfIssue__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_DateOfIncorporation__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_Email__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_ExpiryDate__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_FifthName__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_FourthName__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_ImmediateExpenseBenefit__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_IssueDate__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_Mobile__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_OccupationRiskCategory__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_OrganisationType__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_OrganizationName__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_PassportNumber__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_PhoneNumber__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_PreferredLanguage__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_Qualification__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_Race__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_RegistrationNumber__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_RelationshipToOwner__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_Smoker__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_SouthAfricanResidentIndicator__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_Suffix__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_ThirdName__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_WeddingAnniversary__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.CMN_WorkPhoneNumber__c.getDescribe().getLocalName(),
				InsurancePolicyParticipant.RelatedParticipantContactId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method to retrieve Insurance Policy Participant based on account linked to related Insurance Policy and Role
	 *
	 * @param accountId the Id of account linked to Related Insurance Policy
	 * @param roles the roles for which records are being queried
	 *
	 * @return A list of Insurance Policy Participants
	 */
	public static List<InsurancePolicyParticipant> findByAccountIdAndRole(String accountId, List<String> roles)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_NAME_INSURED_ID, new Set<String> {accountId}, getDefaultFields());
		searchParameters.searchConditions.inX(FIELD_ROLE, roles);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Method to retrieve Financial Account Roles based on PolicyID and Array of Roles
	 *
	 * @param policyId the Id of insurance policy
	 * @param roles the list of roles for which records are being queried
	 *
	 * @return A list of Insurance Policy Participants
	 */
	public static List<InsurancePolicyParticipant> findByPolicyIdAndListOfRoles(Id policyId, List<String> roles)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_INSURANCE_POLICY_ID, new Set<String> {policyId}, getDefaultFields());
		searchParameters.searchConditions.inX(FIELD_ROLE, roles);
		return CMN_DAL_Search.getObjects(searchParameters);
	}
}