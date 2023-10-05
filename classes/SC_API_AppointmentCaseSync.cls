/**
 * @description API handler to support appointment case synchronisation
 *
 * @see SC_URL_AppointmentCaseSync @story ST-318497
 * @see SC_API_AppointmentCaseSync_TEST
 *
 * @author mthobisi.ndlovu@accenture.com, vijay.jayswal@acceture.com
 *
 * @date August 2022, May 2023
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.ExcessivePublicCount')
public inherited sharing class SC_API_AppointmentCaseSync extends SC_API_CaseSynchronisation
{
	private CMN_UTIL_SObjectIndex caseNumberToCaseExtensionMap;
	private CMN_UTIL_SObjectIndex caseNumberToExistingCaseMap;
	private CMN_UTIL_SObjectIndex contractNumberToAssociatedContractMap;
	private Map<String, User> uacfIdToAgentMap;
	private String clientIdNumber;
	private String masterContractNumber;
	private final Set<Object> existingCaseNumbers = new Set<Object>();
	private final Set<String> caseNumbers = new Set<String>();
	private final Set<String> personalityDatabaseIds = new Set<String>();
	private final Set<String> uacfIds = new Set<String>();
	private static final String CASE_SYNC_SUCCESSFUL = 'Case added successfully';
	private static final String DASH = '-';
	@TestVisible
	private static final String ERROR_CLIENT_LAST_NAME_NOT_FOUND = 'Request failed to process because the client  surname name was not found';
	@TestVisible
	private static final String ERROR_CLIENT_NAME_NOT_FOUND = 'Request failed to process because the client  first name was not found';
	@TestVisible
	private static final String ERROR_CLIENT_SUBURB_NOT_FOUND = 'Request failed to process because the client suburb was not found';
	@TestVisible
	private static final String ERROR_CONSULTANT_CODE_NOT_FOUND = 'Request failed to process because the consultant code was not found';
	@TestVisible
	private static final String ERROR_ID_NUMBER_NOT_FOUND = 'Request failed to process because Identification Number was not found';
	@TestVisible
	private static final String ERROR_NO_CONTACT_NUMBER_FOUND = 'Request failed to process because no contact number was found';
	private static final String UNDERSCORE = '_';

	/**
	 * @description stores the name of the service which can be referenced in test class
	 */
	public static final String SERVICE_NAME = SC_API_AppointmentCaseSync.class.getName();

	/**
	 * @description Initialise variable Object variables
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Will check that the information received is valid and query any related data
	 */
	protected override void processRequest()
	{
		super.processRequest();

		DTO_Request request = (DTO_Request)baseRequestDTO;
		for(DTO_AppointmentCase requestCase : request.cases)
		{
			canProcessRequest(requestCase);
			collectCaseInformation(requestCase);
		}
		createServiceTypeMap();
		getCaseQueueId();
		createConsultantCodeToConsultantMap(consultantCodes);
		createMasterAccountMapByIdNumber(identificationNumbers);
		createContractNumberToPolicyMap(contractNumbers);
	}

	/**
	 * @description This will collect various information from the inbound case to be used in later methods
	 *
	 * @param requestCase The inbound underwriting case
	 */
	private void collectCaseInformation(DTO_AppointmentCase requestCase)
	{
		masterContractNumber = requestCase.caseDetail?.contractNumber;
		clientIdNumber = requestCase.client?.identificationNumber;
		contractNumbers.add(masterContractNumber);
		caseNumbers.add(requestCase.caseDetail?.caseNumber);
		existingCaseNumbers.add(Integer.valueOf(CMN_UTIL_String.trim(requestCase.caseDetail?.caseNumber)));
		identificationNumbers.add(requestCase.client?.identificationNumber);
		consultantCodes.add(requestCase.consultant?.code);
		uacfIds.add(requestCase.caseDetail?.uacfId);
		Integer serviceTypeNumber = CMN_UTIL_String.isNotBlank(requestCase.caseDetail?.serviceType)
				? Integer.valueOf(requestCase.caseDetail?.serviceType) : null;
		serviceTypeCodes.add(serviceTypeNumber);

		if(requestCase.concurrentContractNumbers != null)
		{
			for(DTO_Contract contract : requestCase.concurrentContractNumbers)
			{
				contractNumbers.add(contract.concurrentContract);
			}
		}

		contractNumbers = CMN_UTIL_System.trimSet(contractNumbers);
	}

	/**
	 * @description Will check the incoming request and ensure all relevant (required) information is provided
	 *
	 * @param requestCase The inbound underwriting case
	 */
	private void canProcessRequest(DTO_AppointmentCase requestCase)
	{
		String errorMessage;

		personalityDatabaseIds.add(requestCase.client?.pdbId);

		if(String.isBlank(requestCase.client.fullName))
		{
			errorMessage = ERROR_CLIENT_NAME_NOT_FOUND;
		}
		else if(String.isBlank(requestCase.client.identificationNumber))
		{
			errorMessage = ERROR_ID_NUMBER_NOT_FOUND;
		}
		else if(String.isBlank(requestCase.client.cellularPhoneNumber) && String.isBlank(requestCase.client.workTelephoneNumber) && String.isBlank(requestCase.client.homeTelephoneNumber))
		{
			errorMessage = ERROR_NO_CONTACT_NUMBER_FOUND;
		}
		else if(String.isBlank(requestCase.consultant.code))
		{
			errorMessage = ERROR_CONSULTANT_CODE_NOT_FOUND;
		}
		else if(String.isBlank(requestCase.client.surname))
		{
			errorMessage = ERROR_CLIENT_LAST_NAME_NOT_FOUND;
		}
		else if(String.isBlank(requestCase.client.suburb))
		{
			errorMessage = ERROR_CLIENT_SUBURB_NOT_FOUND;
		}

		if(String.isNotBlank(errorMessage))
		{
			throw new IllegalArgumentException(errorMessage);
		}
	}

	/**
	 * @description update response with synced case numbers
	 */
	protected override void updateResponseDTO()
	{
		super.updateResponseDTO();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
		dtoResponse.cases = new List<DTO_SyncedCase>();

		for(String caseNumber : caseNumbers)
		{
			DTO_SyncedCase syncedCase = new DTO_SyncedCase();
			syncedCase.caseNumber = caseNumber;
			dtoResponse.cases.add(syncedCase);
		}
	}
	/**
	 * @description override to set the data in case of any errors that occurred
	 *
	 * @param error the exception that needs to be managed
	 */
	public override void handleError(Exception error)
	{
		super.handleError(error);

		List<DTO_Error> errors = new List<DTO_Error>();

		for(String personalityDatabaseId : personalityDatabaseIds)
		{
			DTO_Error err = new DTO_Error();
			err.errorCode = callResult.statusCode;
			err.pdbId = personalityDatabaseId;
			err.message = error.getMessage();
			errors.add(err);
		}
		responseBody = JSON.serializePretty(errors, true);

		callResult.responseBody = responseBody;
		callResult.errors = new List<String> {responseBody};
	}
	/**
	 * @description Will ensure that the change to case is registered to be committed after
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		uacfIdToAgentMap = SC_DAL_User.getAgentMapByUacfId(uacfIds);
		caseNumberToCaseExtensionMap = SC_DAL_CaseExtension.generateCaseNumberToCaseExtensionMap(caseNumbers, clientIdNumber);

		//get existing cases
		List<Case> existingCases = SC_DAL_Case.findByCaseClientNumber(existingCaseNumbers, clientIdNumber);
		caseNumberToExistingCaseMap = new CMN_UTIL_SObjectIndex(SC_DAL_Case.FIELD_WORKFLOW_CASE_NUMBER).putAll(existingCases);
		Set<Id> caseIds = CMN_UTIL_System.extractListIds(existingCases);
		contractNumberToAssociatedContractMap =
				new CMN_UTIL_SObjectIndex(SC_DAL_AssociatedContract.FIELD_ASSOCIATED_CONTRACT_EXTENSION_CONTRACT_NUMBER).putAll(SC_DAL_AssociatedContract.findByCaseId(caseIds));

		Set<String> caseExtensionIds = CMN_UTIL_System.extractSetValues
				(
						existingCases,
						Case.SC_CaseExtension__c.getDescribe().getLocalName()
				);
		createContractNumberToAssocContractExtMap(caseExtensionIds);
		DTO_Request request = (DTO_Request)baseRequestDTO;
		processCaseCreation(request.cases);
	}

	/**
	 * @description This method processes the creation of medical appointment cases
	 * 				and related records
	 *
	 * @param requestCases The list of all cases received with the request
	 */
	private void processCaseCreation(List<DTO_AppointmentCase> requestCases)
	{
		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName
				(
						SC_CaseExtension__c.SObjectType,
						SC_DAL_CaseExtension.RT_MEDICAL_APPOINTMENT
				);
		Id caseRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName
				(
						Case.SObjectType,
						SC_DAL_Case.RT_RETAIL
				);
		Map<String, SC_RegionMapping__mdt> medicalAppointmentRegionMapping = SC_DAL_RegionMapping.getAll();
		for(DTO_AppointmentCase reqCase : requestCases)
		{
			//add case extension record
			SC_CaseExtension__c caseExtension = populateCaseExtensionRecord(reqCase, recordTypeId, medicalAppointmentRegionMapping);
			//add a case record
			Case aCase = populateCaseRecord(caseRecordTypeId, reqCase);
			registerRelationship(aCase, Case.SC_CaseExtension__c, caseExtension);
			populateAssociatedContractExtension(aCase, reqCase.consultant, caseExtension);
			//Add WorkOrder  and WorkOrderLineItem record
			if((!aCase.Status.equalsIgnoreCase(SC_DAL_Case.STATUS_CLOSED)
					&& !aCase.Status.equalsIgnoreCase(SC_DAL_Case.STATUS_RESOLVED)))
			{
				populateWorkOrder(aCase, reqCase.medicalRequirements);
			}
		}
	}

	/**
	 * @description This method populates the case  record
	 *
	 * @param caseRecordTypeId Retail Case Record Type Id
	 * @param dtoRequestCase The request case record
	 *
	 * @return Case record
	 */
	private Case populateCaseRecord(Id caseRecordTypeId, DTO_AppointmentCase dtoRequestCase)
	{
		//Contact number to add on the subject string
		String contactNumber = CMN_UTIL_String.isNotBlank(dtoRequestCase.client.workTelephoneNumber) ? dtoRequestCase.client.workTelephoneNumber
				: dtoRequestCase.client.cellularPhoneNumber;
		//Case subject
		String subject = dtoRequestCase.client.title + DASH + dtoRequestCase.client.fullName + DASH + dtoRequestCase.caseDetail.nurseRegion
				+ DASH + dtoRequestCase.caseDetail.nurseSuburbOrTown + DASH + contactNumber;
		SC_ServiceType__c serviceType = ((SC_ServiceType__c)serviceTypeToServiceTypeMap.get(dtoRequestCase.caseDetail?.serviceType));
		//Owner queue Id
		Id queueId = (serviceType != null && serviceType.SC_Assignable__c) ? assignableCaseQueueId : nonAssignableCaseQueueId;
		//Consultant code record Id
		Id consultantCodeId = consultantCodeToConsultantMap != null ?
				((SC_ConsultantCodes__c)consultantCodeToConsultantMap.get(dtoRequestCase.consultant?.code))?.Id : null;

		// Agent (user) record Id
		Id assignedToId = uacfIdToAgentMap != null ? (uacfIdToAgentMap.get(dtoRequestCase.caseDetail.uacfId))?.Id : null;
		String caseNumber = dtoRequestCase.caseDetail?.caseNumber;
		Case aCase = (Case)caseNumberToExistingCaseMap.get(caseNumber);

		if(aCase == null)
		{
			aCase = new Case();

			aCase.AccountId = (identityNumberToAccountMap.get(dtoRequestCase.client?.identificationNumber))?.Id;
			aCase.Origin = CMN_UTIL_System.getPicklistValue(Case.SObjectType, Case.Origin.getDescribe().getLocalName(), SC_DAL_Case.CASE_ORIGIN_API);
			aCase.OwnerId = queueId;
			aCase.Priority = CMN_UTIL_System.getPicklistValue(Case.SObjectType, Case.Priority.getDescribe().getLocalName(), SC_DAL_Case.PRIORITY_LOW);
			aCase.RSC_ServiceType__c = serviceType?.Id;
			aCase.RSC_WorkflowCaseNumber__c = Decimal.valueOf(CMN_UTIL_String.trim(caseNumber));
			aCase.RecordTypeId = caseRecordTypeId;
			aCase.SC_AssignedTo__c = assignedToId;
			aCase.SC_ConsultantCode__c = consultantCodeId;
			aCase.Status = SC_DAL_Case.STATUS_NEW;
			aCase.Subject = subject;
		}

		aCase.Description = dtoRequestCase.caseDetail.commentText;

		registerChange(aCase);
		return aCase;
	}
	/**
	 * @description Th
	 *
	 * @param dtoRequestCase The request case record
	 * @param recordTypeId The medical appointment record type
	 * @param medicalAppointmentRegionMapping The medical appointment region mapping metadata
	 *
	 * @return case extension record
	 */
	private SC_CaseExtension__c populateCaseExtensionRecord
			(
					DTO_AppointmentCase dtoRequestCase,
					Id recordTypeId,
					Map<String, SC_RegionMapping__mdt> medicalAppointmentRegionMapping
			)
	{
		String caseNumber = dtoRequestCase.caseDetail.caseNumber;
		SC_CaseExtension__c caseExtension = (SC_CaseExtension__c)caseNumberToCaseExtensionMap.get(caseNumber);
		String regionSuburbKey = CMN_UTIL_String.replace(dtoRequestCase.caseDetail.nurseRegion, ' ', '')
				+ UNDERSCORE + CMN_UTIL_String.replace(dtoRequestCase.caseDetail.nurseSuburbOrTown, ' ', '');
		//Create a case extension record
		if(caseExtension == null)
		{
			caseExtension = new SC_CaseExtension__c();
			caseExtension.RecordTypeId = recordTypeId;
		}
		//Case Detail information
		caseExtension.SC_AlternativeContactTime__c = dtoRequestCase.caseDetail?.alternativeContactTime;
		caseExtension.RSC_CaseNumber__c = caseNumber;
		caseExtension.RSC_MasterContractNumber__c = dtoRequestCase.caseDetail?.contractNumber;
		caseExtension.SC_NurseRegion__c = dtoRequestCase.caseDetail?.nurseRegion;
		caseExtension.SC_NurseSuburbOrTown__c = dtoRequestCase.caseDetail?.nurseSuburbOrTown;
		caseExtension.RSC_PreferredContactTime__c = dtoRequestCase.caseDetail?.preferredContactTime;
		caseExtension.SC_RequestType__c = dtoRequestCase.caseDetail?.requestType;
		caseExtension.SC_Schema__c = dtoRequestCase.caseDetail?.schema;
		caseExtension.SC_SequenceNumber__c = dtoRequestCase.caseDetail?.sequenceNumber;
		caseExtension.SC_SourceType__c = dtoRequestCase.caseDetail?.sourceType;
		caseExtension.SC_Source__c = dtoRequestCase.caseDetail?.sourceData;
		caseExtension.SC_UACFID__c = dtoRequestCase.caseDetail?.uacfId;
		caseExtension.SC_Username__c = dtoRequestCase.caseDetail?.username;
		caseExtension.SC_WorkType__c = dtoRequestCase.caseDetail?.workType;
		caseExtension.SC_AgentRegion__c = medicalAppointmentRegionMapping?.get(regionSuburbKey)?.RSC_AgentRegion__c;
		//Client Information
		//Client Information
		caseExtension.SC_AlternateTelephoneNumber__c = formatPhoneNumber(dtoRequestCase.client?.alternativeCellularPhoneNumber);
		caseExtension.RSC_ClientAddressLine1__c = dtoRequestCase.client?.addressLine1;
		caseExtension.RSC_ClientAddressLine2__c = dtoRequestCase.client?.addressLine2;
		caseExtension.RSC_ClientAlternateCellNumber__c = formatPhoneNumber(dtoRequestCase.client?.alternativeCellularPhoneNumber);
		caseExtension.RSC_ClientCellNumber__c = formatPhoneNumber(dtoRequestCase.client?.cellularPhoneNumber);
		caseExtension.RSC_ClientFirstName__c = dtoRequestCase.client?.fullName;
		caseExtension.RSC_ClientIdentificationNumber__c = dtoRequestCase.client?.identificationNumber;
		caseExtension.RSC_ClientSuburb__c = dtoRequestCase.client?.suburb;
		caseExtension.RSC_ClientSurname__c = dtoRequestCase.client?.surname;
		caseExtension.RSC_ClientTitle__c = dtoRequestCase.client?.title;
		caseExtension.SC_Gender__c = dtoRequestCase.client?.gender;
		caseExtension.RSC_HomeTelephoneNumber__c = formatPhoneNumber(dtoRequestCase.client?.homeTelephoneNumber);
		caseExtension.RSC_PersonalityDatabaseIdentityNumber__c = dtoRequestCase.client?.pdbId;
		caseExtension.RSC_WorkTelephoneNumber__c = formatPhoneNumber(dtoRequestCase.client?.workTelephoneNumber);

		registerChange(caseExtension);
		return caseExtension;
	}
	/**
	 * @description This method is used to populate contract extension details on the requested cases
	 *
	 * @param caseRecord The case existing case record
	 * @param consultant The consultant record related to the master contract number (policy)
	 * @param caseExtension The case extension record related to a case
	 */
	private void populateAssociatedContractExtension
			(
					Case caseRecord,
					DTO_Consultant consultant,
					SC_CaseExtension__c caseExtension)
	{
		String caseId = caseRecord.Id;
		Id medicalAppointmentRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(
				SC_AssociatedContractExtension__c.SObjectType,
				SC_DAL_CaseExtension.RT_MEDICAL_APPOINTMENT
		);

		if(contractNumbers.isEmpty())
		{
			return;
		}
		//unique identifiers for checking if associated contract extension records exist
		Set<String> extensionUniqueIdentifiers = generateContractUniqueIds(caseId);

		for(String contractNumber : contractNumbers)
		{
			if(String.isNotBlank(contractNumber) && !extensionUniqueIdentifiers.contains(caseId + contractNumber))
			{
				SC_AssociatedContractExtension__c contractExtension = new SC_AssociatedContractExtension__c();
				contractExtension.RSC_PolicyNumber__c = contractNumber;
				contractExtension.RecordTypeId = medicalAppointmentRecordTypeId;
				//if it doesn't match then the fields are not populated
				//Only the record that has the master contract number
				// Will hold the consultant information
				if(CMN_UTIL_String.equals(contractNumber, masterContractNumber))
				{
					contractExtension.SC_ConsultantPriority__c = consultant?.priority;
					contractExtension.RSC_ConsultantCode__c = consultant?.code;
					contractExtension.SC_ConsultantType__c = consultant?.type;
					contractExtension.SC_ConsultantInitials__c = consultant?.initials;
					contractExtension.RSC_AdviserSurname__c = consultant?.surname;
					contractExtension.RSC_AdviserEmail__c = consultant?.emailAddress;
					contractExtension.SC_BrokerConsultantEmail__c = consultant?.copyEmailAddress;
					contractExtension.SC_ConsultantTelephoneNumber__c = formatPhoneNumber(consultant?.telephoneNumber);
					contractExtension.RSC_AdviserCellphoneNumber__c = formatPhoneNumber(consultant?.cellularPhoneNumber);
					contractExtension.SC_CanConsultantBookMed__c = consultant?.canBookMed;
				}

				registerNew(contractExtension);
				registerRelationship(contractExtension, SC_AssociatedContractExtension__c.SC_CaseExtension__c, caseExtension);
				SC_AssociatedContract__c associatedContract = populateAssociatedContractRecord(contractNumber);
				registerNew(associatedContract, SC_AssociatedContract__c.SC_Case__c, caseRecord);
				registerRelationship(associatedContract, SC_AssociatedContract__c.SC_AssociatedContractExtension__c, contractExtension);

			}
		}
	}
	/**
	 * @description This method create Medical Requirement(WorkOrderLineItem) and WorkOrder records
	 *
	 * @param appointmentCase The case record that will be associated to a WorkOrder
	 * @param medicalRequirements The blood test records from the WorkOrderLineItem
	 */
	private void populateWorkOrder(Case appointmentCase, List<DTO_WorkOrderLineItem> medicalRequirements)
	{
		WorkOrder newWorkOrder = new WorkOrder();
		SC_ServiceType__c serviceType = new SC_ServiceType__c();
		WorkOrder existingWorkOrder = SC_DAL_WorkOrder.findByCaseId(appointmentCase.Id);
		if(!String.isBlank(appointmentCase.RSC_ServiceType__c))
		{
			serviceType = SC_DAL_ServiceType.findById(appointmentCase.RSC_ServiceType__c);
		}

		Id workOrderRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(
				WorkOrder.SObjectType,
				serviceType.SC_WorkType__r.SC_WorkOrderRecordType__c
		);
		Id workOrderLineItemRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(
				WorkOrderLineItem.SObjectType,
				serviceType.SC_WorkType__r.SC_WorkOrderLineItemRecordType__c
		);
		if(existingWorkOrder != null)
		{
			newWorkOrder = existingWorkOrder;
		}
		else
		{
			newWorkOrder.WorkTypeId = serviceType.SC_WorkType__c;
			newWorkOrder.RecordTypeId = workOrderRecordTypeId;

			newWorkOrder.Subject = appointmentCase.Subject;
			registerChange(newWorkOrder);
			registerRelationship(newWorkOrder, WorkOrder.CaseId, appointmentCase);
		}
		if(medicalRequirements != null && !medicalRequirements.isEmpty())
		{
			populateWorkOrderLineItem(newWorkOrder, medicalRequirements, workOrderLineItemRecordTypeId);
		}
	}
	/**
	 * @description This method create Medical Requirement(WorkOrderLineItem) and WorkOrder records
	 *
	 * @param newWorkOrder The WorkOrder record that will be associated to a WorkOrderLineItem
	 * @param medicalRequirements The blood test records from the WorkOrderLineItem
	 * @param workOrderLineItemRecordTypeId the recordType of WorkOrderLineItem
	 */
	private void populateWorkOrderLineItem(WorkOrder newWorkOrder, List<DTO_WorkOrderLineItem> medicalRequirements, Id workOrderLineItemRecordTypeId)
	{
		Set<Id> workOrderIds = new Set<Id>();
		workOrderIds.add(newWorkOrder.Id);
		Set<String> lineItemIdentifiers = findExistingMedicalRequirements(workOrderIds);
		for(DTO_WorkOrderLineItem medicalRequirement : medicalRequirements)
		{
			if(!lineItemIdentifiers.contains(medicalRequirement.bloodRequirements.toLowerCase()) && String.isNotBlank(medicalRequirement.bloodRequirements))
			{
				WorkOrderLineItem newWorOrderLineItem = new WorkOrderLineItem();
				newWorOrderLineItem.RecordTypeId = workOrderLineItemRecordTypeId;
				newWorOrderLineItem.SC_MedicalCode__c = medicalRequirement.bloodCode;
				newWorOrderLineItem.SC_MedicalQuestionnaire__c = medicalRequirement.bloodQuestionnaire;
				newWorOrderLineItem.SC_MedicalRequirement__c = medicalRequirement.bloodRequirements;
				registerChange(newWorOrderLineItem);
				registerRelationship(newWorOrderLineItem, WorkOrderLineItem.WorkOrderId, newWorkOrder);
			}
		}
	}

	/**
	 * @description The method is used to generate MedicalRequirement to identify existing LineItem
	 *
	 * @param workOrderIds The LineItem's workOrder Ids
	 *
	 * @return A set of MedicalRequirements
	 */
	public static Set<String> findExistingMedicalRequirements(Set<Id> workOrderIds)
	{
		List<WorkOrderLineItem> workOrderLineItems = SC_DAL_WorkOrderLineItem.findByWorkOrderId(workOrderIds);
		Set<String> lineItemIdentifiers = new Set<String>();

		for(WorkOrderLineItem lineItem : workOrderLineItems)
		{
			lineItemIdentifiers.add(CMN_UTIL_String.lowerCase(lineItem.SC_MedicalRequirement__c));
		}

		return lineItemIdentifiers;

	}

	/**
	 * @description Method formats the phone number by removing remove the braces,
	 * 				unneeded spaces and special characters.
	 *
	 * @param phone phone number to be formatted
	 *
	 * @return String of a formatted phone number
	 */
	private static String formatPhoneNumber(String phone)
	{
		return phone?.replaceAll('[^+0-9]', CMN_UTIL_String.EMPTY);
	}

	/**
	 * @description The DTO representing the request being sent
	 */
	@TestVisible
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public List<DTO_AppointmentCase> cases;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Request.class;
		}

		/**
		 * @description Will deserialize the string and return an instance of the class specified in "getObjectType"
		 *
		 * @param dtoString A JSON string
		 *
		 * @return Deserialized DTO
		 *
		 * @see CMN_DTO_JsonBase.getObjectType
		 */
		public override CMN_DTO_Base deserialize(String dtoString)
		{
			//a single case record per request will be sent from mulesoft
			String transformedRequest = '{ "cases" : ' + dtoString + '}';
			return super.deserialize(transformedRequest);
		}

		/**
		 * @description Suppresses null values when serializing Apex objects
		 *
		 * @return JSON string
		 */
		public override String serialize()
		{
			return JSON.serializePretty(cases, true);
		}
	}

	/**
	 * @description DTO representing a successful response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<DTO_SyncedCase> cases;

		/**
		 * @description Suppresses null values when serializing Apex objects
		 *
		 * @return JSON string
		 */
		public override String serialize()
		{
			return JSON.serializePretty(cases, true);
		}
	}

	/**
	 * @description class representing a synced case
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	private class DTO_SyncedCase
	{
		/**
		 * @description stores the master case number
		 */
		private String caseNumber;
		/**
		 * @description stores the message
		 */
		private final String message = CASE_SYNC_SUCCESSFUL;
	}

	/**
	 * @description class representing a synced case
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	@TestVisible
	private class DTO_Error
	{
		/**
		 * @description stores the pdbId
		 */
		public String pdbId;
		/**
		 * @description stores the error code
		 */
		public String errorCode;
		/**
		 * @description stores error message details
		 */
		public String message;
	}

	/**
	 * @description Class representing the JSON structure of the appointment case sync API
	 */
	@TestVisible
	private class DTO_AppointmentCase
	{
		/**
		 * @description stores the case details
		 */
		public DTO_CaseDetail caseDetail;
		/**
		 * @description stores the client details
		 */
		public DTO_Client client;
		/**
		 * @description stores the consultant details
		 */
		public DTO_Consultant consultant;
		/**
		 * @description stores the List of contracts associated on  the case
		 */
		public List<DTO_Contract> concurrentContractNumbers;
		/**
		 * @description stores the List of WorkOrderLineItem
		 */
		public List<DTO_WorkOrderLineItem> medicalRequirements ;
	}

	/**
	 * @description class representing a case
	 */
	@TestVisible
	private class DTO_CaseDetail
	{
		/**
		 * @description stores the comments on the case
		 */
		public String commentText;
		/**
		 * @description stores the case's sequence number
		 */
		public String sequenceNumber;
		/**
		 * @description stores the type of the requester on  the case (service type code)
		 */
		public String requestType;
		/**
		 * @description stores the username
		 */
		public String username;
		/**
		 * @description stores the schema
		 */
		public String schema;
		/**
		 * @description stores the case work type
		 */
		public String workType;
		/**
		 * @description stores the case's source type
		 */
		public String sourceType;
		/**
		 * @description stores the source data
		 */
		public String sourceData;
		/**
		 * @description stores the client's preferred contact time
		 */
		public String preferredContactTime;
		/**
		 * @description stores the client's alternative contact time
		 */
		public String alternativeContactTime;
		/**
		 * @description stores the nurse's suburb/town
		 */
		public String nurseSuburbOrTown;
		/**
		 * @description stores nurse's region
		 */
		public String nurseRegion;
		/**
		 * @description stores the master contract number
		 */
		public String contractNumber;
		/**
		 * @description stores the master Case Number from pinball
		 */
		public String caseNumber;
		/**
		 * @description stores the uacfId of the Owner on the case
		 */
		public String uacfId;
		/**
		 * @description stores the service type number/code
		 */
		public String serviceType;
	}
	/**
	 * @description Class representing a WorkOrderLineItem
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	@TestVisible
	private class DTO_WorkOrderLineItem
	{
		/**
		 * @description stores the medical requirements
		 */
		public String bloodRequirements;
		/**
		 * @description stores the blood code
		 */
		public String bloodCode;
		/**
		 * @description stores the blood questionnaire
		 */
		public String bloodQuestionnaire;

	}

	/**
	 * @description Class representing a consultant
	 */
	@TestVisible
	private class DTO_Consultant
	{
		/**
		 * @description stores the priority
		 */
		public String priority;
		/**
		 * @description stores the code
		 */
		public String code;
		/**
		 * @description stores the type
		 */
		public String type;
		/**
		 * @description stores the initials
		 */
		public String initials;
		/**
		 * @description stores the surname
		 */
		public String surname;
		/**
		 * @description stores the email address
		 */
		public String emailAddress;
		/**
		 * @description stores the broker consultant's email address
		 */
		public String copyEmailAddress;
		/**
		 * @description stores the telephone number
		 */
		public String telephoneNumber;
		/**
		 * @description stores the cellphone number
		 */
		public String cellularPhoneNumber;
		/**
		 * @description stores a boolean
		 */
		public String canBookMed;
	}

	/**
	 * @description Class representing a client
	 */
	@TestVisible
	private class DTO_Client
	{
		/**
		 * @description stores the title
		 */
		public String title;
		/**
		 * @description stores the  client's full name
		 */
		public String fullName;
		/**
		 * @description stores the surname
		 */
		public String surname;
		/**
		 * @description stores the identity number
		 */
		public String identificationNumber;
		/**
		 * @description stores the gender
		 */
		public String gender;
		/**
		 * @description stores the suburb
		 */
		public String suburb;
		/**
		 * @description stores the first address line
		 */
		public String addressLine1;
		/**
		 * @description stores the second address line
		 */
		public String addressLine2;
		/**
		 * @description stores the pdbId
		 */
		public String pdbId;
		/**
		 * @description stores the cellphone number
		 */
		public String cellularPhoneNumber;
		/**
		 * @description stores the alternative cellphone number
		 */
		public String alternativeCellularPhoneNumber;
		/**
		 * @description stores the home telephone number
		 */
		public String homeTelephoneNumber;
		/**
		 * @description stores the work telephone number
		 */
		public String workTelephoneNumber;
		/**
		 * @description stores the alternative home telephone number
		 */
		public String alternativeTelephoneNumber;
	}

	/**
	 * @description Class representing concurrent contracts
	 */
	@TestVisible
	private class DTO_Contract
	{

		public String concurrentContract;
	}
}