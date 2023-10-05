/**
 * @description Service class to make outbound API call and retrieve Client's Workflow Tasks
 *
 * @see AW_API_RestOutboundWorkflowTasks_TEST @story ST-2338
 *
 * @author jason.van.beukering@accenture.com, vishakha.saini@accenture.com
 *
 * @date 2019, March 2023
 */
public inherited sharing class AW_API_RestOutboundWorkflowTasks extends CMN_API_RestBaseOutboundMule
{
	private User adviser;
	private static final Map<String, String> PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE = new Map<String, String>();
	private static final Map<String, String> PINBALL_STATUS_CODE_MAPPING = new Map<String, String>();
	private static final String ZERO_STRING = '0';

	@TestVisible
	private static final String FMT_JSON_OUTER_ATTR_NAME = '"workflowTasks":';

	/**
	 * @description API class name
	 */
	public static final String SERVICE_NAME = AW_API_RestOutboundWorkflowTasks.class.getName();

	//Global constants for exceptions
	@TestVisible
	private static final String ERROR_CONSULTANT_CODE_NOT_FOUND = 'Consultant Code is not found in Queue item, unable to process request';
	@TestVisible
	private static final String ERROR_ADVISER_NOT_FOUND = 'Adviser is not found, unable to process request';

	//Global constants for Processing status codes mapping
	private static final String STR_ZERO = '0';
	private static final String STR_ONE = '1';
	private static final String STR_TWO = '2';
	private static final String STR_THREE = '3';
	private static final String STR_FOUR = '4';
	private static final String STR_FIVE = '5';
	private static final String STR_SIX = '6';
	private static final String STR_SEVEN = '7';
	private static final String STR_EIGHT = '8';
	private static final String STR_ALPHABET_A = 'A';
	private static final String STR_ALPHABET_B = 'B';
	private static final String STR_IN_PROGRESS = 'In progress';
	private static final String STR_UNDERWRITING_REQUIREMENTS_OUTSTANDING = 'Underwriting requirements outstanding';
	private static final String STR_UNDERWRITING_REQUIREMENTS_COMPLETED = 'Underwriting requirements completed';
	private static final String STR_AWAITING_OUTSTANDING_REQUIREMENTS = 'Awaiting outstanding requirements';
	private static final String STR_REFERRED_TO_OPERATIONS = 'Referred to operations';
	private static final String STR_INVALIDATED = 'Invalidated';
	private static final String STR_DECLINED = 'Declined';
	private static final String STR_APPROVED = 'Approved';
	private static final String STR_POLICY_LOADED = 'Policy loaded';

	@TestVisible
	private static String mockIdentificationNumber;
	@TestVisible
	private static String mockUpdateIsn;
	@TestVisible
	private static String mockProcessingStatus;

	private static final Map<String, Integer> OPPORTUNITY_STAGES_MAPPED_WITH_PRIORITIES = new Map<String, Integer>();

	private static final Integer PRIORITY_ONE = 1;
	private static final Integer PRIORITY_TWO = 2;
	private static final Integer PRIORITY_THREE = 3;

	static
	{
		PINBALL_STATUS_CODE_MAPPING.put(STR_ZERO, STR_IN_PROGRESS);
		PINBALL_STATUS_CODE_MAPPING.put(STR_ONE, STR_UNDERWRITING_REQUIREMENTS_OUTSTANDING);
		PINBALL_STATUS_CODE_MAPPING.put(STR_TWO, STR_UNDERWRITING_REQUIREMENTS_COMPLETED);
		PINBALL_STATUS_CODE_MAPPING.put(STR_THREE, STR_AWAITING_OUTSTANDING_REQUIREMENTS);
		PINBALL_STATUS_CODE_MAPPING.put(STR_FOUR, STR_REFERRED_TO_OPERATIONS);
		PINBALL_STATUS_CODE_MAPPING.put(STR_FIVE, STR_INVALIDATED);
		PINBALL_STATUS_CODE_MAPPING.put(STR_SIX, STR_DECLINED);
		PINBALL_STATUS_CODE_MAPPING.put(STR_SEVEN, STR_APPROVED);
		PINBALL_STATUS_CODE_MAPPING.put(STR_EIGHT, STR_APPROVED);
		PINBALL_STATUS_CODE_MAPPING.put(STR_ALPHABET_A, STR_REFERRED_TO_OPERATIONS);
		PINBALL_STATUS_CODE_MAPPING.put(STR_ALPHABET_B, STR_POLICY_LOADED);

		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_ZERO, AW_DAL_Opportunity.OPPORTUNITY_STAGE_CASE_SUBMITTED);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_ONE, AW_DAL_Opportunity.OPPORTUNITY_STAGE_CASE_SUBMITTED);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_TWO, AW_DAL_Opportunity.OPPORTUNITY_STAGE_BUSINESS_ACCEPTED);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_THREE, AW_DAL_Opportunity.OPPORTUNITY_STAGE_CASE_SUBMITTED);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_FOUR, AW_DAL_Opportunity.OPPORTUNITY_STAGE_CASE_SUBMITTED);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_FIVE, AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_LOST);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_SIX, AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_LOST);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_SEVEN, AW_DAL_Opportunity.OPPORTUNITY_STAGE_BUSINESS_ACCEPTED);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_EIGHT, AW_DAL_Opportunity.OPPORTUNITY_STAGE_BUSINESS_ACCEPTED);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_ALPHABET_A, AW_DAL_Opportunity.OPPORTUNITY_STAGE_BUSINESS_ACCEPTED);
		PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.put(STR_ALPHABET_B, AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON);
	}

	static
	{
		OPPORTUNITY_STAGES_MAPPED_WITH_PRIORITIES.put(AW_DAL_Opportunity.OPPORTUNITY_STAGE_CASE_SUBMITTED, PRIORITY_ONE);
		OPPORTUNITY_STAGES_MAPPED_WITH_PRIORITIES.put(AW_DAL_Opportunity.OPPORTUNITY_STAGE_BUSINESS_ACCEPTED, PRIORITY_TWO);
		OPPORTUNITY_STAGES_MAPPED_WITH_PRIORITIES.put(AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_LOST, PRIORITY_THREE);
		OPPORTUNITY_STAGES_MAPPED_WITH_PRIORITIES.put(AW_DAL_Opportunity.OPPORTUNITY_STAGE_CLOSED_WON, PRIORITY_THREE);
	}

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseResponseDTO = new DTO_Response();

	}

	/**
	 * @description Override to get Service name to be used when looking up custom settings for the service
	 *
	 * @return String Returns service name as string
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Override to use Get HTTP Method for API call
	 *
	 * @return String
	 */
	public override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Override to set identifier indicating Triggering object id is not required for this API call
	 *
	 * @return Boolean
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock AW_API_RestOutboundWorkflowTasksMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AW_API_RestOutboundWorkflowTasksMock();
	}

	/**
	 * @description Override to validate if all the information required to make API call is available
	 *
	 * @return Boolean Returns true if all the information is present, else will return false
	 */
	protected override Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			if(String.isBlank(queueItem.CMN_PartnerCode__c))
			{
				mustAbort = true;
				callResult.errors.add(ERROR_CONSULTANT_CODE_NOT_FOUND);
			}

			List<User> advisers = AW_DAL_User.findByConsultantCode(new Set<String>
			{
					queueItem.CMN_PartnerCode__c
			});

			if(advisers != null && advisers.isEmpty())
			{
				mustAbort = true;
				callResult.errors.add(ERROR_ADVISER_NOT_FOUND);
			}
			else
			{
				adviser = advisers[0];
			}
		}

		return mustAbort;
	}

	/**
	 * @description Override to construct API endpoint
	 *
	 * @return String Complete API Endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		return String.format(super.getWebServiceEndPoint(), new List<String> {queueItem.CMN_PartnerCode__c});
	}

	protected override void populateRequestDTO()
	{
		super.populateRequestDTO();
	}

	/**
	 * @description Override to inject JSON outer class in API response
	 *
	 * @return String Response body
	 */
	protected override String getResponseBody()
	{
		String responseBody = super.getResponseBody();

		//We have to inject a JSON outer class because we are receiving an Array Response
		return '{' + FMT_JSON_OUTER_ATTR_NAME + responseBody + '}';
	}

	/**
	 * @description Override to set SObject types for DML operation
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType>
		{
				AW_Outstanding_Requirement__c.SObjectType
		});
	}

	/**
	 * @description Override to process API response and create/ update workflow tasks in salesforce
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Response dtoWorkflowTasks = (DTO_Response)baseResponseDTO;

		updateWorkflowTasks(dtoWorkflowTasks.workflowTasks);
	}

	private void updateWorkflowTasks(List<DTO_WorkflowTask> workflowTasks)
	{
		if(!workflowTasks.isEmpty())
		{
			Map<String, List<AW_Outstanding_Requirement__c>> tasksListByContractNumber = new Map<String, List<AW_Outstanding_Requirement__c>>();

			Map<String, SObject> existingWFTasks = new Map<String, SObject>();

			List<AW_Outstanding_Requirement__c> existingTaskList = AW_DAL_OutstandingRequirement.findByOwnerId(adviser.Id);

			if(!existingTaskList.isEmpty())
			{
				existingWFTasks = CMN_UTIL_System.convertListToSingleStringMap(existingTaskList, AW_DAL_OutstandingRequirement.FIELD_UPDATE_ISN);
			}

			Map<String, List<Account>> accounts = populateAccountMap(workflowTasks);

			for(DTO_WorkflowTask workflowTask : workflowTasks)
			{
				AW_Outstanding_Requirement__c task = (AW_Outstanding_Requirement__c)existingWFTasks.get(workflowTask.UpdateISN);

				if(task == null)
				{
					task = new AW_Outstanding_Requirement__c();
					task.AW_UpdateISN__c = workflowTask.UpdateISN;
				}
				else
				{
					existingWFTasks.remove(workflowTask.UpdateISN);
				}

				task.AW_Source__c = workflowTask.Source;

				//to remove appended Zeroes if any
				//Contract Number may appended by Zero by Pinball System
				String contractNumberFormatted = CMN_UTIL_String.stripStart(workflowTask.ContractNumber, ZERO_STRING);

				task.AW_ContractNumber__c = contractNumberFormatted;

				List<AW_Outstanding_Requirement__c> tasksList = tasksListByContractNumber.get(contractNumberFormatted);

				if(tasksList == null)
				{
					tasksList = new List<AW_Outstanding_Requirement__c>();
				}
				tasksList.add(task);
				tasksListByContractNumber.put(contractNumberFormatted, tasksList);

				if(String.isNotBlank(workflowTask.ProcessingStatus))
				{
					String processingStatus = PINBALL_STATUS_CODE_MAPPING.get(workflowTask.ProcessingStatus);
					task.AW_Pinball_Code__c = workflowTask.ProcessingStatus;

					if(processingStatus != null)
					{
						task.AW_ProcessingStatus__c = processingStatus;
					}
				}
				else
				{
					task.AW_ProcessingStatus__c = STR_IN_PROGRESS;
					task.AW_Pinball_Code__c = STR_ZERO;
				}

				task.AW_Role__c = workflowTask.Role;
				task.AW_Initials__c = workflowTask.Initials;
				task.AW_LastName__c = workflowTask.LastName;
				task.AW_IdentityNumber__c = workflowTask.IdentityNumber;

				if(accounts.containsKey(workflowTask.IdentityNumber))
				{
					task.AW_Account__c = accounts.get(workflowTask.IdentityNumber)[0].Id;
				}
				else
				{
					task.AW_Account__c = null;
				}

				task.AW_Key__c = workflowTask.Key;
				task.AW_Description__c = workflowTask.Description;

				if(String.isNotBlank(workflowTask.RequirementDate))
				{
					task.AW_RequirementDate__c = CMN_UTIL_Date.sapStringToDate(workflowTask.RequirementDate);
				}

				task.AW_Status__c = workflowTask.Status;
				task.OwnerId = adviser.Id;
			}

			List<AW_Outstanding_Requirement__c> updatedTasks = linkTasksWithOpportunities(tasksListByContractNumber);

			updateRelatedOpportunities(updatedTasks);

			if(!existingWFTasks.isEmpty())
			{
				registerDeleted(existingWFTasks.values());
			}
		}
	}

	private Map<String, List<Account>> populateAccountMap(List<DTO_WorkflowTask> workflowTasks)
	{
		Set<String> identificationNumbers = new Set<String>();
		Map<String, List<Account>> accounts = new Map<String, List<Account>>();

		for(DTO_WorkflowTask task : workflowTasks)
		{
			if(String.isNotBlank(task.IdentityNumber))
			{
				identificationNumbers.add(task.IdentityNumber);
			}
		}

		if(!identificationNumbers.isEmpty())
		{
			List<Account> accountsList = AW_DAL_Account.findAccountsByOwnerAndIdNumbers(adviser, identificationNumbers);

			if(!accountsList.isEmpty())
			{
				accounts = CMN_UTIL_System.convertListToStringMap(accountsList, AW_DAL_Account.FIELD_IDENTIFICATION_NUMBER);
			}
		}
		return accounts;
	}

	@TestVisible
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		@TestVisible
		private List<DTO_WorkflowTask> workflowTasks = new List<DTO_WorkflowTask>();

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
	@SuppressWarnings('PMD.FieldNamingConventions, ApexControlFlowAnalysis')
	private class DTO_WorkflowTask
	{
		private String Source;
		public String ContractNumber;
		//private String SequenceNumber;
		//private String TechnicalStatus;
		private String ProcessingStatus;
		private String Role;
		private String Initials;
		private String LastName;
		private String IdentityNumber;
		private String Key;
		private String Description;
		private String RequirementDate;
		private String Status;
		private String UpdateISN;
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	public class AW_API_RestOutboundWorkflowTasksMock extends CMN_API_HttpBaseOutboundMock
	{
		@TestVisible
		private final String validResponse = '[ { "Source": "PINBALLSER", "ContractNumber": "000055005601100", "SequenceNumber": "01", "TechnicalStatus": "L", ' +
				'"ProcessingStatus": "0", "Role": "LI", "Initials": "MA", "LastName": "TOMPSETT", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - ' +
				'FAX (011)408-4171 OR ELEC UPLOAD ROA", "RequirementDate": "20180316", "Status": "Required", "UpdateISN": "0000049447" }, ' +
				'{ "Source": "PINBALLSER", "ContractNumber": "000059999603900", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "' +
				mockProcessingStatus + '", "Role": "LI", "Initials": "M", "LastName": "JACKSON", "IdentityNumber": "' + mockIdentificationNumber +
				'", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171 OR ELEC UPLOAD ROA", "RequirementDate": "20170207", "Status": "Validated", "UpdateISN": "' +
				mockUpdateIsn + '" }, { "Source": "PINBALLSER", "ContractNumber": "000059999603900", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "2", "Role": ' +
				'"LI", "Initials": "M", "LastName": "JACKSON", "IdentityNumber": "8002208701175", "Key": "T2321", "Description": "CONFIRM DATE OF COMMENCEMENT PLA", ' +
				'"RequirementDate": "20170207", "Status": "Validated", "UpdateISN": "0000096974" }, { "Source": "PINBALLSER", "ContractNumber": "000059999541800", ' +
				'"SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "0", "Role": "LI", "Initials": "M", "LastName": "DHONI", "IdentityNumber": ' +
				'"7706068635080", "Key": "T2127", "Description": "TELE-UW PENDED PRINCIPAL LIFE", "RequirementDate": "20170207", "Status": "Required", "UpdateISN": "0000096995" }, ' +
				'{ "Source": "PINBALLSER", "ContractNumber": "000059999543200", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "0", "Role": "LI", "Initials": ' +
				'"MH", "LastName": "DHONIBC", "IdentityNumber": "7706068635080", "Key": "T2127", "Description": "TELE-UW PENDED PRINCIPAL LIFE", "RequirementDate": "20170207", ' +
				'"Status": "Required", "UpdateISN": "0000096986" }, { "Source": "PINBALLSER", "ContractNumber": "000059999543200", "SequenceNumber": "01", "TechnicalStatus": "L", ' +
				'"ProcessingStatus": "0", "Role": "LI", "Initials": "MH", "LastName": "DHONIBC", "IdentityNumber": "7706068635080", "Key": "T2591", "Description": ' +
				'"DIGITAL RISK APPLICATION AND PENDED FOR VERIFICATION", "Status": "Required", "UpdateISN": "0000096987" }, { "Source": "PINBALLSER", "ContractNumber": ' +
				'"000000013129604", "SequenceNumber": "02", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", "LastName": "LEMMER", "IdentityNumber": ' +
				'"0000000000000", "Key": "T1736", "Description": "FULL FICA COMPLIANCE REQUIREMENTS TO BE SUBMITTED", "RequirementDate": "20170208", "Status": "Required", "UpdateISN":' +
				' "0000097096" }, { "Source": "PINBALLSER", "ContractNumber": "000059999732000", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", ' +
				'"Initials": "TG", "LastName": "TEST", "Key": "T1737", "Description": "ONE PAGE CONFIRMATION FICA REQUIREMENTS TO BE SUBMITTED", "Status": "Validated", "UpdateISN": ' +
				'"0000097138" }, { "Source": "PINBALLSER", "ContractNumber": "000059999732000", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI",' +
				' "Initials": "TG", "LastName": "TEST", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171 OR ELEC UPLOAD ROA", "RequirementDate": "20170209",' +
				' "Status": "Validated", "UpdateISN": "0000097129" }, { "Source": "PINBALLSER", "ContractNumber": "000059999732000", "SequenceNumber": "01", "TechnicalStatus": "L", ' +
				'"ProcessingStatus": "3", "Role": "LI", "Initials": "TG", "LastName": "TEST", "Key": "T1954", "Description": "REQUIRE COPY UTILITY BILL WITH RESIDENTIAL ADDRESS FOR ' +
				'FICA", "RequirementDate": "20180605", "Status": "Required", "UpdateISN": "0000097136" }, { "Source": "PINBALLSER", "ContractNumber": "000059999732000", ' +
				'"SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "TG", "LastName": "TEST", "Key": "T1955", "Description": ' +
				'"REQUIRE COPY ID DOCUMENT FOR FICA COMPLIANCE", "Status": "Validated", "UpdateISN": "0000097137" }, { "Source": "PINBALLSER", "ContractNumber": "000059999732000", ' +
				'"SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "TG", "LastName": "TEST", "Key": "T2468", "Description": ' +
				'"NON SA CITIZEN: PROOF OF SA BANK ACCOUNT", "RequirementDate": "20180605", "Status": "Required", "UpdateISN": "0000097140" }, { "Source": "PINBALLSER", ' +
				'"ContractNumber": "000059999732000", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "TG", "LastName": "TEST", ' +
				'"Key": "T2478", "Description": "IDCQ - IDENTITY CONFIRMATION", "Status": "Validated", "UpdateISN": "0000097141" }, { "Source": "PINBALLSER", "ContractNumber": ' +
				'"000059999732000", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "TG", "LastName": "TEST", "Key": "T2590", ' +
				'"Description": "CLIENT SOURCE OF FUNDS REQUIRED", "Status": "Validated", "UpdateISN": "0000097139" }, { "Source": "PINBALLSER", "ContractNumber": "000059999627300", ' +
				'"SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "P", "LastName": "PLOPPY", "IdentityNumber": "8505169375979", ' +
				'"Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171 OR ELEC UPLOAD ROA", "RequirementDate": "20170209", "Status": "Required", "UpdateISN": ' +
				'"0000097157" }, { "Source": "PINBALLSER", "ContractNumber": "000000064721142", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": ' +
				'"LI", "Initials": "S", "LastName": "SINGH", "IdentityNumber": "7001016520729", "Key": "T1575", "Description": "TAX CLEARANCE CERTIFICATE IF ABOVE R1 000 000", ' +
				'"RequirementDate": "20170209", "Status": "Required", "UpdateISN": "0000097206" }, { "Source": "PINBALLSER", "ContractNumber": "000000064721142", "SequenceNumber": ' +
				'"01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", "LastName": "SINGH", "IdentityNumber": "7001016520729", "Key": "T1576", ' +
				'"Description": "CLIENT AUTHORITY FOR EXCELSIOR INTERNATIONAL CAPITAL BOND", "RequirementDate": "20170209", "Status": "Required", "UpdateISN": "0000097203" }, ' +
				'{ "Source": "PINBALLSER", "ContractNumber": "000000064721142", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", ' +
				'"LastName": "SINGH", "IdentityNumber": "7001016520729", "Key": "T1577", "Description": "FORM A - APPLICATION TO PURCHASE FOREIGN EXCHANGE", "RequirementDate": ' +
				'"20170209", "Status": "Required", "UpdateISN": "0000097204" }, { "Source": "PINBALLSER", "ContractNumber": "000000064721142", "SequenceNumber": "01", ' +
				'"TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", "LastName": "SINGH", "IdentityNumber": "7001016520729", "Key": "T1579", ' +
				'"Description": "ID DOCUMENT", "RequirementDate": "20170209", "Status": "Required", "UpdateISN": "0000097205" }, { "Source": "PINBALLSER", "ContractNumber": ' +
				'"000000064721142", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", "LastName": "SINGH", "IdentityNumber":' +
				' "7001016520729", "Key": "T1737", "Description": "ONE PAGE CONFIRMATION FICA REQUIREMENTS TO BE SUBMITTED", "RequirementDate": "20170209", "Status": "Validated", ' +
				'"UpdateISN": "0000097202" }, { "Source": "PINBALLSER", "ContractNumber": "000000064721142", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", ' +
				'"Role": "LI", "Initials": "S", "LastName": "SINGH", "IdentityNumber": "7001016520729", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171 OR ' +
				'ELEC UPLOAD ROA", "RequirementDate": "20170209", "Status": "Validated", "UpdateISN": "0000097198" }, { "Source": "PINBALLSER", "ContractNumber": "000000064721142", ' +
				'"SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", "LastName": "SINGH", "IdentityNumber": "7001016520729", ' +
				'"Key": "T1954", "Description": "REQUIRE COPY UTILITY BILL WITH RESIDENTIAL ADDRESS FOR FICA", "RequirementDate": "20170209", "Status": "Validated", "UpdateISN": ' +
				'"0000097200" }, { "Source": "PINBALLSER", "ContractNumber": "000000064721142", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", ' +
				'"Initials": "S", "LastName": "SINGH", "IdentityNumber": "7001016520729", "Key": "T1955", "Description": "REQUIRE COPY ID DOCUMENT FOR FICA COMPLIANCE", ' +
				'"RequirementDate": "20170209", "Status": "Validated", "UpdateISN": "0000097201" }, { "Source": "PINBALLSER", "ContractNumber": "000000064721142", "SequenceNumber": ' +
				'"01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", "LastName": "SINGH", "IdentityNumber": "7001016520729", "Key": "T2213", ' +
				'"Description": "ADVICE FEE MANDATE - PLEASE SEND TO NEW BUSINESS", "RequirementDate": "20170209", "Status": "Validated", "UpdateISN": "0000097199" }, ' +
				'{ "Source": "PINBALLSER", "ContractNumber": "000000064721142", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", ' +
				'"LastName": "SINGH", "IdentityNumber": "7001016520729", "Key": "T2590", "Description": "CLIENT SOURCE OF FUNDS REQUIRED", "RequirementDate": "20170209", "Status": ' +
				'"Validated", "UpdateISN": "0000097207" }, { "Source": "PINBALLSER", "ContractNumber": "000059999132600", "SequenceNumber": "01", "TechnicalStatus": "L", ' +
				'"ProcessingStatus": "0", "Role": "LI", "Initials": "J", "LastName": "CHETTY", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171 OR ' +
				'ELEC UPLOAD ROA", "RequirementDate": "20170202", "Status": "Required", "UpdateISN": "0000045781" }, { "Source": "PINBALLSER", "ContractNumber": "000000051815139", ' +
				'"SequenceNumber": "02", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", "LastName": "NAIDOO", "IdentityNumber": "6911085290080", ' +
				'"Key": "T1736", "Description": "FULL FICA COMPLIANCE REQUIREMENTS TO BE SUBMITTED", "RequirementDate": "20170202", "Status": "Required", "UpdateISN": "0000060348" }, ' +
				'{ "Source": "PINBALLSER", "ContractNumber": "000000051815139", "SequenceNumber": "02", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "S", ' +
				'"LastName": "NAIDOO", "IdentityNumber": "6911085290080", "Key": "T2558", "Description": "TAX EXEMPTION CERTIFICATE REQUIRED", "RequirementDate": "20170202", "Status": ' +
				'"Required", "UpdateISN": "0000060111" }, { "Source": "PINBALLSER", "ContractNumber": "000000066700148", "SequenceNumber": "01", "TechnicalStatus": "L", ' +
				'"ProcessingStatus": "3", "Role": "LI", "Initials": "B", "LastName": "NOBODY", "Key": "T1623", "Description": "AWAIT MONEY", "RequirementDate": "20180307", ' +
				'"Status": "Required", "UpdateISN": "0000048327" }, { "Source": "PINBALLSER", "ContractNumber": "000000066700148", "SequenceNumber": "01", "TechnicalStatus": "L", ' +
				'"ProcessingStatus": "3", "Role": "LI", "Initials": "B", "LastName": "NOBODY", "Key": "T1737", "Description": "ONE PAGE CONFIRMATION FICA REQUIREMENTS TO BE SUBMITTED",' +
				' "RequirementDate": "20180307", "Status": "Required", "UpdateISN": "0000048325" }, { "Source": "PINBALLSER", "ContractNumber": "000000066700148", "SequenceNumber": ' +
				'"01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "B", "LastName": "NOBODY", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - ' +
				'FAX (011)408-4171 OR ELEC UPLOAD ROA", "RequirementDate": "20180307", "Status": "Required", "UpdateISN": "0000048322" }, { "Source": "PINBALLSER", "ContractNumber": ' +
				'"000000066700148", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "B", "LastName": "NOBODY", "Key": "T1954", ' +
				'"Description": "REQUIRE COPY UTILITY BILL WITH RESIDENTIAL ADDRESS FOR FICA", "RequirementDate": "20180307", "Status": "Required", "UpdateISN": "0000048323" }, ' +
				'{ "Source": "PINBALLSER", "ContractNumber": "000000066700148", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "B", ' +
				'"LastName": "NOBODY", "Key": "T1955", "Description": "REQUIRE COPY ID DOCUMENT FOR FICA COMPLIANCE", "RequirementDate": "20180307", "Status": "Required", ' +
				'"UpdateISN": "0000048324" }, { "Source": "PINBALLSER", "ContractNumber": "000000066700148", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", ' +
				'"Role": "LI", "Initials": "B", "LastName": "NOBODY", "Key": "T2469", "Description": "NON SA CITIZEN: PROOF OF SA INCOME TAX NUMBER", "Status": "Required", "UpdateISN": ' +
				'"0000048326" }, { "Source": "PINBALLSER", "ContractNumber": "000059995448000", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "0", "Role": "LI",' +
				' "Initials": "S", "LastName": "ZARA", "IdentityNumber": "9112110414657", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171 OR ELEC UPLOAD ROA", ' +
				'"RequirementDate": "20161109", "Status": "Validated", "UpdateISN": "0000105955" }, { "Source": "PINBALLSER", "ContractNumber": "000052638222100", "SequenceNumber": ' +
				'"01", "TechnicalStatus": "L", "ProcessingStatus": "0", "Role": "LI", "Initials": "B", "LastName": "BLUE", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - ' +
				'FAX (011)408-4171 OR ELEC UPLOAD ROA", "RequirementDate": "20161221", "Status": "Required", "UpdateISN": "0000116604" }, { "Source": "PINBALLSER", "ContractNumber": ' +
				'"000059999127800", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "J", "LastName": "SMITH", "IdentityNumber":' +
				' "8002028676961", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171 OR ELEC UPLOAD ROA", "RequirementDate": "20170131", "Status": "Required", ' +
				'"UpdateISN": "0000122214" }, { "Source": "PINBALLSER", "ContractNumber": "000059847481300", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "1",' +
				' "Role": "LI", "Initials": "U", "LastName": "GHDGKHJ", "IdentityNumber": "8012012548902", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171' +
				' OR ELEC UPLOAD ROA", "RequirementDate": "20160510", "Status": "Required", "UpdateISN": "0000074356" }, { "Source": "PINBALLSER", "ContractNumber": "000000064009400",' +
				' "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "A", "LastName": "JOHNSON", "IdentityNumber": "6503145183080", ' +
				'"Key": "T1623", "Description": "AWAIT MONEY", "RequirementDate": "20160714", "Status": "Required", "UpdateISN": "0000074182" }, { "Source": "PINBALLSER", ' +
				'"ContractNumber": "000000064009400", "SequenceNumber": "01", "TechnicalStatus": "L", "ProcessingStatus": "3", "Role": "LI", "Initials": "A", "LastName": "JOHNSON", ' +
				'"IdentityNumber": "6503145183080", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171 OR ELEC UPLOAD ROA", "RequirementDate": "20160418", ' +
				'"Status": "Required", "UpdateISN": "0000074181" }, { "Source": "PINBALLSER", "ContractNumber": "000055029227700", "SequenceNumber": "01", "TechnicalStatus": "L", ' +
				'"ProcessingStatus": "0", "Role": "LI", "Initials": "H", "LastName": "HOOPS", "Key": "T1804", "Description": "REQ RECORD OF ADVICE - FAX (011)408-4171 OR ELEC UPLOAD ' +
				'ROA", "RequirementDate": "20180511", "Status": "Required", "UpdateISN": "0000059674" } ]';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	/**
	 * @description Link the workflow tasks (outstanding requirements) with their corresponding opportunities.
	 *
	 * @param tasksListByContractNumber List of AW_Outstanding_Requirement__c
	 *
	 * @return List<AW_Outstanding_Requirement__c>
	 */
	private List<AW_Outstanding_Requirement__c> linkTasksWithOpportunities(Map<String, List<AW_Outstanding_Requirement__c>> tasksListByContractNumber)
	{
		List<AW_Outstanding_Requirement__c> updatedTasks = new List<AW_Outstanding_Requirement__c>();

		Set<String> contractNumbers = new Set<String>(tasksListByContractNumber.keySet());

		List<AW_Quoted_Solution__c> quotedSolutions = AW_DAL_QuotedSolution.findByContractNumber(contractNumbers);

		// map the quoted solutions and the related quote id by the contract number
		Map<String, List<AW_Quoted_Solution__c>> quotedSolutionsByContractNumber = new Map<String, List<AW_Quoted_Solution__c>>();
		Map<String, Id> quoteIdByContractNumber = new Map<String, Id>();
		for(AW_Quoted_Solution__c quotedSolution : quotedSolutions)
		{
			List<AW_Quoted_Solution__c> quotedSolutionsList = quotedSolutionsByContractNumber.get(quotedSolution.AW_Contract_Number__c);
			if(quotedSolutionsList == null)
			{
				quotedSolutionsList = new List<AW_Quoted_Solution__c>();
			}
			quotedSolutionsList.add(quotedSolution);
			quotedSolutionsByContractNumber.put(quotedSolution.AW_Contract_Number__c, quotedSolutionsList);
			quoteIdByContractNumber.put(quotedSolution.AW_Contract_Number__c, quotedSolution.AW_Quote_Name__c);
		}

		Set<Id> quotesIds = new Set<Id>(quoteIdByContractNumber.values());
		Map<Id, Quote> quotesByIds = new Map<Id, Quote>(AW_DAL_Quote.findById(quotesIds));

		// link each outstanding requirement (workflow task) with the corresponding opportunity
		for(String contractNumber : contractNumbers)
		{
			Id quoteId = quoteIdByContractNumber.get(contractNumber);
			Quote quote = quotesByIds.get(quoteId);

			List<AW_Outstanding_Requirement__c> tasksListToUpdate = tasksListByContractNumber.get(contractNumber);

			for(AW_Outstanding_Requirement__c taskToUpdate : tasksListToUpdate)
			{
				if(quote != null)
				{
					taskToUpdate.AW_Opportunity__c = quote.OpportunityId;
				}
				registerChange(taskToUpdate);
				updatedTasks.add(taskToUpdate);
			}
		}

		return updatedTasks;
	}

	/**
	 * @description Update the stages of the opportunities related to the given workflow tasks (outstanding requirements).
	 *
	 * @param tasks List of AW_Outstanding_Requirement__c
	 */
	private static void updateRelatedOpportunities(List<AW_Outstanding_Requirement__c> tasks)
	{
		Map<Id, List<AW_Outstanding_Requirement__c>> tasksByOpportunityId = new Map<Id, List<AW_Outstanding_Requirement__c>>();

		// map the outstanding requirements (workflow tasks) by their related opportunity
		for(AW_Outstanding_Requirement__c task : tasks)
		{
			List<AW_Outstanding_Requirement__c> tasksList = tasksByOpportunityId.get(task.AW_Opportunity__c);
			if(tasksList == null)
			{
				tasksList = new List<AW_Outstanding_Requirement__c>();
			}
			tasksList.add(task);
			tasksByOpportunityId.put(task.AW_Opportunity__c, tasksList);
		}

		List<Opportunity> opportunitiesToUpdate = AW_DAL_Opportunity.findById(tasksByOpportunityId.keySet());

		// updated the stage of each related opportunity
		for(Opportunity opportunity : opportunitiesToUpdate)
		{
			List<AW_Outstanding_Requirement__c> tasksList = tasksByOpportunityId.get(opportunity.Id);
			AW_Outstanding_Requirement__c highestTask = findHighestTask(tasksList);

			setOpportunityStage(opportunity, highestTask);
		}

		CMN_DAL_SObjectDomain.updateDBObjects(opportunitiesToUpdate, true);
	}

	/**
	 * @description Find the workflow task (outstanding requirement) corresponding to an opportunity stage with the highest priority.
	 *
	 * @param tasks List of the AW_Outstanding_Requirement__c
	 *
	 * @return AW_Outstanding_Requirement__c
	 */
	private static AW_Outstanding_Requirement__c findHighestTask(List<AW_Outstanding_Requirement__c> tasks)
	{
		if(tasks == null || tasks.size() == 0)
		{
			return null;
		}

		AW_Outstanding_Requirement__c highestTask = tasks.get(0);
		String highestTaskOpportunityStage = PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.get(highestTask.AW_Pinball_Code__c);
		Integer highestTaskPriority = OPPORTUNITY_STAGES_MAPPED_WITH_PRIORITIES.get(highestTaskOpportunityStage);

		for(AW_Outstanding_Requirement__c task : tasks)
		{
			String taskOpportunityStage = PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.get(task.AW_Pinball_Code__c);
			Integer taskPriority = OPPORTUNITY_STAGES_MAPPED_WITH_PRIORITIES.get(taskOpportunityStage);

			if(taskPriority > highestTaskPriority)
			{
				highestTask = task;
				highestTaskOpportunityStage = PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.get(highestTask.AW_Pinball_Code__c);
				highestTaskPriority = OPPORTUNITY_STAGES_MAPPED_WITH_PRIORITIES.get(highestTaskOpportunityStage);
			}
		}

		return highestTask;
	}

	/**
	 * @description Sets the stage of the given opportunity depending on the given workflow task (outstanding requirement).
	 *
	 * @param opportunity Opportunity
	 * @param task AW_Outstanding_Requirement__c
	 */
	private static void setOpportunityStage(Opportunity opportunity, AW_Outstanding_Requirement__c task)
	{
		if(task != null)
		{
			opportunity.StageName = PINBALL_STATUS_CODE_MAPPED_WITH_OPPORTUNITY_STAGE.get(task.AW_Pinball_Code__c);
		}
	}
}