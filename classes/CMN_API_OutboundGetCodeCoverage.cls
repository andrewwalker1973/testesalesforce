/**
 * @description This will retrieve the Code Coverage Details for a Salesforce Org, before calling API, make sure you
 * clear coverage results and run all tests again.
 *
 * @see CMN_API_OutboundGetCodeCoverage_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date October 2021, July 2023
 */
public inherited sharing class CMN_API_OutboundGetCodeCoverage extends CMN_API_RestBaseOutbound
{
	private static final String CSV_COLUMN_HEADERS =
			'Class Name,Lines Covered,Lines Not Covered,Total Number of Lines, Percentage Code Coverage' + CMN_UTIL_String.CRLF;
	private static final String FMT_FILE_NAME = 'Code Coverage Report - {0}.csv';
	private static final String HTTP_HEADER_AUTH_BEARER = 'Bearer ';
	private static final String QUERY_PARAMETERS = 'q=SELECT+ApexClassOrTriggerId,ApexClassOrTrigger.Name,NumLinesCovered,' +
			'NumLinesUncovered+FROM+ApexCodeCoverageAggregate';

	@TestVisible
	private List<DTO_CoverageComparable> codeCoverages = new List<DTO_CoverageComparable>();

	protected override void initialise()
	{
		super.initialise();

		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Will compose the relevant Query for retrieving code coverage
	 *
	 * @return The query string that will be appended to the URL
	 */
	protected override String getQueryParameters()
	{
		return QUERY_PARAMETERS;
	}

	/**
	 * @description Will return the current session Id as authorisation token
	 *
	 * @return Authorisation Header value
	 *
	 * @see UserInfo.getSessionId
	 */
	protected override String getAuthorisationToken()
	{
		//This is being called so that we can cover get an Auth String that is empty
		String authString = super.getAuthorisationToken();

		return String.isNotBlank(authString) ? authString : HTTP_HEADER_AUTH_BEARER + CMN_UTIL_System.getApiEnabledSessionId();
	}

	/**
	 * @description determine whether call must be aborted if no TriggerObjectId is provided
	 *
	 * @return Indicates that TriggerObjectId is required or not
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description Returns the verb for the request
	 *
	 * @return Will return "GET"
	 */
	protected override String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();
		addSObjectTypes(new List<SObjectType> {ContentVersion.SObjectType});
	}

	/**
	 * @description Ensure that we update the current user with a new file for the CSV file
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;

		setCoverages(dtoResponse);

		CMN_UTIL_StringBuffer csvFile = getCsvFile();

		registerChange
				(
						CMN_DAL_DataFactory.newContentVersion
								(
										UserInfo.getUserId(),
										String.format(FMT_FILE_NAME, new List<String> {String.valueOf(Datetime.now())}),
										Blob.valueOf(csvFile.toStr())
								)
				);
	}

	/**
	 * @description Will read the response and transform the coverages into a sortable list
	 *
	 * @param dtoResponse The response received
	 */
	private void setCoverages(DTO_Response dtoResponse)
	{
		if(dtoResponse.records != null)
		{
			for(DTO_Coverage dtoCoverage : dtoResponse.records)
			{
				if(dtoCoverage.NumLinesCovered + dtoCoverage.NumLinesUncovered > 0)
				{
					DTO_CoverageComparable newCodeCoverage = new DTO_CoverageComparable();

					newCodeCoverage.className = dtoCoverage.ApexClassOrTrigger.Name;
					newCodeCoverage.linesCovered = dtoCoverage.NumLinesCovered;
					newCodeCoverage.linesNotCovered = dtoCoverage.NumLinesUncovered;
					newCodeCoverage.totalNumberOfLines = newCodeCoverage.linesCovered + newCodeCoverage.linesNotCovered;
					newCodeCoverage.percentCovered = 0;

					if(newCodeCoverage.totalNumberOfLines > 0)
					{
						newCodeCoverage.percentCovered = Decimal.valueOf(newCodeCoverage.linesCovered) / Decimal.valueOf(newCodeCoverage.totalNumberOfLines) * 100;
					}

					newCodeCoverage.percentCovered = newCodeCoverage.percentCovered.setScale(2);

					codeCoverages.add(newCodeCoverage);
				}
			}

			//Sort from lowest overage to highest.
			codeCoverages.sort();
		}
	}

	/**
	 * @description will create a buffer that represents the contents of a CSV file
	 *
	 * @return The buffer with all the coverages in it
	 */
	private CMN_UTIL_StringBuffer getCsvFile()
	{
		CMN_UTIL_StringBuffer csvFile = new CMN_UTIL_StringBuffer();

		csvFile.append(CSV_COLUMN_HEADERS);

		for(DTO_CoverageComparable codeCoverage : codeCoverages)
		{
			csvFile.append(codeCoverage.className);
			csvFile.append(CMN_UTIL_String.COMMA);
			csvFile.append(codeCoverage.linesCovered);
			csvFile.append(CMN_UTIL_String.COMMA);
			csvFile.append(codeCoverage.linesNotCovered);
			csvFile.append(CMN_UTIL_String.COMMA);
			csvFile.append(codeCoverage.totalNumberOfLines);
			csvFile.append(CMN_UTIL_String.COMMA);
			csvFile.append(codeCoverage.percentCovered);
			csvFile.append(CMN_UTIL_String.CRLF);
		}
		return csvFile;
	}

	/**
	 * @description Returns Mock API Client used during unit tests
	 *
	 * @return Mock Endpoint
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new CMN_API_OutboundGetCodeCoverageMock();
	}

	/**
	 * @description This is example of Mock Response object used both in unit tests and when running service in mock mode
	 */
	private class CMN_API_OutboundGetCodeCoverageMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"records":[{"ApexClassOrTrigger":{"Name":"CMN_API_GetAddressGeocode"},"NumLinesCovered":67,"NumLinesUncovered":0},' +
				'{"ApexClassOrTrigger":{"Name":"CMN_CTRL_FieldSet"},"NumLinesCovered":0,"NumLinesUncovered":90},{"ApexClassOrTrigger":' +
				'{"Name":"CMN_BATCH_WebserviceQueueItem"},"NumLinesCovered":10,"NumLinesUncovered":0}]}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<DTO_Coverage> records;

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

	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_ApexClassOrTrigger
	{
		public String Name;
	}

	@SuppressWarnings('PMD.FieldNamingConventions')
	private class DTO_Coverage
	{
		public DTO_ApexClassOrTrigger ApexClassOrTrigger;
		public Integer NumLinesCovered;
		public Integer NumLinesUncovered;
	}

	/**
	 * @description A class to allow code coverages to be sorted based on coverage
	 */
	@TestVisible
	private class DTO_CoverageComparable implements Comparable
	{
		public String className;
		public Integer linesCovered;
		public Integer linesNotCovered;
		public Integer totalNumberOfLines;
		public Decimal percentCovered;

		/**
		 * @description Used to compare two code coverage DTOs so that they can be sorted
		 *
		 * @param compareTo Object to be compared
		 *
		 * @return 0, 1 or -1 depending on if the object's match or are considered above or below each other in sort order
		 */
		public Integer compareTo(Object compareTo)
		{
			DTO_CoverageComparable codeCoverage = (DTO_CoverageComparable)compareTo;

			Integer compareResult = -1;

			if(percentCovered == codeCoverage.percentCovered)
			{
				compareResult = 0;
			}
			else if(percentCovered > codeCoverage.percentCovered)
			{
				compareResult = 1;
			}

			return compareResult;
		}
	}
}