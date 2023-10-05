/**
 * @description Service class to make the API call to notify Mulesoft when a Case is created or updated in Salesforce
 *
 * @see RSC_API_SynchroniseCase_TEST @story ST-145998
 *
 * @author jason.van.beukering@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date October 2022, July 2023
 */
public without sharing class RSC_API_SynchroniseCase extends CMN_API_RestBaseOutboundMule
{
	/*
		We are using without sharing as we need the queries to see cases the agent may not necessarily be able to see (due to the owner being changed)
	 */
	private static final String ERROR_ITEM_NOT_FOUND = 'Unable to process request as no Case was found.';
	private static List<CMN_CaseComment__c> foundCaseComments = new List<CMN_CaseComment__c>();
	/**
	 * @description stores the name of the service which can be referenced in test class
	 */
	public static final String SERVICE_NAME = RSC_API_SynchroniseCase.class.getName();

	@TestVisible
	private static String mockCaseNumber;
	@TestVisible
	private static String mockExternalCaseNumber;
	@TestVisible
	private static String mockSourceCommentId;
	@TestVisible
	private static String mockTargetCommentId;
	@TestVisible
	private static String mockTeam;

	/**
	 * @description Override to set request and response DTO types and any other globals which may be used
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
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
	 * @description Check if the JSON Response is in the form of an array without key; Parsing this using a Salesforce DTO
	 * class is not possible so it needs to be manually added to the response
	 *
	 * @return Boolean - An indicator to show if the response is an array and is withing a key node.
	 */
	protected override Boolean hasArrayResponse()
	{
		return true;
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
			DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

			dtoRequest.caseToSend = SC_DAL_Case.findById(queueItem.CMN_TriggeringObjectId__c);

			if(dtoRequest.caseToSend == null)
			{
				mustAbort = true;
				callResult.errors.add(ERROR_ITEM_NOT_FOUND);
			}
		}

		return mustAbort;
	}

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType> {Case.SObjectType, CMN_CaseComment__c.SObjectType});
	}

	/**
	 * @description Inner class to define structure of request body and populate the same for API call
	 */
	public inherited sharing class DTO_Request extends CMN_DTO_JsonBase
	{
		private transient Case caseToSend;
		/**
		 * @description stores the case information to be sent from salesforce to horizon
		 */
		public List<RSC_DTO_Case> dtoCases;

		/**
		 * @description Override to populate request body
		 *
		 * @param triggeringObjectId Case Id for which API call is initiated
		 */
		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);
			dtoCases = new List<RSC_DTO_Case> {createAndPopulateDtoCase()};
		}

		/**
		 * @description Will create an populate the Case DTO
		 *
		 * @return newly populated dto
		 */
		private RSC_DTO_Case createAndPopulateDtoCase()
		{
			RSC_DTO_Case dtoCase = new RSC_DTO_Case();

			//if the AssignedTo checkbox on clone or create case component is not checked then SC_AssignedTo__c will be blank
			Id userId = caseToSend.RSC_ServiceType__r.SC_Assignable__c ? caseToSend.OwnerId : caseToSend.SC_AssignedTo__c;

			//userId may be a queue, in this case do  not run query to find user, as this will return no results
			dtoCase.assignedTo = CMN_UTIL_System.getSObjectTypeById(userId) == User.SObjectType ? SC_DAL_User.findById(userId).AW_UACFID__c : null;
			dtoCase.caseTitle = caseToSend.Subject;
			dtoCase.consultantCode = caseToSend.SC_ConsultantCode__r.Name;
			dtoCase.departmentName = caseToSend.RSC_ServiceType__r.SC_Department__c;
			dtoCase.emailAddress = caseToSend.SC_RequesterEmail__c;
			dtoCase.priority = caseToSend.Priority == SC_DAL_Case.PRIORITY_MEDIUM ? SC_DAL_Case.PRIORITY_NORMAL : caseToSend.Priority;
			dtoCase.requestorType = caseToSend.SC_RequesterType__c;
			dtoCase.sourceCaseNumber = caseToSend.CaseNumber;
			dtoCase.serviceTypeCode = Integer.valueOf(caseToSend.RSC_ServiceType__r.SC_ServiceType__c);

			dtoCase.sourceSystem = SC_DAL_Case.DEFAULT_SOURCE_SYSTEM;

			if(caseToSend.RSC_WorkflowCaseNumber__c != null)
			{
				dtoCase.targetCaseNumber = String.valueOf(caseToSend.RSC_WorkflowCaseNumber__c);
				dtoCase.sourceChannel = caseToSend.Origin;
			}
			else
			{
				dtoCase.sourceChannel = SC_DAL_Case.SOURCE_SYSTEM_CHANNEL;
			}

			populateAccountInformation(dtoCase);
			populateCaseStatus(dtoCase);
			populateComments(dtoCase);
			populateContractNumbers(dtoCase);
			populateDocuments(dtoCase);

			return dtoCase;
		}

		/**
		 * @description Will retrieve case account information and update the DTO
		 *
		 * @param dtoCase Case to populate
		 */
		private void populateAccountInformation(RSC_DTO_Case dtoCase)
		{
			if(String.isNotBlank(caseToSend.AccountId))
			{
				Account foundAccount = AW_DAL_Account.findById(caseToSend.AccountId);
				Boolean isMasterPerson = SC_DAL_Account.RT_PERSON_MASTER_ACCOUNT.equals(foundAccount?.RecordType.DeveloperName) ? true : false;
				String identityNumber = isMasterPerson ? foundAccount?.AW_IdentificationNumber__pc : foundAccount?.AW_CompanyRegistrationTrustNumber__c;
				String identityType = isMasterPerson ? SC_DAL_Case.IDENTITY_TYPE : SC_DAL_Case.COMPANY_TRUST_TYPE;

				dtoCase.identificationNumber = identityNumber;
				dtoCase.identificationType = identityType;
			}
		}

		/**
		 * @description Will set the case status code appropriately
		 *
		 * @param dtoCase Case to populate
		 */
		private void populateCaseStatus(RSC_DTO_Case dtoCase)
		{
			if(caseToSend.Status == SC_DAL_Case.STATUS_NEW)
			{
				dtoCase.statusCode = SC_DAL_Case.WORKFLOW_STATUS_WIP;
			}
			else if(caseToSend.Status == SC_DAL_Case.STATUS_IN_PROGRESS)
			{
				if(SC_DAL_Case.SUB_STATUS_ON_HOLD.equals(caseToSend.SC_SubStatus__c))
				{
					dtoCase.statusCode = dtoCase.subStatusCode = SC_DAL_Case.WORKFLOW_STATUS_PEND;
				}
				else
				{
					dtoCase.statusCode = SC_DAL_Case.WORKFLOW_STATUS_WIP;
				}
			}
			else if(caseToSend.Status == SC_DAL_Case.STATUS_CLOSED || caseToSend.Status == SC_DAL_Case.STATUS_RESOLVED)
			{
				if(SC_DAL_Case.SUB_STATUS_TERMINATED.equals(caseToSend.SC_SubStatus__c))
				{
					dtoCase.statusCode = dtoCase.subStatusCode = SC_DAL_Case.SUB_STATUS_TERMINATED;
				}
				else
				{
					dtoCase.statusCode = SC_DAL_Case.WORKFLOW_STATUS_CLOSED;
				}
			}
		}

		/**
		 * @description Will retrieve and populate the case comments
		 *
		 * @param dtoCase Case to populate
		 */
		private void populateComments(RSC_DTO_Case dtoCase)
		{
			foundCaseComments = CMN_DAL_CaseComments.findByCaseId(caseToSend.Id);
			if(!foundCaseComments.isEmpty())
			{
				dtoCase.caseComments = new List<RSC_DTO_Case.DTO_CaseComment>();

				for(CMN_CaseComment__c newComment : foundCaseComments)
				{
					RSC_DTO_Case.DTO_CaseComment dtoComment = new RSC_DTO_Case.DTO_CaseComment();
					dtoComment.sourceCaseNumber = caseToSend.CaseNumber;
					dtoComment.targetCaseNumber = caseToSend.RSC_WorkflowCaseNumber__c != null ? String.valueOf(caseToSend.RSC_WorkflowCaseNumber__c) : CMN_UTIL_String.EMPTY;
					dtoComment.sourceCommentId = newComment.Id;
					if(newComment.CMN_ExternalCommentId__c != null)
					{
						dtoComment.targetCommentId = newComment.CMN_ExternalCommentId__c;
					}
					dtoComment.commentHtml = newComment.CMN_Comment__c;
					dtoComment.commentDate = newComment.CreatedDate;
					dtoComment.userName = newComment.CreatedBy.AW_UACFID__c;

					dtoCase.caseComments.add(dtoComment);
				}
			}
		}

		/**
		 * @description Will retrieve and populate the case contract numbers
		 *
		 * @param dtoCase Case to populate
		 */
		private void populateContractNumbers(RSC_DTO_Case dtoCase)
		{
			List<SC_AssociatedContract__c> newContracts = SC_DAL_AssociatedContract.findByParent(caseToSend.Id);

			if(!newContracts.isEmpty())
			{
				dtoCase.contractNumbers = new List<RSC_DTO_Case.DTO_Contract>();

				for(SC_AssociatedContract__c contract : newContracts)
				{
					RSC_DTO_Case.DTO_Contract dtoContracts = new RSC_DTO_Case.DTO_Contract();

					if(contract.SC_FinancialAccount__c != null || contract.SC_InsurancePolicy__c != null)
					{
						if(contract.SC_FinancialAccount__c != null)
						{
							dtoContracts.contractNumber = contract.SC_FinancialAccount__r.FinServ__FinancialAccountNumber__c;
						}
						else
						{
							dtoContracts.contractNumber = contract.SC_InsurancePolicy__r.Name;
						}
						dtoCase.contractNumbers.add(dtoContracts);
					}
				}
			}
		}

		/**
		 * @description Will retrieve and populate the case documents
		 *
		 * @param dtoCase Case to populate
		 */
		private void populateDocuments(RSC_DTO_Case dtoCase)
		{
			List<DocumentChecklistItem> checklistItems = SC_DAL_DocumentChecklistItem.findVaultedDocumentByParent(caseToSend.Id);
			if(!checklistItems.isEmpty())
			{
				dtoCase.documents = new List<RSC_DTO_Case.DTO_Document>();

				for(DocumentChecklistItem newItem : checklistItems)
				{
					RSC_DTO_Case.DTO_Document dtoDocuments = new RSC_DTO_Case.DTO_Document();
					dtoDocuments.typeText = newItem.Name;
					dtoDocuments.id = newItem.CMN_VaultedId__c;
					dtoDocuments.typeCode = CMN_UTIL_String.remove(newItem.DocumentType?.DeveloperName, SC_DAL_DocumentChecklistItem.DOCUMENT_CODE);

					dtoCase.documents.add(dtoDocuments);
				}
			}
		}

		/**
		 * @description Suppresses null values when serializing Apex objects
		 *
		 * @return JSON string
		 */
		public override String serialize()
		{
			return JSON.serializePretty(dtoCases, true);
		}
	}

	/**
	 * @description Takes all the work that has been registered with the UnitOfWork and commits it to the database
	 */
	public override void commitWork()
	{
		/* Including this to make sure the sharing is bypassed after making the controller as without sharing*/
		super.commitWork(false);
	}

	/**
	 * @description Will ensure that any changes to be made to Salesforce are registered here
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		//Since we only send one case at a time we expect one response in the array
		DTO_Case dtoCase = dtoResponse.responses.iterator().next();

		dtoRequest.caseToSend.RSC_WorkflowCaseNumber__c = Integer.valueOf(dtoCase.targetCaseNumber);
		dtoRequest.caseToSend.RSC_Team__c = dtoCase.team;

		registerChange(dtoRequest.caseToSend);

		if(dtoCase.caseComments != null)
		{
			CMN_UTIL_SObjectIndex targetCommentIdToCommentsMap = new CMN_UTIL_SObjectIndex(CMN_DAL_CaseComments.FIELD_ID).putAll(foundCaseComments);

			for(RSC_DTO_Case.DTO_CaseComment dtoComment : dtoCase.caseComments)
			{
				//we are sending the recordId of Case comment as the source comment Id to Horizon
				CMN_CaseComment__c foundComment = (CMN_CaseComment__c)targetCommentIdToCommentsMap.get(dtoComment.sourceCommentId);

				if(foundComment != null)
				{
					foundComment.CMN_ExternalCommentId__c = dtoComment.targetCommentId;
					registerChange(foundComment);
				}
			}
		}
	}

	/**
	 * @description Inner class to define structure of response body
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<DTO_Case> responses;

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
	private class DTO_Case
	{
		public String targetCaseNumber;
		public String message;
		@SuppressWarnings('ApexUnusedDeclaration')
		public String sourceCaseNumber;
		public String team;
		public List<RSC_DTO_Case.DTO_CaseComment> caseComments;
	}

	/**
	 * @description Override to return inner class having Mock response
	 *
	 * @return CMN_API_HttpBaseOutboundMock RSC_API_SynchroniseCaseMock is extension class and contains Mock response
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new RSC_API_SynchroniseCaseMock();
	}

	/**
	 * @description Extension for CMN_API_HttpBaseOutboundMock class to specify Mock response for test class
	 */
	private class RSC_API_SynchroniseCaseMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '[{"targetCaseNumber": "' + mockExternalCaseNumber + '", "sourceCaseNumber": "' + mockCaseNumber + '","team": "' +
				mockTeam + '", "caseComments": [{"sourceCommentId": "' + mockSourceCommentId + '", "targetCommentId": "' + mockTargetCommentId + '"}], ' +
				'"message": "Case synced successfully"}]';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}