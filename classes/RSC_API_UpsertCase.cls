/**
 * @description API handler to support upserting of cases coming from Horizon (an internal ticketing system)
 *
 * @see RSC_API_UpsertCase_TEST
 * @see RSC_URL_CaseSync
 *
 * @author jayanth.kumar.s@accenture.com aakriti.a.goyal@accenture.com
 *
 * @date December 2021, July 2023
 *
 * @since ST-145996, ST-348797, ST-493088
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
public inherited sharing class RSC_API_UpsertCase extends CMN_API_RestBaseInbound
{
	private CMN_UTIL_SObjectIndex serviceTypeCodeToServiceTypes;
	private final Map<RSC_DTO_Case, Case> dtoToCaseMap = new Map<RSC_DTO_Case, Case>();
	private final Map<RSC_DTO_Case, Set<String>> dtoToMissingContractsMap = new Map<RSC_DTO_Case, Set<String>>();
	private final Set<Id> accountsToRefresh = new Set<Id>();
	private final Set<Id> upsertedCaseIds = new Set<Id>();
	private final Set<Object> workflowCaseNumbers = new Set<Object>();
	private final Set<String> documentTypes = new Set<String>();
	private static Id assignableCaseQueueId;
	private static Id nonAssignableCaseQueueId;
	private static final String CLASS_METHOD_GENERATE_CHECKLIST = 'RSC_API_UpsertCase/generateChecklistItem';
	@TestVisible
	private static final String CLASS_METHOD_POPULATE_CONTRACT = 'RSC_API_UpsertCase/populateContractDetails';
	@TestVisible
	private static final String ERROR_NO_CASE_FOUND = 'Unable to process request as case was not found to be processed.';
	private static final String NO_SERVICE_TYPE_FOUND = 'Case created/updated without a service type as the code "{0}" was not found';
	private static final String SUCCESS_CASE_SYNC = 'Case Synced successfully';

	/**
	 * @description stores the name of the service which can be referenced in test class
	 */
	public static final String SERVICE_NAME = RSC_API_UpsertCase.class.getName();

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
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType>
		{
				Case.SObjectType,
				SC_AssociatedContract__c.SObjectType,
				CaseComment.SObjectType,
				CMN_CaseComment__c.SObjectType
		});
	}
	/**
	 * @description Will check that the information received is valid and query any related data
	 */
	protected override void processRequest()
	{
		super.processRequest();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		if(dtoRequest.cases != null && !dtoRequest.cases.isEmpty())
		{
			Set<Integer> serviceTypeCodes = new Set<Integer>();

			for(RSC_DTO_Case dtoCase : dtoRequest.cases)
			{
				serviceTypeCodes.add(Integer.valueOf(dtoCase.serviceTypeCode));
			}

			serviceTypeCodeToServiceTypes = createServiceCodeToServiceTypeMap(serviceTypeCodes);
			assignableCaseQueueId = SC_DAL_Group.getAssignableCasesQueue()?.Id;
			nonAssignableCaseQueueId = SC_DAL_Group.getNonAssignableCasesQueue()?.Id;
		}
		else
		{
			throw new SearchException(ERROR_NO_CASE_FOUND);
		}
	}

	/**
	 * @description Will ensure that the change to case is registered to be committed after
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		processCaseRequests(dtoRequest.cases);
	}

	/**
	 * @description process the case requests & populate case data
	 *
	 * @param dtoCases The list of all cases received with the request
	 */
	private void processCaseRequests(List<RSC_DTO_Case> dtoCases)
	{
		Set<String> commentUacfIds = new Set<String>();
		Set<String> consultantCodes = new Set<String>();
		Set<String> contractNumbers = new Set<String>();
		Set<String> identityNumbers = new Set<String>();
		Set<String> targetCommentId = new Set<String>();
		Set<String> uacfIds = new Set<String>();

		for(RSC_DTO_Case dtoCase : dtoCases)
		{
			if(dtoCase.sourceCaseNumber != null)
			{
				workflowCaseNumbers.add(Integer.valueOf(dtoCase.sourceCaseNumber));
			}

			consultantCodes.add(dtoCase.consultantCode);
			identityNumbers.add(dtoCase.identificationNumber);
			uacfIds.add(dtoCase.assignedTo);

			if(dtoCase.contractNumbers != null)
			{
				for(RSC_DTO_Case.DTO_Contract dtoContract : dtoCase.contractNumbers)
				{
					contractNumbers.add(dtoContract.contractNumber);
				}
			}

			if(dtoCase.documents != null)
			{
				//Since we already looping through cases, collect document types
				for(RSC_DTO_Case.DTO_Document document : dtoCase.documents)
				{
					documentTypes.add(SC_DAL_DocumentChecklistItem.DOCUMENT_CODE + document.typeCode);
				}
			}

			if(dtoCase.caseComments != null)
			{
				for(RSC_DTO_Case.DTO_CaseComment dtoComment : dtoCase.caseComments)
				{
					targetCommentId.add(dtoComment.sourceCommentId);
					commentUacfIds.add(dtoComment.userName);
				}
			}
		}
		CMN_UTIL_SObjectIndex commentUacfIdToUserMap = createUacfIdToUserMap(commentUacfIds);
		CMN_UTIL_SObjectIndex consultantCodeToConsultants = createConsultantCodeToConsultantsMap(consultantCodes);
		CMN_UTIL_SObjectIndex targetCommentIdToCaseComments = createTargetCommentIdToCommentsMap(targetCommentId);
		CMN_UTIL_SObjectIndex uacfIdToUserMap = createUacfIdToUserMap(uacfIds);
		CMN_UTIL_SObjectIndex workflowCaseNumberToExistingCase = createCaseNumberExistingCaseMap(workflowCaseNumbers);
		Map<String, Account> identityNumberToAccountMap = SC_DAL_Account.getMasterAccountMapByIdNumber(identityNumbers);
		Map<String, SObject> contractNumberToPolicy = SC_UTIL_Contracts.findAllContractsByNumber(contractNumbers);

		populateCaseDetails
				(
						dtoCases,
						workflowCaseNumberToExistingCase,
						uacfIdToUserMap,
						consultantCodeToConsultants,
						identityNumberToAccountMap,
						contractNumberToPolicy,
						targetCommentIdToCaseComments,
						commentUacfIdToUserMap
				);
	}

	/**
	 * @description This method is used to get Map of Workflow Case Number and Existing Case record among the request DTO
	 *
	 * @param workflowCaseNumbers The set of all workflow case numbers received with the request DTO
	 *
	 * @return Map of the Case Number to the Case record
	 */
	public static CMN_UTIL_SObjectIndex createCaseNumberExistingCaseMap(Set<Object> workflowCaseNumbers)
	{
		List<Case> existingCases = SC_DAL_Case.findByWorkflowCaseNumber(workflowCaseNumbers);

		CMN_UTIL_SObjectIndex workflowCaseNumberToExistingCase = new CMN_UTIL_SObjectIndex(SC_DAL_Case.FIELD_WORKFLOW_CASE_NUMBER).putAll(existingCases);

		return workflowCaseNumberToExistingCase;
	}

	/**
	 * @description This method is used to get Map of UACF ID and Existing User record among the request DTO
	 *
	 * @param uacfIds The set of all UACF Ids received with the request DTO
	 *
	 * @return Map of the UACF Id to the User record
	 */
	private static CMN_UTIL_SObjectIndex createUacfIdToUserMap(Set<String> uacfIds)
	{
		List<User> existingUsers = AW_DAL_User.findByUACFIds(uacfIds);

		CMN_UTIL_SObjectIndex uacfIdToUserMap = new CMN_UTIL_SObjectIndex(AW_DAL_User.FIELD_UACF_ID).putAll(existingUsers);

		return uacfIdToUserMap;
	}

	/**
	 * @description This method is used to get Map of Consultant code and Existing Contact record among the request DTO
	 *
	 * @param consultantCodes The set of all consultant codes received with the request DTO
	 *
	 * @return Map of the Consultant codes to the Contact record
	 */
	private static CMN_UTIL_SObjectIndex createConsultantCodeToConsultantsMap(Set<String> consultantCodes)
	{
		List<SC_ConsultantCodes__c> existingConsultants = SC_DAL_ConsultantCodes.findByConsultantCode(consultantCodes);

		CMN_UTIL_SObjectIndex consultantCodeToConsultantsMap = new CMN_UTIL_SObjectIndex(CMN_DAL_SObjectDomain.FIELD_NAME).putAll(existingConsultants);

		return consultantCodeToConsultantsMap;
	}

	/**
	 * @description This method is used to get Map of TargetCommentId to Existing Case Comment record among the request DTO
	 *
	 * @param targetCommentIds The set of all case comments received with the request DTO
	 *
	 * @return Map of the TargetCommentId to the Case Comment record
	 */
	private static CMN_UTIL_SObjectIndex createTargetCommentIdToCommentsMap(Set<String> targetCommentIds)
	{
		List<CMN_CaseComment__c> existingCaseComments = CMN_DAL_CaseComments.findByExternalCommentId(targetCommentIds);

		CMN_UTIL_SObjectIndex targetCommentIdToCommentsMap = new CMN_UTIL_SObjectIndex(CMN_DAL_CaseComments.FIELD_EXTERNAL_COMMENT_ID).putAll(existingCaseComments);

		return targetCommentIdToCommentsMap;
	}

	/**
	 * @description populate case details
	 *
	 * @param dtoCases The list of all cases received with the request
	 * @param workflowCaseNumberToExistingCase Map of the Case Number to the Case record
	 * @param uacfIdToUserMap Map of the UACF Id to the User record
	 * @param consultantCodeToConsultants Map of the Consultant codes to the Consultants record
	 * @param identityNumberToAccountMap Map of the Identification number to the Account record
	 * @param contractNumberToPolicy Map of the Contract Number to the Existing Financial Account or Insurance Policy record
	 * @param targetCommentIdToCaseComments Map of the Target Comment Id to the Existing Case Comments record
	 * @param commentUacfIdToUserMap Map of the Target Comment UserName to found User Record
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private void populateCaseDetails
			(
					List<RSC_DTO_Case> dtoCases,
					CMN_UTIL_SObjectIndex workflowCaseNumberToExistingCase,
					CMN_UTIL_SObjectIndex uacfIdToUserMap,
					CMN_UTIL_SObjectIndex consultantCodeToConsultants,
					Map<String, Account> identityNumberToAccountMap,
					Map<String, SObject> contractNumberToPolicy,
					CMN_UTIL_SObjectIndex targetCommentIdToCaseComments,
					CMN_UTIL_SObjectIndex commentUacfIdToUserMap
			)
	{
		Id retailRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Case.SObjectType, SC_DAL_Case.RT_RETAIL);

		for(RSC_DTO_Case dtoCase : dtoCases)
		{
			Case upsertCase = (Case)workflowCaseNumberToExistingCase.get(dtoCase.sourceCaseNumber);

			if(upsertCase == null)
			{
				upsertCase = new Case();
				upsertCase.RecordTypeId = retailRecordTypeId;
			}

			SC_ServiceType__c foundServiceType = ((SC_ServiceType__c)serviceTypeCodeToServiceTypes.get(dtoCase.serviceTypeCode));
			Boolean isCaseAssignable = foundServiceType?.SC_Assignable__c == true;

			if(foundServiceType == null)
			{
				CaseComment newComment = new CaseComment();
				newComment.CommentBody = String.format(NO_SERVICE_TYPE_FOUND, new List<String> {String.valueOf(dtoCase.serviceTypeCode)});

				registerChange(newComment);
				registerRelationship(newComment, CaseComment.ParentId, upsertCase);
			}

			Account foundAccount = identityNumberToAccountMap.get(dtoCase.identificationNumber);

			if(isCaseAssignable && foundAccount != null)
			{
				//Ensure that we refresh the account's portfolio with latest policies and values
				accountsToRefresh.add(foundAccount.Id);
			}

			upsertCase.AccountId = (identityNumberToAccountMap.get(dtoCase.identificationNumber))?.Id;
			upsertCase.Origin = CMN_UTIL_System.getPicklistValue(Case.SObjectType, SC_DAL_Case.FIELD_ORIGIN, dtoCase.sourceChannel);
			if(String.isNotBlank(dtoCase.priority))
			{
				upsertCase.Priority = dtoCase.priority == SC_DAL_Case.PRIORITY_NORMAL ? SC_DAL_Case.PRIORITY_MEDIUM : dtoCase.priority;
			}

			upsertCase.RSC_Department__c = dtoCase.departmentName;
			upsertCase.RSC_ServiceType__c = foundServiceType?.Id;
			upsertCase.RSC_Team__c = dtoCase.team;
			upsertCase.RSC_WorkflowCaseNumber__c = dtoCase.sourceCaseNumber != null ? Integer.valueOf(dtoCase.sourceCaseNumber) : upsertCase.RSC_WorkflowCaseNumber__c;
			upsertCase.SC_AssignedTo__c = ((User)uacfIdToUserMap.get(dtoCase.assignedTo))?.Id;
			upsertCase.SC_ConsultantCode__c = ((SC_ConsultantCodes__c)consultantCodeToConsultants.get(dtoCase.consultantCode))?.Id;
			upsertCase.SC_RequesterEmail__c = dtoCase.emailAddress;
			upsertCase.SC_RequesterType__c = CMN_UTIL_System.getPicklistValue(Case.SObjectType, SC_DAL_Case.FIELD_REQUESTER_TYPE, dtoCase.requestorType);
			upsertCase.SC_SourceSystem__c = CMN_UTIL_System.getPicklistValue(Case.SObjectType, SC_DAL_Case.FIELD_SOURCE_SYSTEM, dtoCase.sourceSystem);
			upsertCase.Subject = dtoCase.caseTitle;

			setCaseOwner(dtoCase, upsertCase, isCaseAssignable);

			setCaseStatus(dtoCase, upsertCase);

			registerChange(upsertCase);
			dtoToCaseMap.put(dtoCase, upsertCase);

			populateContractDetails(dtoCase, upsertCase, contractNumberToPolicy);
			populateCaseCommentsDetails(dtoCase, upsertCase, targetCommentIdToCaseComments, commentUacfIdToUserMap);
		}
	}

	/**
	 * @description Will set the case Owner either to respective queue or the existing owner
	 *
	 * @param dtoCase The case details provided by external system
	 * @param upsertCase The case to be upserted
	 * @param isCaseAssignable flag to identify if the case is serviceable or not
	 */
	private static void setCaseOwner(RSC_DTO_Case dtoCase, Case upsertCase, Boolean isCaseAssignable)
	{
		if(String.isNotBlank(upsertCase.Id))
		{
			if(upsertCase.RSC_ServiceType__r.SC_ServiceType__c != dtoCase.serviceTypeCode)
			{
				if(isCaseAssignable)
				{
					upsertCase.OwnerId = (upsertCase.OwnerId == assignableCaseQueueId || upsertCase.OwnerId == nonAssignableCaseQueueId) ?
							assignableCaseQueueId : upsertCase.OwnerId;
				}
				else
				{
					upsertCase.OwnerId = nonAssignableCaseQueueId;
				}
			}
		}
		else
		{
			upsertCase.OwnerId = isCaseAssignable ? assignableCaseQueueId : nonAssignableCaseQueueId;
		}
	}

	/**
	 * @description Will set the case status using complex logic
	 *
	 * @param dtoCase The case details provided by external system
	 * @param upsertCase The case to be upserted
	 */
	private static void setCaseStatus(RSC_DTO_Case dtoCase, Case upsertCase)
	{
		if(String.isNotBlank(upsertCase.Id))
		{
			if(dtoCase.statusCode == SC_DAL_Case.WORKFLOW_STATUS_CLOSED && (dtoCase.subStatusCode == null || dtoCase.subStatusCode == CMN_UTIL_String.EMPTY))
			{
				upsertCase.Status = SC_DAL_Case.STATUS_RESOLVED;
			}
			else if(dtoCase.statusCode == SC_DAL_Case.WORKFLOW_STATUS_PEND && dtoCase.subStatusCode == SC_DAL_Case.WORKFLOW_STATUS_PEND)
			{
				upsertCase.Status = SC_DAL_Case.STATUS_IN_PROGRESS;
				upsertCase.SC_SubStatus__c = SC_DAL_Case.SUB_STATUS_ON_HOLD;
			}
			else if(dtoCase.statusCode == SC_DAL_Case.SUB_STATUS_TERMINATED && dtoCase.subStatusCode == SC_DAL_Case.SUB_STATUS_TERMINATED)
			{
				upsertCase.Status = SC_DAL_Case.STATUS_CLOSED;
				upsertCase.SC_SubStatus__c = SC_DAL_Case.SUB_STATUS_TERMINATED;
			}
			else if(dtoCase.statusCode == SC_DAL_Case.WORKFLOW_STATUS_WIP)
			{
				upsertCase.Status = SC_DAL_Case.STATUS_IN_PROGRESS;
			}
		}
		else
		{
			if(dtoCase.statusCode == SC_DAL_Case.WORKFLOW_STATUS_WIP && dtoCase.assignedTo != null && dtoCase.assignedTo != CMN_UTIL_String.EMPTY)
			{
				upsertCase.Status = SC_DAL_Case.STATUS_IN_PROGRESS;
			}
			else
			{
				upsertCase.Status = SC_DAL_Case.STATUS_NEW;
			}
		}
	}

	/**
	 * @description This method is used to populate case comments details on the requested cases
	 *
	 * @param dtoCase The case received with the request
	 * @param foundCase The case existing case record for the provided workflow case number
	 * @param targetCommentIdToCaseComments Map of the Target Comment Id to the Existing Case Comments record
	 * @param commentUacfIdToUserMap Map of the Comment User Name to found USer record
	 */
	private void populateCaseCommentsDetails(RSC_DTO_Case dtoCase, Case foundCase,
			CMN_UTIL_SObjectIndex targetCommentIdToCaseComments, CMN_UTIL_SObjectIndex commentUacfIdToUserMap)
	{
		if(dtoCase.caseComments != null)
		{
			for(RSC_DTO_Case.DTO_CaseComment dtoComment : dtoCase.caseComments)
			{
				//Horizon sourceCommentId is external commentId for us, hence getting the records from the map based on sourceCommentId
				CMN_CaseComment__c foundComment = (CMN_CaseComment__c)targetCommentIdToCaseComments.get(dtoComment.sourceCommentId);
				CMN_CaseComment__c commentToUpsert = foundComment != null ? foundComment : new CMN_CaseComment__c();

				commentToUpsert.CMN_Comment__c = dtoComment.commentHtml;
				commentToUpsert.CMN_ExternalCommentCreatedDate__c = dtoComment.commentDate;
				commentToUpsert.CMN_ExternalCommentId__c = dtoComment.sourceCommentId;
				commentToUpsert.CMN_IsExternalComment__c = true;

				User foundUser = (User)commentUacfIdToUserMap.get(dtoComment.userName);
				if(foundUser != null)
				{
					commentToUpsert.CMN_CommentCreatedBy__c = commentToUpsert.CMN_CommentCreatedByInformation__c = foundUser.Id;
				}
				else
				{
					commentToUpsert.CMN_CommentCreatedByInformation__c = dtoComment.userName;
				}

				//if the comment is new Comment then lookup with Case
				if(String.isBlank(commentToUpsert.Id))
				{
					registerNew(commentToUpsert, CMN_CaseComment__c.CMN_Case__c, foundCase);
				}
				else
				{
					registerChange(commentToUpsert);
				}
			}
		}
	}

	/**
	 * @description This method is used to populate contract details on the requested cases
	 *
	 * @param dtoCase The case received with the request
	 * @param foundCase The case existing case record for the provided workflow case number
	 * @param contractNumberToPolicy Map of the Contract Number to the Existing Financial Account or Insurance Policy record
	 */
	@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
	private void populateContractDetails(RSC_DTO_Case dtoCase, Case foundCase, Map<String, SObject> contractNumberToPolicy)
	{
		Set<String> newContractNumbers = new Set<String>();
		String existingCaseId = foundCase.Id;

		// Create new contracts for the service request
		if(dtoCase.contractNumbers != null)
		{
			// Check existing contracts for a case
			Set<String> caseIdToContractNumber = new Set<String>();

			if(foundCase.Id != null)
			{
				for(SC_AssociatedContract__c contract : foundCase.Associated_Contracts__r)
				{
					if(contract.SC_FinancialAccount__c != null)
					{
						caseIdToContractNumber.add(existingCaseId + contract.SC_FinancialAccount__c);
					}
					else if(contract.SC_InsurancePolicy__c != null)
					{
						caseIdToContractNumber.add(existingCaseId + contract.SC_InsurancePolicy__c);
					}
				}
			}

			Set<String> missingContractNumbers = new Set<String>();

			for(RSC_DTO_Case.DTO_Contract dtoContract : dtoCase.contractNumbers)
			{
				Boolean policyFound = false;

				if(!contractNumberToPolicy.isEmpty())
				{
					SObject policy = contractNumberToPolicy.get(dtoContract.contractNumber);

					policyFound = policy != null;

					if(policyFound)
					{
						SC_AssociatedContract__c newAssociatedContract = new SC_AssociatedContract__c();
						if(policy.getSObjectType() == FinServ__FinancialAccount__c.SObjectType &&
								!caseIdToContractNumber.contains(existingCaseId + ((FinServ__FinancialAccount__c)policy)?.Id))
						{
							newAssociatedContract.SC_FinancialAccount__c = ((FinServ__FinancialAccount__c)policy)?.Id;
							registerNew(newAssociatedContract, SC_AssociatedContract__c.SC_Case__c, foundCase);
						}
						else if(policy.getSObjectType() == InsurancePolicy.SObjectType && !caseIdToContractNumber.contains(existingCaseId + ((InsurancePolicy)policy)?.Id))
						{
							newAssociatedContract.SC_InsurancePolicy__c = ((InsurancePolicy)policy)?.Id;
							registerNew(newAssociatedContract, SC_AssociatedContract__c.SC_Case__c, foundCase);
						}
					}
				}

				if(!policyFound)
				{
					CMN_UTIL_Logger.warn('Contract Number: "' + dtoContract.contractNumber + '" not found', CLASS_METHOD_POPULATE_CONTRACT);
					missingContractNumbers.add(dtoContract.contractNumber);
				}

				newContractNumbers.add(dtoContract.contractNumber);
			}

			if(!missingContractNumbers.isEmpty())
			{
				dtoToMissingContractsMap.put(dtoCase, missingContractNumbers);
			}
		}

		// Handle deleted contracts for the service requests
		for(SC_AssociatedContract__c contract : foundCase.Associated_Contracts__r)
		{
			if(!newContractNumbers.contains(contract.SC_FinancialAccount__r.FinServ__FinancialAccountNumber__c) &&
					!newContractNumbers.contains(contract.SC_InsurancePolicy__r.Name)
			)
			{
				registerDeleted(contract);
			}
		}
	}

	/**
	 * @description Actions to be performed (like updating response dto)
	 */
	public override void onCommitWorkFinishing()
	{
		upsertedCaseIds.addAll(CMN_UTIL_System.extractListIds(dtoToCaseMap.values()));
		processCaseDocuments();

		super.onCommitWorkFinishing();

		upsertMissingContractsCache();

		insertAccountRefreshItems();
	}

	/**
	 * @description Will insert or update the Missing Contracts Cache to be consumed when portfolio refresh operation returns the missing contracts
	 */
	private void upsertMissingContractsCache()
	{
		if(!dtoToMissingContractsMap.isEmpty())
		{
			SC_UTIL_Contracts.MissingContractsCacheHandler cacheHandler = new SC_UTIL_Contracts.MissingContractsCacheHandler();

			//Retrieve all caches for the accounts that we intend to refresh, so we don't over right a cache entry for same account on a different case
			cacheHandler.retrieveFromCache(accountsToRefresh);

			//Make sure we store the missing contracts to platform cache, so when the portfolio refresh operation can use this to link the policies to the case
			for(RSC_DTO_Case dtoCase : dtoToMissingContractsMap.keySet())
			{
				Case foundCase = dtoToCaseMap.get(dtoCase);

				if(foundCase != null)
				{
					cacheHandler.addMissingContracts(foundCase.AccountId, foundCase.Id, dtoToMissingContractsMap.get(dtoCase));
				}
			}

			cacheHandler.persistToCache();
		}
	}

	/**
	 * @description Will initialise and insert queue items that will trigger portfolio refresh API call outs
	 */
	private void insertAccountRefreshItems()
	{
		if(!accountsToRefresh.isEmpty())
		{
			List<CMN_WebserviceCallQueue__c> newQueueItems = new List<CMN_WebserviceCallQueue__c>();

			for(Id accountId : accountsToRefresh)
			{
				newQueueItems.add(CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RefreshContracts.SERVICE_NAME, accountId));
			}

      CMN_DAL_SObjectDomain.insertDBObjects(newQueueItems, false);
		}
	}

	/**
	 * @description Will process any documents that are associated to the cases synchronised
	 */
	private void processCaseDocuments()
	{
		CMN_UTIL_SObjectIndex checkListItemMap = createCaseAndIdentifierToCheckListItemMap(upsertedCaseIds);
		CMN_UTIL_SObjectIndex developerNameToDocumentType = createDeveloperNameToDocumentTypeMap(documentTypes);
		Id checkListItemRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(DocumentChecklistItem.SObjectType, SC_DAL_DocumentChecklistItem.RT_CASE_DOCUMENT);
		Map<String, DocumentChecklistItem> mapOfItemsToUpsert = new Map<String, DocumentChecklistItem>();

		Set<Id> updatedCheckListItems = new Set<Id>();

		for(RSC_DTO_Case dtoCase : dtoToCaseMap.keySet())
		{
			if(dtoCase.documents != null)
			{
				Case upsertedCase = dtoToCaseMap.get(dtoCase);

				for(RSC_DTO_Case.DTO_Document dtoDocument : dtoCase.documents)
				{
					DocumentChecklistItem upsertItem =
							generateChecklistItem(checkListItemRecordTypeId, developerNameToDocumentType, checkListItemMap, dtoDocument, upsertedCase, mapOfItemsToUpsert);

					if(String.isNotBlank(upsertItem.Id))
					{
						updatedCheckListItems.add(upsertItem.Id);
						mapOfItemsToUpsert.put(upsertItem.Id, upsertItem);
					}
					else
					{
						mapOfItemsToUpsert.put(upsertItem.CMN_VaultedId__c, upsertItem);
					}
				}
			}
		}

		List<SObject> itemsToDelete = new List<SObject>();

		for(SObject existingItem : checkListItemMap.values())
		{
			//Only delete items that aren't part of the case anymore and where originally synchronised as part of the case
			if(!updatedCheckListItems.contains(existingItem.Id) && ((DocumentChecklistItem)existingItem).SC_UploadedWithCase__c == true)
			{
				itemsToDelete.add(existingItem);
			}
		}

		CMN_DAL_SObjectDomain.upsertDBObjects(mapOfItemsToUpsert.values());
		CMN_DAL_SObjectDomain.deleteDBObjects(itemsToDelete);
	}

	/**
	 * @description Process documents associated to case as well as update response with upserted case numbers
	 */
	protected override void updateResponseDTO()
	{
		super.updateResponseDTO();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
		dtoResponse.cases = new List<DTO_Case>();

		//Get latest case details
		List<Case> upsertedCases = SC_DAL_Case.findById(upsertedCaseIds);
		List<CMN_CaseComment__c> foundCaseComments = CMN_DAL_CaseComments.findByCaseId(upsertedCaseIds);

		List<String> searchFields = new List<String>
		{
				CMN_DAL_CaseComments.FIELD_CASE,
				CMN_DAL_CaseComments.FIELD_EXTERNAL_COMMENT_ID
		};

		CMN_UTIL_SObjectIndex commentsMap = new CMN_UTIL_SObjectIndex(searchFields).putAll(foundCaseComments);

		for(Case upsertedCase : upsertedCases)
		{
			Map<String, Object> searchFieldsMap = new Map<String, Object>
			{
					CMN_DAL_CaseComments.FIELD_CASE => upsertedCase.Id
			};

			//get all the comments for the given caseID later this can be filtered based on the source commentId
			List<SObject> foundCommentsOnCase = commentsMap.getAll(searchFieldsMap);

			DTO_Case dtoCase = new DTO_Case();

			dtoCase.sourceCaseNumber = upsertedCase.RSC_WorkflowCaseNumber__c == null ? null : String.valueOf(upsertedCase.RSC_WorkflowCaseNumber__c);
			dtoCase.targetCaseNumber = upsertedCase.CaseNumber;

			if(!foundCommentsOnCase.isEmpty() && foundCommentsOnCase != null)
			{
				List<RSC_DTO_Case.DTO_CaseComment> commentsResponseList = new List<RSC_DTO_Case.DTO_CaseComment>();

				for(CMN_CaseComment__c foundComment : (List<CMN_CaseComment__c>)foundCommentsOnCase)
				{
					searchFieldsMap.put(CMN_DAL_CaseComments.FIELD_EXTERNAL_COMMENT_ID, foundComment.CMN_ExternalCommentId__c);

					List<CMN_CaseComment__c> commentToResponse = (List<CMN_CaseComment__c>)commentsMap.getAll(searchFieldsMap);

					if(commentToResponse != null)
					{
						CMN_CaseComment__c commentToProcess = commentToResponse.iterator().next();

						RSC_DTO_Case.DTO_CaseComment commentResponse = new RSC_DTO_Case.DTO_CaseComment();

						commentResponse.sourceCommentId = commentToProcess.CMN_ExternalCommentId__c;
						commentResponse.targetCommentId = commentToProcess.Id;

						commentsResponseList.add(commentResponse);
					}
				}

				if(!commentsResponseList.isEmpty() && commentsResponseList != null)
				{
					dtoCase.caseComments = commentsResponseList;
				}
			}
			dtoResponse.cases.add(dtoCase);
		}
	}

	/**
	 * @description Will construct the Document Checklist Item to either insert or update
	 *
	 * @param checkListItemRecordTypeId The record type id to use the checklist item
	 * @param developerNameToDocumentType An index of Document Types, will be used to set document type on item
	 * @param checkListItemMap An index of existing checklist items, used to match inbound documents
	 * @param dtoDocument Inbound document associated to case
	 * @param upsertedCase The case that is linked to inbound document
	 * @param mapOfItemsToUpsert list of items that are already in the list to upsert
	 *
	 * @return A populated checklist item
	 */
	@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts,PMD.ExcessiveParameterList')
	private static DocumentChecklistItem generateChecklistItem
			(
					Id checkListItemRecordTypeId,
					CMN_UTIL_SObjectIndex developerNameToDocumentType,
					CMN_UTIL_SObjectIndex checkListItemMap,
					RSC_DTO_Case.DTO_Document dtoDocument,
					Case upsertedCase,
					Map<String, DocumentChecklistItem> mapOfItemsToUpsert
			)
	{

		String documentTypeName = SC_DAL_DocumentChecklistItem.DOCUMENT_CODE + dtoDocument.typeCode;

		DocumentType foundDocumentType = (DocumentType)developerNameToDocumentType.get(documentTypeName);

		//We do not expect the condition below to happen in test or production environments, but in the event it does, we can detect the problem
		if(foundDocumentType == null)
		{
			CMN_UTIL_Logger.debug('Document Type: "' + documentTypeName + '" not found', CLASS_METHOD_GENERATE_CHECKLIST);
		}

		Map<String, Object> searchFieldsMap = new Map<String, Object>
		{
				SC_DAL_DocumentChecklistItem.FIELD_PARENT_ID => upsertedCase.Id,
				SC_DAL_DocumentChecklistItem.FIELD_VAULT_ID => dtoDocument.id
		};

		//Search on Case Id and Vault Id
		List<SObject> foundCheckListItems = checkListItemMap.getAll(searchFieldsMap);

		if(foundCheckListItems.isEmpty() && foundDocumentType != null)
		{
			//Search on Case Id and Document Type Id
			searchFieldsMap.remove(SC_DAL_DocumentChecklistItem.FIELD_VAULT_ID);
			searchFieldsMap.put(SC_DAL_DocumentChecklistItem.FIELD_DOCUMENT_TYPE_ID, foundDocumentType.Id);
			List<SObject> foundCheckListItemsWithSameType = checkListItemMap.getAll(searchFieldsMap);
			// Adding this chk to allow addition of multiple documents of same type with different vaultedId
			if(!foundCheckListItemsWithSameType.isEmpty())
			{
				// add thing chk to make sure that the list doesnt has same element multiple times to upsert,
				// earlier same item was getting added to list multiple times bcz of which the sync was failing
				if(!mapOfItemsToUpsert.isEmpty())
				{
					DocumentChecklistItem itemToProcess = getItemToProcess(foundCheckListItemsWithSameType, mapOfItemsToUpsert);
					if(itemToProcess != null)
					{
						foundCheckListItems = new List<SObject>();
						foundCheckListItems.add(itemToProcess);
					}
				}
				else
				{
					foundCheckListItems = foundCheckListItemsWithSameType;
				}
			}
		}

		DocumentChecklistItem foundItem = getItemToProcess(foundCheckListItems, mapOfItemsToUpsert);
		DocumentChecklistItem upsertItem = foundCheckListItems.isEmpty() || foundItem == null ? new DocumentChecklistItem() : foundItem ;

		upsertItem.AW_DateVaulted__c = dtoDocument.storedDate;
		upsertItem.AW_Vaulted__c = String.isNotBlank(dtoDocument.id);
		upsertItem.CMN_VaultedId__c = dtoDocument.id;
		upsertItem.DocumentTypeId = foundDocumentType?.Id;
		upsertItem.Name = dtoDocument.typeText;
		upsertItem.ParentRecordId = upsertedCase.Id;
		upsertItem.RecordTypeId = checkListItemRecordTypeId;
		upsertItem.SC_UploadedWithCase__c = true;

		return upsertItem;
	}

	/**
	 * @description method to get the unique item that doest exist in map
	 *
	 * @param foundCheckListItems non vaulted items with same Document types
	 * @param mapOfItemsToUpsert map of Items to upsert
	 *
	 * @return A populated checklist item
	 */
	public static DocumentChecklistItem getItemToProcess(List<DocumentChecklistItem> foundCheckListItems, Map<String, DocumentChecklistItem> mapOfItemsToUpsert)
	{
		for(DocumentChecklistItem foundItem : foundCheckListItems)
		{
			Boolean hasItem = mapOfItemsToUpsert.containsKey(foundItem.Id);
			if(!hasItem)
			{
				return foundItem;
			}
		}
		return null;
	}

	/**
	 * @description This method is used to get SObjectIndex of Service Type Code and Existing Service Type record among the request DTO
	 *
	 * @param serviceTypeCodes The set of all service type code received with the request DTO
	 *
	 * @return SObjectIndex of the Service Code to the Service Type record
	 */
	private static CMN_UTIL_SObjectIndex createServiceCodeToServiceTypeMap(Set<Integer> serviceTypeCodes)
	{
		List<SC_ServiceType__c> existingServiceTypes = SC_DAL_ServiceType.findByServiceTypeCodes(serviceTypeCodes);

		CMN_UTIL_SObjectIndex serviceTypeCodeToServiceType = new CMN_UTIL_SObjectIndex(SC_DAL_ServiceType.FIELD_SERVICE_TYPE_CODE).putAll(existingServiceTypes);

		return serviceTypeCodeToServiceType;
	}

	/**
	 * @description This method is used to get Map of developer name and Existing Document Type record among the request DTO
	 *
	 * @param documentTypes The set of all document type names received with the request DTO
	 *
	 * @return A newly created sObject index
	 */
	private static CMN_UTIL_SObjectIndex createDeveloperNameToDocumentTypeMap(Set<String> documentTypes)
	{
		List<DocumentType> foundDocumentTypes = SC_DAL_DocumentType.findByDeveloperName(documentTypes);
		return new CMN_UTIL_SObjectIndex(SC_DAL_DocumentType.FIELD_DEVELOPER_NAME).putAll(foundDocumentTypes);
	}

	/**
	 * @description Will query all existing checklist items for the given Case Ids and then build up an index across multiple fields
	 *
	 * @param caseIds A list of items to query against
	 *
	 * @return A Sobject index, the index being Case Id and combination of DocumentTypeId or VaultID
	 */
	private static CMN_UTIL_SObjectIndex createCaseAndIdentifierToCheckListItemMap(Set<Id> caseIds)
	{
		List<DocumentChecklistItem> foundChecklistItems = SC_DAL_DocumentChecklistItem.findByParent(caseIds);

		List<String> searchFields = new List<String>
		{
				SC_DAL_DocumentChecklistItem.FIELD_PARENT_ID,
				SC_DAL_DocumentChecklistItem.FIELD_VAULT_ID,
				SC_DAL_DocumentChecklistItem.FIELD_DOCUMENT_TYPE_ID
		};

		return new CMN_UTIL_SObjectIndex(searchFields).putAll(foundChecklistItems);
	}

	/**
	 * @description The DTO representing the request being sent
	 */
	@TestVisible
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public List<RSC_DTO_Case> cases;

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
			String modifiedRequest = '{ "cases" : ' + dtoString + '}';
			return super.deserialize(modifiedRequest);
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
		public List<DTO_Case> cases;

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

	@TestVisible
	private class DTO_Case
	{
		private String sourceCaseNumber;
		private String targetCaseNumber;
		@SuppressWarnings('ApexUnusedDeclaration')
		private final String message = SUCCESS_CASE_SYNC;
		private List<RSC_DTO_Case.DTO_CaseComment> caseComments;
	}
}