/**
 * @description Service class to make  Outbound call to Mulesoft to get Activity Measure
 *
 * @see AW_TEST_API_AdviserPerformance @story ST-3495
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_API_RestOutboundAdviserPerformance extends CMN_API_RestBaseOutboundMule
{
	public static final String SERVICE_NAME = AW_API_RestOutboundAdviserPerformance.class.getName();
	@TestVisible
	private static final String FMT_JSON_OUTER_ATTR_NAME = '"adviserPerformances":';
	@TestVisible
	private static final String EXC_UACFID_NOT_FOUND = 'Adviser\'s UACF Id is not found, unable to process request';

	@TestVisible
	private static List<Integer> MOCK_WEEK_NUMBERS;
	@TestVisible
	private static List<String> MOCK_YEAR_WEEKS;
	@TestVisible
	private static String MOCK_UACFID;

	private static User clientUser;

	private Date latestWeekEndDate; // This holds the end date of the latest week in response

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();

	}

	/**
	 * @description The name of service to be used when looking up custom settings for you service
	 *
	 * @return
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Override to Inject json outer class in the response array
	 * 	 *
	 *
	 * @return
	 */
	protected override String getResponseBody()
	{
		String responseBody = super.getResponseBody();

		//We have to inject a JSON outer class because we are receiving an Array Response
		return '{' + FMT_JSON_OUTER_ATTR_NAME + responseBody + '}';
	}

	/**
	 * @description Override to return mock response for test class
	 * <p/>
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AW_API_RestOutboundAdviserPerformanceMock();
	}

	/**
	 * @description Override to set the SObject type for dml operations using uow
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();
		addSObjectTypes(new List<Schema.SObjectType> {AW_AdviserPerformance__c.SObjectType, User.SObjectType});
	}

	/**
	 * @description Override to abort the api call in case of insufficient information to make a call
	 *
	 * @return
	 */
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			clientUser = AW_DAL_User.findById(queueItem.CMN_TriggeringObjectId__c);

			if(String.isEmpty(clientUser.AW_UACFID__c))
			{
				mustAbort = true;
				callResult.errors.add(EXC_UACFID_NOT_FOUND);
			}
		}

		return mustAbort;
	}

	/**
	 * @description Override to performance DML operations
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Response dtoAdviserPerformances = (DTO_Response)baseResponseDTO;

		upsertAdviserPerformances(dtoAdviserPerformances.adviserPerformances);

		if(latestWeekEndDate != null)
		{
			clientUser.AW_LastPerformanceAPIRunDate__c = latestWeekEndDate;
			registerDirty(clientUser);
		}

	}

	/**
	 * @description This method upsert the adviser performance records corresponding to response DTO
	 *
	 * @param dtoAdviserPerformances *
	 */
	private void upsertAdviserPerformances(List<DTO_AdviserPerformance> dtoAdviserPerformances)
	{
		if(dtoAdviserPerformances != null && !dtoAdviserPerformances.isEmpty())
		{
			Map<String, SObject> compositeId2existingPerformance = createCompositeIdExistingPerformanceMap(dtoAdviserPerformances);

			for(DTO_AdviserPerformance adp : dtoAdviserPerformances)
			{
				String year = yearFromYearWeek(adp.yearWeek);
				String compositeKey = AW_DAL_AdviserPerformance.constructPerformanceCompositeKey(Integer.valueOf(adp.numberOfWeek), year, adp.uacfId);

				AW_AdviserPerformance__c foundPerformance = (AW_AdviserPerformance__c)compositeId2existingPerformance.get(compositeKey);

				// if existing update the record
				if(foundPerformance == null)
				{
					foundPerformance = new AW_AdviserPerformance__c();
					foundPerformance.AW_WeekNumber__c = adp.numberOfWeek;
					foundPerformance.AW_Year__c = year;
					foundPerformance.AW_UACFID__c = adp.uacfId;
					registerNew(foundPerformance);
				}
				else
				{
					registerDirty(foundPerformance);
				}

				foundPerformance.AW_ConsultantCode__c = adp.thirteenDigitText;
				foundPerformance.AW_LAPExpTenure__c = adp.primaryExperienceTenure;
				foundPerformance.AW_LastYearsProductionClubStatus__c = adp.prodClubPrevYr;
				foundPerformance.AW_AverageFAVP__c = adp.groupAqcCalculatedCategory;
				foundPerformance.AW_OnPBS__c = (adp.pbsGroupLatest != null) ? Boolean.valueOf(adp.pbsGroupLatest) : false;
				foundPerformance.AW_NetPCR__c = adp.netPCR;
				foundPerformance.AW_NetPCRActualYTD__c = adp.netPCR_YTD;
				foundPerformance.AW_TargetPCRYTD__c = adp.targetPcrYTD;
				foundPerformance.AW_PercentageNetPCRTargetYTD__c = adp.netPCRTargetYTD;
				foundPerformance.AW_FullYearTargetPCR__c = adp.targetPCRFullYR;
				foundPerformance.AW_FullYearPercentageNetPCRTargetYTD__c = adp.netPcrTargetFullYR;
				foundPerformance.AW_RetailActivities__c = adp.retailActivities;
				foundPerformance.AW_NetRetailActivitiesYTD__c = adp.retailActivitiesYTD;
				foundPerformance.AW_TargetRetailActivitiesYTD__c = adp.targetRetailActivitiesYTD;
				foundPerformance.AW_PercentageRetailActivitiesTargetYTD__c = adp.retailActivitiesTargetYTD;
				foundPerformance.AW_FullYearTargetRetailActivities__c = adp.targetRetailActivitiesFullYR;
				foundPerformance.AW_FullYearPCNetRetailActivityTargetYTD__c = adp.retailActivitiesTargetFullYR;
				foundPerformance.AW_RiskPCR__c = adp.riskPCR;
				foundPerformance.AW_RiskNetPCRYTD__c = adp.riskPCRYTD;
				foundPerformance.AW_TargetRiskPCRYTD__c = adp.targetRiskPCRYTD;
				foundPerformance.AW_PercentageRiskNetPCRTargetYTD__c = adp.riskPCRTargetYTD;
				foundPerformance.AW_FullYearTargetRiskPCR__c = adp.targetRiskPCRFullYR;
				foundPerformance.AW_FullYearPCRiskNetPCRTargetYTD__c = adp.riskPCRTargetFullYR;
				foundPerformance.AW_RiskActivities__c = adp.riskActivities;
				foundPerformance.AW_NetRiskActivitiesYTD__c = adp.riskActivitiesYTD;
				foundPerformance.AW_TargetRiskActivitiesYTD__c = adp.targetRiskActivitiesYTD;
				foundPerformance.AW_PercentageRiskActivitiesTargetYTD__c = adp.riskActivitiesTargetYTD;
				foundPerformance.AW_FullYearTargetRiskActivities__c = adp.targetRiskActivitiesFullYR;
				foundPerformance.AW_FullYearNetRiskActivitiesTargetYTD__c = adp.riskActivitiesTargetFullYR;
				foundPerformance.AW_NetPCRRequiredForValidationYTD__c = adp.valReqNetPCRytd;
				foundPerformance.AW_LastMELAPValidatingYTD__c = adp.validatingytd;

				// Populate the latest week end date received
				Date weekEndDate = CMN_UTIL_Date.weekEndDateFromWeekNumber(adp.numberOfWeek, Integer.valueOf(year));
				if(latestWeekEndDate == null || weekEndDate > latestWeekEndDate)
				{
					latestWeekEndDate = weekEndDate;
				}
			}
		}
	}

	/**
	 * @description This method is used to get Map of Composite Id and Existing Performance record among the response DTO
	 *
	 * @param dtoAdviserPerformances *
	 *
	 * @return
	 */
	private Map<String, SObject> createCompositeIdExistingPerformanceMap(List<DTO_AdviserPerformance> dtoAdviserPerformances)
	{
		Set<String> compositeIds = extractCompositeIds(dtoAdviserPerformances);
		List<AW_AdviserPerformance__c> existingPerformances = AW_DAL_AdviserPerformance.findByCompositeId(compositeIds);

		Map<String, SObject> compositeId2existingPerformance = CMN_UTIL_System.convertListToSingleStringMap(existingPerformances, AW_DAL_AdviserPerformance.FIELD_COMPOSITE_KEY);

		return compositeId2existingPerformance;
	}

	/**
	 * @description This method extract the composite Id from response DTO
	 *
	 * @param dtoAdviserPerformances *
	 *
	 * @return
	 */
	@TestVisible
	private Set<String> extractCompositeIds(List<DTO_AdviserPerformance> dtoAdviserPerformances)
	{
		Set<String> compositeKeys = new Set<String>();
		for(DTO_AdviserPerformance dtoPerformance : dtoAdviserPerformances)
		{
			Integer weekNumber = Integer.valueOf(dtoPerformance.numberOfWeek);
			String year = yearFromYearWeek(dtoPerformance.yearWeek);
			String uacfId = dtoPerformance.uacfId;

			String compositeKey = AW_DAL_AdviserPerformance.constructPerformanceCompositeKey(weekNumber, year, uacfId);

			compositeKeys.add(compositeKey);
		}
		return compositeKeys;
	}

	/**
	 * @description Extract year from yearWeek String
	 *
	 * @param yearWeek *
	 *
	 * @return
	 */
	private String yearFromYearWeek(String yearWeek)
	{
		String year;

		if(yearWeek != null && String.isNotEmpty(yearWeek) && yearWeek.length() > 4)
		{
			year = yearWeek.substring(0, 4);
		}

		return year;
	}

	/**
	 * @description DTO class
	 */
	public class DTO_Request extends CMN_DTO_JsonBase
	{
		private String startDate;
		private String endDate;
		private List<String> uacfIds = new List<String>();

		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);

			startDate = String.valueOf(clientUser.AW_LastPerformanceAPIRunDate__c);

			if(startDate == null)
			{
				AW_AdviserPerformanceAPISetting__mdt apiSetting = AW_AdviserPerformanceAPISetting__mdt.getInstance(SERVICE_NAME);

				if(apiSetting != null)
				{
					startDate = String.valueOf(apiSetting.AW_StartDate__c);
				}
			}

			endDate = String.valueOf(System.today());
			uacfIds.add(clientUser.AW_UACFID__c);
		}
	}

	@TestVisible
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		@TestVisible
		private List<DTO_AdviserPerformance> adviserPerformances = new List<DTO_AdviserPerformance>();

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}

	@TestVisible
	private class DTO_AdviserPerformance
	{
		//private Integer rowId;
		@TestVisible
		private String yearWeek;
		@TestVisible
		private Integer numberOfWeek;
		//private Integer partyId;
		//private Integer primarySrsId;
		private String thirteenDigitText;
		//private String adviserType;
		private String uacfId;
		//private String surnameName;
		//private String status;
		//private String primaryEffectiveStartDate;
		//private String PrimaryEffectiveEndDate;
		//private Integer brnNum;
		//private String branchShort;
		private String primaryExperienceTenure;
		private String prodClubPrevYr;
		private String groupAqcCalculatedCategory;
		private String pbsGroupLatest;
		private Double netPCR;
		private Double netPCR_YTD;
		private Double targetPcrYTD;
		private Double netPCRTargetYTD;
		private Double targetPCRFullYR;
		private Double netPcrTargetFullYR;
		private Double retailActivities;
		private Double retailActivitiesYTD;
		private Double targetRetailActivitiesYTD;
		private Double retailActivitiesTargetYTD;
		private Double targetRetailActivitiesFullYR;
		private Double retailActivitiesTargetFullYR;
		private Double riskPCR;
		private Double riskPCRYTD;
		private Double targetRiskPCRYTD;
		private Double riskPCRTargetYTD;
		private Double targetRiskPCRFullYR;
		private Double riskPCRTargetFullYR;
		private Double riskActivities;
		private Double riskActivitiesYTD;
		private Double targetRiskActivitiesYTD;
		private Double riskActivitiesTargetYTD;
		private Double targetRiskActivitiesFullYR;
		private Double riskActivitiesTargetFullYR;
		private Double valReqNetPCRytd;
		private String validatingytd;
		//private String UploadDate;
	}

	@TestVisible
	private class AW_API_RestOutboundAdviserPerformanceMock extends CMN_API_HttpBaseOutboundMock
	{
		@TestVisible
		private final String VALID_RESPONSE = '[{"rowId":1,"yearWeek":"' + MOCK_YEAR_WEEKS[0] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[0] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":2064867.20,"netPCR_YTD":2064867.20,"targetPcrYTD":13288231.02,"netPCRTargetYTD":15.54,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":1.55,"retailActivities":3.00,"retailActivitiesYTD":3.00,"targetRetailActivitiesYTD":0.43,"retailActivitiesTargetYTD":39.37,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":3.96,"riskPCR":280440.00,"riskPCRYTD":280440.00,"targetRiskPCRYTD":356432.88,"riskPCRTargetYTD":78.68,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":7.87,"riskActivities":1.00,"riskActivitiesYTD":1.00,"targetRiskActivitiesYTD":7.62,"riskActivitiesTargetYTD":232.56,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":24.21,"valReqNetPCRytd":7669818.94,"validatingytd":"No","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":3,"yearWeek":"' + MOCK_YEAR_WEEKS[1] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[1] + ',"partyId":7865,"primarySrsId":146055,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Kurland, Roy","status":"Active","primaryEffectiveStartDate":"1989-02-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"REP","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":1933490.59,"netPCR_YTD":1933490.59,"targetPcrYTD":2660748.17,"netPCRTargetYTD":72.67,"targetPCRFullYR":26607481.44,"netPcrTargetFullYR":7.27,"retailActivities":4.00,"retailActivitiesYTD":4.00,"targetRetailActivitiesYTD":1.76,"retailActivitiesTargetYTD":55.48,"targetRetailActivitiesFullYR":72.66,"retailActivitiesTargetFullYR":5.51,"riskPCR":56972.00,"riskPCRYTD":56972.00,"targetRiskPCRYTD":458109.31,"riskPCRTargetYTD":12.44,"targetRiskPCRFullYR":4581092.90,"riskPCRTargetFullYR":1.24,"riskActivities":1.00,"riskActivitiesYTD":1.00,"targetRiskActivitiesYTD":7.21,"riskActivitiesTargetYTD":56.82,"targetRiskActivitiesFullYR":17.84,"riskActivitiesTargetFullYR":5.61,"valReqNetPCRytd":1640189.54,"validatingytd":"Validating","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":2309,"yearWeek":"' + MOCK_YEAR_WEEKS[2] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[2] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":10201548.84,"netPCR_YTD":12266416.04,"targetPcrYTD":23918815.88,"netPCRTargetYTD":51.28,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":9.23,"retailActivities":15.00,"retailActivitiesYTD":18.00,"targetRetailActivitiesYTD":0.75,"retailActivitiesTargetYTD":131.77,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":23.75,"riskPCR":175126.00,"riskPCRYTD":455566.00,"targetRiskPCRYTD":641579.20,"riskPCRTargetYTD":71.01,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":12.78,"riskActivities":1.00,"riskActivitiesYTD":2.00,"targetRiskActivitiesYTD":13.66,"riskActivitiesTargetYTD":266.67,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":48.43,"valReqNetPCRytd":15339637.88,"validatingytd":"No","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":4667,"yearWeek":"' + MOCK_YEAR_WEEKS[3] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[3] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":9104742.55,"netPCR_YTD":21371158.59,"targetPcrYTD":34549400.74,"netPCRTargetYTD":61.86,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":16.08,"retailActivities":5.00,"retailActivitiesYTD":23.00,"targetRetailActivitiesYTD":1.07,"retailActivitiesTargetYTD":116.75,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":30.34,"riskPCR":299696.00,"riskPCRYTD":755262.00,"targetRiskPCRYTD":926725.52,"riskPCRTargetYTD":81.50,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":21.19,"riskActivities":1.00,"riskActivitiesYTD":3.00,"targetRiskActivitiesYTD":19.70,"riskActivitiesTargetYTD":280.37,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":72.64,"valReqNetPCRytd":23009456.82,"validatingytd":"No","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":7126,"yearWeek":"' + MOCK_YEAR_WEEKS[4] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[4] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":7293139.13,"netPCR_YTD":28664297.72,"targetPcrYTD":45179985.60,"netPCRTargetYTD":63.44,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":21.57,"retailActivities":11.00,"retailActivitiesYTD":34.00,"targetRetailActivitiesYTD":1.39,"retailActivitiesTargetYTD":132.09,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":44.85,"riskPCR":199563.00,"riskPCRYTD":954825.00,"targetRiskPCRYTD":1211871.84,"riskPCRTargetYTD":78.79,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":26.79,"riskActivities":1.00,"riskActivitiesYTD":4.00,"targetRiskActivitiesYTD":25.74,"riskActivitiesTargetYTD":287.77,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":96.85,"valReqNetPCRytd":30679275.76,"validatingytd":"No","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":9677,"yearWeek":"' + MOCK_YEAR_WEEKS[5] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[5] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":19424899.72,"netPCR_YTD":48089197.44,"targetPcrYTD":58468216.62,"netPCRTargetYTD":82.25,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":36.19,"retailActivities":7.00,"retailActivitiesYTD":41.00,"targetRetailActivitiesYTD":1.82,"retailActivitiesTargetYTD":122.90,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":54.09,"riskPCR":414973.00,"riskPCRYTD":1369798.00,"targetRiskPCRYTD":1568304.72,"riskPCRTargetYTD":87.34,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":38.43,"riskActivities":1.00,"riskActivitiesYTD":5.00,"targetRiskActivitiesYTD":33.36,"riskActivitiesTargetYTD":274.73,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":121.07,"valReqNetPCRytd":38349094.70,"validatingytd":"Validating","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":12330,"yearWeek":"' + MOCK_YEAR_WEEKS[6] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[6] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":7993573.50,"netPCR_YTD":56082770.94,"targetPcrYTD":69098801.48,"netPCRTargetYTD":81.16,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":42.20,"retailActivities":8.00,"retailActivitiesYTD":49.00,"targetRetailActivitiesYTD":2.14,"retailActivitiesTargetYTD":124.37,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":64.64,"riskPCR":204511.00,"riskPCRYTD":1574309.00,"targetRiskPCRYTD":1853451.04,"riskPCRTargetYTD":84.94,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":44.17,"riskActivities":2.00,"riskActivitiesYTD":7.00,"targetRiskActivitiesYTD":39.40,"riskActivitiesTargetYTD":327.10,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":169.49,"valReqNetPCRytd":46018913.64,"validatingytd":"Validating","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":15057,"yearWeek":"' + MOCK_YEAR_WEEKS[7] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[7] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":28101526.17,"netPCR_YTD":84184297.11,"targetPcrYTD":82387032.50,"netPCRTargetYTD":102.18,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":63.35,"retailActivities":6.00,"retailActivitiesYTD":55.00,"targetRetailActivitiesYTD":2.57,"retailActivitiesTargetYTD":116.97,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":72.56,"riskPCR":549118.00,"riskPCRYTD":2123427.00,"targetRiskPCRYTD":2209883.92,"riskPCRTargetYTD":96.09,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":59.57,"riskActivities":1.00,"riskActivitiesYTD":8.00,"targetRiskActivitiesYTD":47.02,"riskActivitiesTargetYTD":311.28,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":193.70,"valReqNetPCRytd":53688732.58,"validatingytd":"Validating","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":17798,"yearWeek":"' + MOCK_YEAR_WEEKS[8] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[8] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":8827193.43,"netPCR_YTD":93011490.54,"targetPcrYTD":93017617.36,"netPCRTargetYTD":99.99,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":70.00,"retailActivities":9.00,"retailActivitiesYTD":64.00,"targetRetailActivitiesYTD":2.89,"retailActivitiesTargetYTD":120.62,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":84.43,"riskPCR":278968.00,"riskPCRYTD":2402395.00,"targetRiskPCRYTD":2495030.24,"riskPCRTargetYTD":96.29,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":67.40,"riskActivities":3.00,"riskActivitiesYTD":11.00,"targetRiskActivitiesYTD":53.06,"riskActivitiesTargetYTD":380.62,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":266.34,"valReqNetPCRytd":61358551.52,"validatingytd":"Validating","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":20601,"yearWeek":"' + MOCK_YEAR_WEEKS[9] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[9] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"Excellent","pbsGroupLatest":"FALSE","netPCR":2243974.53,"netPCR_YTD":95255465.07,"targetPcrYTD":103648202.22,"netPCRTargetYTD":91.90,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":71.68,"retailActivities":8.00,"retailActivitiesYTD":72.00,"targetRetailActivitiesYTD":3.21,"retailActivitiesTargetYTD":121.83,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":94.99,"riskPCR":479483.00,"riskPCRYTD":2881878.00,"targetRiskPCRYTD":2780176.56,"riskPCRTargetYTD":103.66,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":80.85,"riskActivities":3.00,"riskActivitiesYTD":14.00,"targetRiskActivitiesYTD":59.10,"riskActivitiesTargetYTD":436.14,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":338.98,"valReqNetPCRytd":69028370.46,"validatingytd":"Validating","UploadDate":"2019-10-14T10:38:52.183"},{"rowId":23472,"yearWeek":"' + MOCK_YEAR_WEEKS[10] + '","numberOfWeek":' + MOCK_WEEK_NUMBERS[10] + ',"partyId":3336,"primarySrsId":145890,"thirteenDigitText":"8000100021003","adviserType":"FA","uacfId":"' + MOCK_UACFID + '","surnameName":"Stein, David","status":"Active","primaryEffectiveStartDate":"1979-11-01T00:00:00","PrimaryEffectiveEndDate":"9999-12-31T00:00:00","brnNum":68,"branchShort":"Cape Town","primaryExperienceTenure":"E4","prodClubPrevYr":"ACHIEVER","groupAqcCalculatedCategory":"","pbsGroupLatest":"FALSE","netPCR":0.00,"netPCR_YTD":0.00,"targetPcrYTD":116936433.24,"netPCRTargetYTD":0.00,"targetPCRFullYR":132882310.59,"netPcrTargetFullYR":0.00,"retailActivities":0.00,"retailActivitiesYTD":0.00,"targetRetailActivitiesYTD":3.64,"retailActivitiesTargetYTD":0.00,"targetRetailActivitiesFullYR":75.80,"retailActivitiesTargetFullYR":0.00,"riskPCR":0.00,"riskPCRYTD":0.00,"targetRiskPCRYTD":3136609.44,"riskPCRTargetYTD":0.00,"targetRiskPCRFullYR":3564328.94,"riskPCRTargetFullYR":0.00,"riskActivities":0.00,"riskActivitiesYTD":0.00,"targetRiskActivitiesYTD":66.72,"riskActivitiesTargetYTD":0.00,"targetRiskActivitiesFullYR":4.13,"riskActivitiesTargetFullYR":0.00,"valReqNetPCRytd":76698189.40,"validatingytd":"Validating","UploadDate":"2019-10-14T10:38:52.183"}]';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
}