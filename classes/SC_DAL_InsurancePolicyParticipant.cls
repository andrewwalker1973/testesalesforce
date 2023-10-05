/**
 * @description Public class to return the records of Insurance Policy Participant
 *
 * @see InsurancePolicyParticipant
 *
 * @author aakriti.a.goyal@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date February 2023
 */
public inherited sharing class SC_DAL_InsurancePolicyParticipant
{
	private static final String FIELD_ACTIVE = InsurancePolicyParticipant.IsActiveParticipant.getDescribe().getLocalName();
	private static final String FIELD_INSURANCE_POLICY_NAME = 'InsurancePolicy.PolicyName';
	private static final String FIELD_INSURANCE_POLICY_NUMBER = 'InsurancePolicy.Name';
	private static final String FIELD_INSURANCE_POLICY_SOURCE_SYSTEM = 'InsurancePolicy.CMN_PolicySourceSystem__c';
	private static final String FIELD_ROLE = InsurancePolicyParticipant.Role.getDescribe().getLocalName();

	/**
	 * @description Variable used to store the Object API name
	 */
	public static final String OBJECT_NAME = InsurancePolicyParticipant.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description Variable to store the Relation To Life Assured Field API name
	 */
	@TestVisible
	private static final String FIELD_RELATION_TO_OWNER = InsurancePolicyParticipant.CMN_RelationshipToOwner__c.getDescribe().getLocalName();
	/**
	 * @description Parent Policy Id Field
	 */
	public static final String FIELD_PARENT_POLICY_ID = InsurancePolicyParticipant.InsurancePolicyId.getDescribe().getLocalName();

	/**
	 * @description Constant used to identify the Primary Life Assured role of the Insurance Policy Participant
	 */
	public static final String ROLE_PRIMARY_LIFE_ASSURED = AW_DAL_InsurancePolicyParticipant.PRIMARY_LIFE_ASSURED;

	/**
	 * @description Constant used to identify the Primary Life Assured Beneficiary role of the Insurance Policy Participant
	 */
	public static final String ROLE_PRIMARY_LIFE_ASSURED_BENEFICIARY = AW_DAL_InsurancePolicyParticipant.PRIMARY_LIFE_ASSURED_BENEFICIARY;

	/**
	 * @description Constant used to identify the Secondary Life Assured role of the Insurance Policy Participant
	 */
	public static final String ROLE_SECONDARY_LIFE_ASSURED = AW_DAL_InsurancePolicyParticipant.SECONDARY_LIFE_ASSURED;

	/**
	 * @description Constant used to identify the beneficiary role of the Insurance Policy Participant
	 */
	public static final String ROLE_BENEFICIARY = 'Beneficiary';

	/**
	 * @description Constant used to identify the Secondary Life Assured Beneficiary role of the Insurance Policy Participant
	 */
	public static final String ROLE_SECONDARY_LIFE_ASSURED_BENEFICIARY = AW_DAL_InsurancePolicyParticipant.SECONDARY_LIFE_ASSURED_BENEFICIARY;

	/**
	 * @description Set used to store the required roles for Beneficiary
	 */
	public static final Set<String> BENEFICIARY_ROLES = new Set<String>
	{
			ROLE_PRIMARY_LIFE_ASSURED,
			ROLE_PRIMARY_LIFE_ASSURED_BENEFICIARY,
			ROLE_SECONDARY_LIFE_ASSURED,
			ROLE_SECONDARY_LIFE_ASSURED_BENEFICIARY
	};

	/**
	 * @description Set used to store all the required roles for Beneficiary
	 */
	public static final Set<String> ALL_BENEFICIARY_ROLES = new Set<String>
	{
			ROLE_BENEFICIARY,
			ROLE_PRIMARY_LIFE_ASSURED_BENEFICIARY,
			ROLE_SECONDARY_LIFE_ASSURED_BENEFICIARY
	};
	/**
	 * @description Liberty Insurance Policy Participant record type id that should be used
	 */
	public static final Id RT_LIBERTY_INSURANCE_POLICY_PARTICIPANT_ID =
			CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName
					(
							InsurancePolicyParticipant.SObjectType,
							AW_DAL_InsurancePolicyParticipant.RT_LIBERTY_INSURANCE_POLICY_PARTICIPANT
					);

	/**
	 * @description Method to set the fields using Insurance Policy Participants
	 *
	 * @return A set of the standard fields used by queries when returning Insurance Policy Participants
	 */
	private static Set<String> getDefaultFields()
	{
		Set<String> defaultFields = AW_DAL_InsurancePolicyParticipant.getDefaultFields();

		defaultFields.addAll
				(
						new Set<String>
						{
								FIELD_ACTIVE,
								FIELD_INSURANCE_POLICY_NAME,
								FIELD_INSURANCE_POLICY_NUMBER,
								FIELD_INSURANCE_POLICY_SOURCE_SYSTEM,
								FIELD_RELATION_TO_OWNER,
								InsurancePolicyParticipant.AW_PDBID__c.getDescribe().getLocalName(),
								InsurancePolicyParticipant.RSC_PartyName__c.getDescribe().getLocalName(),
								InsurancePolicyParticipant.RelationshipToInsured.getDescribe().getLocalName()
						}
				);

		return defaultFields;
	}

	/**
	 * @description Retrieves the InsurancePolicyParticipant record by Id.
	 *
	 * @param parentRecordId a set of policy ids
	 *
	 * @return a list of items
	 */
	public static List<InsurancePolicyParticipant> findByParent(Set<Id> parentRecordId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PARENT_POLICY_ID, parentRecordId, getDefaultFields());
	}

	/**
	 * @description Gives InsurancePolicyParticipant record by set of parent Ids and Role.
	 *
	 * @param parentRecordIds a set of parent policy ids
	 * @param role The role selected
	 *
	 * @return a list of items
	 */
	public static List<InsurancePolicyParticipant> findByParentIdAndRole(Set<Id> parentRecordIds, String role)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters
				(
						OBJECT_NAME,
						FIELD_PARENT_POLICY_ID,
						CMN_UTIL_System.convertIdSetToStringSet(parentRecordIds),
						getDefaultFields()
				);

		searchParameters.searchConditions.equalsX(FIELD_ROLE, role);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Retrieves the Insurance Policy Participant record by Parent Ids and the roles.
	 *
	 * @param parentRecordIds The recordIds to which this item is associated
	 * @param roles The selected roles
	 *
	 * @return a list of items
	 */
	public static List<InsurancePolicyParticipant> findByParentIdsAndRoles(Set<Id> parentRecordIds, Set<String> roles)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters =
				CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_PARENT_POLICY_ID,
						CMN_UTIL_System.convertIdSetToStringSet(parentRecordIds), getDefaultFields());
		searchParameters.searchConditions.inX(FIELD_ROLE, CMN_UTIL_System.setToList(roles));

		return CMN_DAL_Search.getObjects(searchParameters);
	}
	/**
	 * @description Retrieves the inactive Insurance Policy Participant record by Parent Ids.
	 *
	 * @param parentIds The recordIds to which this item is associated
	 *
	 * @return a list of items
	 */
	public static List<InsurancePolicyParticipant> findInactiveByParentIds(Set<Id> parentIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.searchConditions.inX(FIELD_PARENT_POLICY_ID, CMN_UTIL_System.setToList(parentIds));
		searchParameters.searchConditions.equalsX(FIELD_ACTIVE, false);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will find an insurance policy participant by Id
	 *
	 * @param policyParticipantId The Id of the account
	 *
	 * @return Either the item found or null
	 */
	public static InsurancePolicyParticipant findById(Id policyParticipantId)
	{
		return (InsurancePolicyParticipant)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, policyParticipantId, getDefaultFields());
	}

	/**
	 * @description Will return all Policy Participants created by unit tests
	 *
	 * @return A list of Insurance Policy Participants
	 */
	@TestVisible
	private static List<InsurancePolicyParticipant> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}