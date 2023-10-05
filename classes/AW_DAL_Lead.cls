/**
 * @description Public class to return the record of Leads
 *
 * @author Accenture vishakha.saini@accenture.com
 *
 * @date 2019, March 2022
 */
public inherited sharing class AW_DAL_Lead
{
	private static final String FIELD_LEAD_OWNER_PROFILE = Lead.AW_LeadOwnerProfile__c.getDescribe().getLocalName();
	public static final String COUNT_OF_CONVERTED_LEADS = 'countOfConvertedLeads';
	public static final String COUNT_OF_NEW_LEADS = 'countOfNewLeads';
	public static final String COUNT_OF_OPEN_LEADS = 'countOfOpenLeads';
	public static final String FIELD_ADVISER_UACFID = Lead.AW_AdviserUACFID__c.getDescribe().getLocalName();
	public static final String FIELD_DATE_RECEIVED = Lead.AW_DateReceived__c.getDescribe().getLocalName();
	public static final String FIELD_IDENTIFICATION_NUMBER = Lead.AW_identificationNumber__c.getDescribe().getLocalName();
	public static final String FIELD_IS_REALLOCATED = Lead.AW_IsReallocated__c.getDescribe().getLocalName();
	public static final String FIELD_LEAD_BRANCH = Lead.AW_LeadBranch__c.getDescribe().getLocalName();
	public static final String FIELD_LEAD_IS_CONVERTED = Lead.IsConverted.getDescribe().getLocalName();
	public static final String FIELD_LEAD_SOURCE = Lead.LeadSource.getDescribe().getLocalName();
	public static final String IDENTIFICATION_TYPE_PASSPORT = 'Passport';
	public static final String IDENTIFICATION_TYPE_SA_ID = 'South African ID';
	public static final String LEAD_SOURCE_CLIENT_REQUEST = 'Client Request';
	public static final String LEAD_SOURCE_CONTACT_CENTRE = 'Contact Centre';
	public static final String LEAD_SOURCE_WEBSITE = 'Website';
	public static final String MARTIAL_STATUS_MARRIED = 'Married';
	public static final String OBJECT_NAME = Lead.SObjectType.getDescribe().getLocalName();
	public static final String RECORDTYPE_BUSINESS = 'AW_LibertyBusinessLeadReferral';
	public static final String RECORDTYPE_DEFAULT = 'AW_DefaultLead';
	public static final String STATUS_CONVERTED = 'Convert';
	public static final String STATUS_INITIATE_1ST_CONTACT = 'Initiate 1st Contact';
	public static final String STATUS_NEW = 'New';
	public static final String STATUS_PROSPECT = 'Prospect';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_ADVISER_UACFID,
				FIELD_DATE_RECEIVED,
				FIELD_IDENTIFICATION_NUMBER,
				FIELD_IS_REALLOCATED,
				FIELD_LEAD_BRANCH,
				FIELD_LEAD_IS_CONVERTED,
				FIELD_LEAD_OWNER_PROFILE,
				FIELD_LEAD_SOURCE,
				Lead.AW_CompanyRegistrationTrustNumber__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress1City__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress1Line1__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress1Line2__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress1PostalCode__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress1ProvinceCode__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress1Province__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress1Suburb__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress2City__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress2Line1__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress2Line2__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress2PostalCode__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress2ProvinceCode__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress2Province__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAddress2Suburb__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauAlternativeEmail__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauCallStatus__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauCellNumber__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauConsent__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauCreditScore__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauDeceasedDate__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauDependants__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauEmployer1__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauEmployer2__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauEstimatedNetIncome__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauForename1__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauForename2__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauForename3__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauGender__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauLastCallDateTime__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauMaritalStatus__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauOccupation1__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauOccupation2__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauRequestStatusMessage__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSpouseName1__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSpouseName2__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier10__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier11__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier12__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier1__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier2__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier3__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier4__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier5__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier6__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier7__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier8__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSupplier9__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauSurname__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauTelephoneNumber__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauTenure1__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauTenure2__c.getDescribe().getLocalName(),
				Lead.AW_CreditBureauTitle__c.getDescribe().getLocalName(),
				Lead.AW_DateOfBirth__c.getDescribe().getLocalName(),
				Lead.AW_Gender__c.getDescribe().getLocalName(),
				Lead.AW_IdentificationType__c.getDescribe().getLocalName(),
				Lead.AW_ProductInterest__c.getDescribe().getLocalName(),
				Lead.AW_SubProductInterest__c.getDescribe().getLocalName(),
				Lead.Company.getDescribe().getLocalName(),
				Lead.FirstName.getDescribe().getLocalName(),
				Lead.Id.getDescribe().getLocalName(),
				Lead.LastName.getDescribe().getLocalName(),
				Lead.Name.getDescribe().getLocalName(),
				Lead.OwnerId.getDescribe().getLocalName(),
				Lead.Status.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method to get the list of lead by branch use in Test class
	 *
	 * @param accounts A list of branch accounts
	 *
	 * @return List of items
	 */
	@TestVisible
	private static List<Lead> findByBranchId(List<Account> accounts)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_LEAD_BRANCH, CMN_UTIL_System.extractListIds(accounts), getDefaultFields());
	}

	/**
	 * @description Method to get the list of lead by Owner using in test class
	 *
	 * @param owners A list of owners
	 *
	 * @return List of items
	 */
	@TestVisible
	private static List<Lead> findByOwnerId(List<User> owners)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_OWNER_ID, CMN_UTIL_System.extractListIds(owners), getDefaultFields());
	}

	/**
	 * @description Method to get the lead by lead id using in test class
	 *
	 * @param leadId The id of the lead to retrieve
	 *
	 * @return Null or Item
	 */
	public static Lead findById(Id leadId)
	{
		return (Lead)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, leadId, getDefaultFields());
	}

	/**
	 * @description This method is contain the count of open lead with owner
	 *
	 * @param ownerIds set of Owner Ids
	 *
	 * @return result of open leads
	 */
	public static Map<Id, AggregateResult> findCountOpenLeadsByOwnerIds(Set<Id> ownerIds)
	{
		Map<Id, AggregateResult> results = new Map<Id, AggregateResult>();
		for(AggregateResult result :
		[
				SELECT OwnerId,
						COUNT(Id) countOfOpenLeads
				FROM Lead
				WHERE OwnerId IN :ownerIds
				AND IsConverted != TRUE
				GROUP BY OwnerId
		])
		{
			results.put((Id)result.get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID), result);
		}
		return results;
	}

	/**
	 * @description This method is return the count of open lead created weekly
	 *
	 * @param performanceCompositeKeys Set of performance composite keys
	 *
	 * @return result of open leads
	 */
	public static Map<Id, AggregateResult> findCountWeeklyNewLeadsByOwnerIds(Set<String> performanceCompositeKeys)
	{
		Map<Id, AggregateResult> results = new Map<Id, AggregateResult>();
		for(AggregateResult result :
		[
				SELECT OwnerId,
						COUNT(Id) countOfNewLeads
				FROM Lead
				WHERE AW_LeadCreatedKey__c IN :performanceCompositeKeys
				GROUP BY OwnerId
		])
		{
			results.put((Id)result.get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID), result);
		}
		return results;
	}

	/**
	 * @description This method is return the converted lead created weekly with owner
	 *
	 * @param performanceCompositeKeys Set of performance composite keys
	 *
	 * @return result of open leads
	 */
	public static Map<Id, AggregateResult> findCountWeeklyConvertedLeadsByOwnerId(Set<String> performanceCompositeKeys)
	{
		Map<Id, AggregateResult> results = new Map<Id, AggregateResult>();

		for(AggregateResult result :
		[
				SELECT OwnerId,
						COUNT(Id) countOfConvertedLeads
				FROM Lead
				WHERE AW_LeadConvertedKey__c IN :performanceCompositeKeys
				GROUP BY OwnerId
		])
		{
			results.put((Id)result.get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID), result);
		}
		return results;
	}
	/**
	 * @description Method to get the list of lead by Identification number & owner where lead hasn't been converted
	 *
	 * @param identificationNumbers List of Identification Numbers
	 * @param ownerIds List of Owner Ids
	 *
	 * @return A list of leads
	 */
	public static List<Lead> findByIdentificationNumberAndOwner(Set<String> identificationNumbers, List<String> ownerIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_IDENTIFICATION_NUMBER, identificationNumbers, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.SetCondition(CMN_DAL_SObjectDomain.FIELD_OWNER_ID, CMN_SOQL_Query.Operator.INX, ownerIds));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_LEAD_IS_CONVERTED, CMN_SOQL_Query.Operator.EQUALS, false));

		searchParameters.addSearchCondition(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is used to get the records to be reallocated by soql query locator
	 *
	 * @param ownerProfileName Owner profile name
	 * @param status Status value
	 * @param slaBreachedOn Datetime on which SLA breaches
	 * @param hotLeadSources Set of Hot Lead Sources
	 *
	 * @return The generate query locator
	 *
	 * @author kiran.kumaryelisetti@lntinfotech.com
	 */
	public static Database.QueryLocator findRecordsToBeReallocatedQuery(String ownerProfileName, String status, Datetime slaBreachedOn, Set<Object> hotLeadSources)
	{
		CMN_SOQL_Builder relatedActivities =
				new CMN_SOQL_Builder()
						.selectX(CMN_DAL_SObjectDomain.FIELD_ID)
						.fromX(CMN_DAL_SObjectDomain.RELATED_OPEN_ACTIVITIES);//TODO: Exclude System generated activities

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_LEAD_OWNER_PROFILE, CMN_SOQL_Query.Operator.EQUALS, ownerProfileName));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(CMN_DAL_Lead.FIELD_STATUS, CMN_SOQL_Query.Operator.EQUALS, status));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_DATE_RECEIVED, CMN_SOQL_Query.Operator.LESS_THAN_OR_EQUAL_TO, slaBreachedOn));
		
		andCondition.add(new CMN_SOQL_Query.SetCondition(FIELD_LEAD_SOURCE, CMN_SOQL_Query.Operator.INX, hotLeadSources));

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(getDefaultFields())
						.selectX(relatedActivities)
						.fromX(OBJECT_NAME)
						.whereX(andCondition);

		return Database.getQueryLocator(builder.toSoql());
	}

	/**
	 * @description Will return all Lead in the system
	 *
	 * @return A list of lead
	 */
	@TestVisible
	private static List<Lead> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}