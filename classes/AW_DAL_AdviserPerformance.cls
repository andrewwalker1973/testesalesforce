/**
 * @description Public class to return the Performance Record
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_AdviserPerformance
{
	private static final String FIELD_AVERAGE_FAP = AW_AdviserPerformance__c.AW_AverageFAVP__c.getDescribe().getLocalName();
	private static final String FIELD_EXP_TENURE = AW_AdviserPerformance__c.AW_LAPExpTenure__c.getDescribe().getLocalName();
	private static final String FIELD_PRODUCTION_CLUB_STATUS = AW_AdviserPerformance__c.AW_LastYearsProductionClubStatus__c.getDescribe().getLocalName();
	private static final String FIELD_START_DATE = AW_AdviserPerformance__c.AW_StartDate__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = AW_AdviserPerformance__c.SObjectType.getDescribe().getLocalName();
	public static final String ACHIEVER_PRODUCTION_CLUB_STATUS = 'ACHIEVER';
	public static final String FIELD_COMPOSITE_KEY = AW_AdviserPerformance__c.AW_AP_CompositeID__c.getDescribe().getName();
	public static final String FIELD_LEAD_CONVERSION_RATE = 'AW_AdviserTarget__r.AW_ActualLeadConversionRate__c';
	public static final String FIELD_OPPORTUNITY_WIN_RATE = 'AW_AdviserTarget__r.AW_ActualOpportunityWinRate__c';
	public static final String FIELD_UACF_ID = AW_AdviserPerformance__c.AW_UACFID__c.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve Account Team Members
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_AdviserPerformance__c.AW_AdviserTarget__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_ClientSatisfactionScore__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_ConsultantCode__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_LastYearsProductionClubStatus__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_LeadConversionRate__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_NumberOfLeadConverted__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_NumberOfNewLeads__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_NumberOfNewOpportunities__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_NumberOfOpenLeads__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_NumberOfOpportunitiesOpen__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_NumberOfOpportunitiesWon__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_OpportunityWinRate__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_WeekNumber__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.AW_Year__c.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.CreatedDate.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.Id.getDescribe().getLocalName(),
				AW_AdviserPerformance__c.OwnerId.getDescribe().getLocalName(),
				FIELD_AVERAGE_FAP,
				FIELD_COMPOSITE_KEY,
				FIELD_EXP_TENURE,
				FIELD_LEAD_CONVERSION_RATE,
				FIELD_OPPORTUNITY_WIN_RATE,
				FIELD_PRODUCTION_CLUB_STATUS,
				FIELD_START_DATE,
				FIELD_UACF_ID
		};
	}

	/**
	 * @description This method is use to return the list of Adviser Performance
	 *
	 * @param performanceIds A set of performance ids
	 *
	 * @return A list of items
	 */
	public static List<AW_AdviserPerformance__c> findById(Set<Id> performanceIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, performanceIds, getDefaultFields());
	}

	/**
	 * @description This method is use to return the list of Adviser Performance with composite key
	 *
	 * @param compositeKeys A set of keys
	 *
	 * @return List of found items
	 */
	public static List<AW_AdviserPerformance__c> findByCompositeId(Set<String> compositeKeys)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_COMPOSITE_KEY, compositeKeys, getDefaultFields());
	}

	/**
	 * @description This method is use to return the an Adviser Performance with given composite key
	 *
	 * @param compositeKey the key against which to search
	 *
	 * @return Null of Item
	 */
	@TestVisible
	private static AW_AdviserPerformance__c findByCompositeId(String compositeKey)
	{
		return (AW_AdviserPerformance__c)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_COMPOSITE_KEY, compositeKey, getDefaultFields(), false);
	}

	@TestVisible
	private static String generateCompositeKey(User adviser)
	{
		String week = String.valueOf(CMN_UTIL_Date.weekNumberFromDate(Date.today()));
		String year = String.valueOf(Date.today().year());

		return week + year + CMN_UTIL_String.upperCase(adviser.AW_UACFID__c);
	}

	/**
	 * @description This method is return the record Adviser Performance based on composite key and consultant code
	 *
	 * @param obj SObject to store the Adviser performance
	 * @param compositeKey To store the value of compositeKey
	 * @param fieldName To store the name of the field
	 * @param uacfIdFieldName To store the consultant code
	 *
	 * @return Adviser performance record
	 */
	public static AW_AdviserPerformance__c newAdviserPerformance(SObject obj, String compositeKey, String fieldName, String uacfIdFieldName)
	{
		//TODO: Can we move this to the data factory class?
		AW_AdviserPerformance__c performance = new AW_AdviserPerformance__c();

		performance.OwnerId = (Id)obj.get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID);
		performance.AW_UACFID__c = (String)obj.get(uacfIdFieldName);
		Datetime dt = (Datetime)obj.get(fieldName);

		performance.AW_AP_CompositeID__c = compositeKey;

		performance.AW_WeekNumber__c = Decimal.valueOf(CMN_UTIL_Date.weekNumberFromDate(dt.date()));
		performance.AW_Year__c = String.valueOf(dt.year());

		return performance;
	}

	/**
	 * @description This method is return the composite key and consultant code
	 *
	 * @param obj To store the SObject
	 * @param dateFieldName To store the date field
	 * @param uacfIdAPIName To store the consultant code
	 *
	 * @return Adviser performance record
	 */
	public static String getCompositeKey(SObject obj, String dateFieldName, String uacfIdAPIName)
	{
		String year;
		Integer weekNumber;
		String compositeKey = CMN_UTIL_String.EMPTY;

		Datetime objectDate = (Datetime)obj.get(dateFieldName);
		String uacfId = (String)obj.get(uacfIdAPIName);

		if(uacfId != null && objectDate != null)
		{
			year = String.valueOf(objectDate.date().year());
			weekNumber = CMN_UTIL_Date.weekNumberFromDate(objectDate.date());

			compositeKey = constructPerformanceCompositeKey(weekNumber, year, uacfId);
		}

		return compositeKey;
	}

	/**
	 * @description This method is uses to return the Composite Key
	 *
	 * @param weekNumber Week Number
	 * @param year Year
	 * @param uacfId UACF Id
	 *
	 * @return compositeKey
	 */
	public static String constructPerformanceCompositeKey(Integer weekNumber, String year, String uacfId)
	{
		String compositeKey = weekNumber + year + CMN_UTIL_String.upperCase(uacfId);
		return compositeKey;
	}

	/**
	 * @description This method is use to return the list of Adviser Performance by uacfId
	 *
	 * @param uacfIds List of items to search against
	 *
	 * @return adviser's performance record sorted by Start Date
	 */
	public static List<AW_AdviserPerformance__c> findByUACFIDs(Set<String> uacfIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_UACF_ID, uacfIds, getDefaultFields());
		searchParameters.addOrderByField(FIELD_START_DATE);
		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Finds the latest Adviser Performance by looking for a field that's not null sorted by start date
	 *
	 * @param uacfId the uacfid against which to filter
	 * @param latestByField The field that shouldn't be empty
	 *
	 * @return null or an adviser performance
	 */
	private static AW_AdviserPerformance__c findLatestByUacfId(String uacfId, String latestByField)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_UACF_ID, new Set<String> {uacfId}, getDefaultFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(latestByField, CMN_SOQL_Query.Operator.NOT_EQUALS, CMN_UTIL_String.EMPTY));

		searchParameters.addSearchCondition(andCondition);

		searchParameters.addOrderByField(FIELD_START_DATE, true);
		searchParameters.pageSize = 1;
		List<AW_AdviserPerformance__c> performances = CMN_DAL_Search.getObjects(searchParameters);

		return performances.isEmpty() ? null : performances.iterator().next();
	}

	/**
	 * @description This method is use to retrieve the latest adviser performance record
	 *
	 * @param uacfId UACF Id
	 *
	 * @return AW_AdviserPerformance__c
	 */
	public static AW_AdviserPerformance__c findLatestByUACFID(String uacfId)
	{
		return findLatestByUacfId(uacfId, FIELD_UACF_ID);
	}

	/**
	 * @description This method is use to retrieve the latest adviser performance record with a Production Club Status
	 *
	 * @param uacfId UACF Id
	 *
	 * @return AW_AdviserPerformance__c
	 */
	public static AW_AdviserPerformance__c findLatestWithProductionClubStatusByUACFID(String uacfId)
	{
		return findLatestByUacfId(uacfId, FIELD_PRODUCTION_CLUB_STATUS);
	}

	/**
	 * @description This method is use to retrieve the latest adviser performance record with a Tenure
	 *
	 * @param uacfId UACF Id
	 *
	 * @return AW_AdviserPerformance__c
	 */
	public static AW_AdviserPerformance__c findLatestWithTenureByUACFID(String uacfId)
	{
		return findLatestByUacfId(uacfId, FIELD_EXP_TENURE);
	}

	/**
	 * @description This method is use to retrieve the latest adviser performance record with a AQC
	 *
	 * @param uacfId UACF Id
	 *
	 * @return AW_AdviserPerformance__c
	 */
	public static AW_AdviserPerformance__c findLatestWithAQCByUACFID(String uacfId)
	{
		return findLatestByUacfId(uacfId, FIELD_AVERAGE_FAP);
	}
}