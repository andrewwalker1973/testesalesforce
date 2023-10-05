/**
 * @description Public class to return the records of Case
 *
 * @see Case
 *
 * @author jason.van.beukering@accenture.com, uttpal.chandra@accenture.com
 *
 * @date 2021, May 2023
 */
public inherited sharing class SC_DAL_Case
{
	private static final String FIELD_ACCOUNT_ALTERNATIVE_EMAIL = 'Account.AW_AlternativeEmail__pc';
	private static final String FIELD_ACCOUNT_ALTERNATIVE_MOBILE = 'Account.CMN_AlternativeMobile__pc';
	private static final String FIELD_ACCOUNT_ALTERNATIVE_PHONE = 'Account.CMN_AlternativePhone__pc';
	private static final String FIELD_ACCOUNT_ALTERNATIVE_WORK_PHONE = 'Account.CMN_AlternativeWorkPhone__pc';
	private static final String FIELD_ACCOUNT_BANK_ACCOUNT_NUMBER = 'Account.AW_BankAccountNumber__pc';
	private static final String FIELD_ACCOUNT_BANK_NAME = 'Account.AW_BankName__pc';
  private static final String FIELD_ACCOUNT_BIRTH_DATE = 'Account.PersonBirthdate';
	private static final String FIELD_ACCOUNT_BUSINESS_ALTERNATIVE_EMAIL = 'Account.CMN_AlternativeEmail__c';
	private static final String FIELD_ACCOUNT_BUSINESS_ALTERNATIVE_MOBILE = 'Account.CMN_AlternativeMobile__c';
	private static final String FIELD_ACCOUNT_BUSINESS_ALTERNATIVE_PHONE = 'Account.CMN_AlternativePhone__c';
	private static final String FIELD_ACCOUNT_BUSINESS_EMAIL = 'Account.AW_Email__c';
	private static final String FIELD_ACCOUNT_BUSINESS_MOBILE = 'Account.AW_Mobile__c';
  private static final String FIELD_ACCOUNT_IDENTIFICATION_NUMBER = 'Account.AW_IdentificationNumber__pc';
  private static final String FIELD_ACCOUNT_IDENTIFICATION_TYPE = 'Account.AW_IdentificationType__pc';
  private static final String FIELD_ACCOUNT_INITIAL = 'Account.CMN_Initials__pc';
	private static final String FIELD_ACCOUNT_IS_PERSON_ACCOUNT = 'Account.IsPersonAccount';
	private static final String FIELD_ACCOUNT_NAME = 'Account.Name';
	private static final String FIELD_ACCOUNT_PERSON_BUSINESS_ALTERNATIVE_EMAIL = 'Account.CMN_AlternativeBusinessEmail__pc';
	private static final String FIELD_ACCOUNT_PERSON_BUSINESS_ALTERNATIVE_MOBILE = 'Account.CMN_AlternativeBusinessMobile__pc';
	private static final String FIELD_ACCOUNT_PERSON_BUSINESS_EMAIL = 'Account.CMN_BusinessEmail__pc';
	private static final String FIELD_ACCOUNT_PERSON_BUSINESS_MOBILE = 'Account.CMN_BusinessMobile__pc';
	private static final String FIELD_ACCOUNT_PERSON_EMAIL = 'Account.PersonEmail';
	private static final String FIELD_ACCOUNT_PERSON_MOBILE = 'Account.PersonMobilePhone';
	private static final String FIELD_ACCOUNT_PHONE = 'Account.Phone';
  private static final String FIELD_ACCOUNT_REGISTRATION_TRUST_NUMBER = 'Account.AW_CompanyRegistrationTrustNumber__c';
	private static final String FIELD_ACCOUNT_RESIDENTIAL_CITY = 'Account.AW_ResidentialCity__pc';
	private static final String FIELD_ACCOUNT_RESIDENTIAL_COUNTRY = 'Account.AW_ResidentialCountry__pc';
	private static final String FIELD_ACCOUNT_RESIDENTIAL_LINE_ONE = 'Account.AW_ResidentialStreetLineOne__pc';
	private static final String FIELD_ACCOUNT_RESIDENTIAL_LINE_THREE = 'Account.AW_ResidentialStreetLineThree__pc';
	private static final String FIELD_ACCOUNT_RESIDENTIAL_LINE_TWO = 'Account.AW_ResidentialStreetLineTwo__pc';
	private static final String FIELD_ACCOUNT_RESIDENTIAL_POSTAL_CODE = 'Account.AW_ResidentialPostalCode__pc';
	private static final String FIELD_ACCOUNT_RESIDENTIAL_SUBURB = 'Account.AW_ResidentialSuburb__pc';
  private static final String FIELD_ACCOUNT_SALUTATION = 'Account.Salutation';
	private static final String FIELD_ACCOUNT_WORK_PHONE = 'Account.CMN_WorkPhone__pc';
	private static final String FIELD_ASSOCIATED_CONTRACT_EXTENSION_FIELDSET = 'RSC_ServiceType__r.RSC_AssociatedContractExtensionFieldSet__c';
	private static final String FIELD_CASE_EXTENSION_CLIENT_CELL_NUMBER = 'SC_CaseExtension__r.RSC_ClientCellNumber__c';
	private static final String FIELD_CASE_EXTENSION_FIELDSET = 'RSC_ServiceType__r.RSC_CaseExtensionFieldSet__c';
	private static final String FIELD_CLIENT_FIRST_NAME = 'SC_CaseExtension__r.RSC_ClientFirstName__c';
	private static final String FIELD_CLIENT_ID_NUMBER = 'SC_CaseExtension__r.RSC_ClientIdentificationNumber__c';
	private static final String FIELD_CLIENT_LAST_NAME = 'SC_CaseExtension__r.RSC_ClientSurname__c';
	private static final String FIELD_CLIENT_TITLE = 'SC_CaseExtension__r.RSC_ClientTitle__c';
	private static final String FIELD_CONSULTANT_CODE_NAME = 'SC_ConsultantCode__r.Name';
	private static final String FIELD_FINANCIAL_ADVISER_FIRST_NAME = 'Case.RSC_AdviserFirstName__c';
	private static final String FIELD_FINANCIAL_ADVISER_LAST_NAME = 'Case.RSC_AdviserLastName__c';
  @TestVisible
  private static final String FIELD_IS_RELATED = Case.RSC_IsRelated__c.getDescribe().getLocalName();
	private static final String FIELD_OWNER_LAST_NAME = 'Owner.LastName';
  private static final String FIELD_OWNER_NAME = 'Owner.Name';
	private static final String FIELD_OWNER_TITLE = 'Owner.Title';
  private static final String FIELD_PROFILE_NAME = 'CreatedBy.Profile.Name';
	private static final String FIELD_SERVICE_TYPE = Case.RSC_ServiceType__c.getDescribe().getLocalName();
  private static final String FIELD_SERVICE_TYPE_ASSIGNABLE = 'RSC_ServiceType__r.SC_Assignable__c';
  private static final String FIELD_SERVICE_TYPE_CODE = 'RSC_ServiceType__r.SC_ServiceType__c';
	private static final String FIELD_SERVICE_TYPE_COMMUNICATIONS_LABEL = 'RSC_ServiceType__r.SC_CommunicationsLabel__c';
  private static final String FIELD_SERVICE_TYPE_DEPARTMENT = 'RSC_ServiceType__r.SC_Department__c';
	private static final String FIELD_SERVICE_TYPE_IS_LATEST_VERSION = 'RSC_ServiceType__r.SC_KnowledgeArticle__r.IsLatestVersion';
	private static final String FIELD_SERVICE_TYPE_KNOWLEDGE_ARTICLE = 'RSC_ServiceType__r.SC_KnowledgeArticle__c';
	private static final String FIELD_SERVICE_TYPE_KNOWLEDGE_ARTICLE_ID = 'RSC_ServiceType__r.SC_KnowledgeArticle__r.KnowledgeArticleId';
  private static final String FIELD_SERVICE_TYPE_NAME = 'RSC_ServiceType__r.Name';
	private static final String FIELD_STATUS = Case.Status.getDescribe().getLocalName();
  private static final String RELATED_ASSOCIATED_CONTRACTS = 'Associated_Contracts__r';
  private static final String RELATED_CONTENT_DOCUMENT = 'ContentDocumentLinks';
  private static final String RELATED_DOCUMENT_CHECKLIST = 'DocumentChecklistItemPR';
	private static final String RELATED_PROCESS_LOGS = 'Case_Process_logs__r';


	/**
	 * @description Related Account parent account Id
	 */
	public static final String FIELD_ACCOUNT_PARENT_ACCOUNT = 'Account.AW_ParentAccount__c';
	/**
	 * @description Related Account record type
	 */
	public static final String FIELD_ACCOUNT_RECORDTYPE = 'Account.RecordType.DeveloperName';
	/**
	 * @description The sub-status for a case if an error occurred when an outbound API was called
	 */
	public static final String SUB_STATUS_TECHNICAL_ERROR = 'Technical Error';
	/**
	 * @description The sub-status for a case when an outbound API was called
	 */
	public static final String SUB_STATUS_PROCESSING_SOURCE = 'Processing at Source';
	/**
   * @description stores the case origin email picklist value
   */
  public static final String DEFAULT_CASE_ORIGIN = 'Email';
  /**
	 * @description stores the case origin API picklist value
	 */
	public static final String CASE_ORIGIN_API = 'API';
	/**
   * @description stores the source system as Salesforce
   */
  public static final String DEFAULT_SOURCE_SYSTEM = 'Salesforce';
  /**
   * @description stores the API name of DocumentChecklistItem Name
   */
  public static final String ENTITY_DOCUMENT_NAME = 'DocumentChecklistItem.Name';
  /**
   * @description stores the field API name of AccountId on Case
   */
  public static final String FIELD_ACCOUNT_ID = Case.AccountId.getDescribe().getLocalName();
  /**
   * @description stores the field API name of Case Id
   */
	public static final String FIELD_CASE_ID = CMN_DAL_SObjectDomain.FIELD_ID;
  /**
   * @description stores the field API name of CreatedDate on Case
   */
  public static final String FIELD_CREATED_DATE = Case.CreatedDate.getDescribe().getLocalName();
  /**
   * @description stores the field API name of Origin on Case
   */
  public static final String FIELD_ORIGIN = Case.Origin.getDescribe().getLocalName();
  /**
   * @description stores the field API name of ParentId on Case
   */
  public static final String FIELD_PARENT_CASE_ID = Case.ParentId.getDescribe().getLocalName();
  /**
   * @description stores the field API name of Requester Mail on Case
   */
  public static final String FIELD_REQUESTER_EMAIL = Case.SC_RequesterEmail__c.getDescribe().getLocalName();
  /**
   * @description stores the field API name of Requester Mobile on Case
   */
  public static final String FIELD_REQUESTER_MOBILE = Case.SC_RequesterMobile__c.getDescribe().getLocalName();
  /**
   * @description stores the field API name of Requester Name on Case
   */
  public static final String FIELD_REQUESTER_NAME = Case.SC_RequesterName__c.getDescribe().getLocalName();
  /**
   * @description stores the field API name of Requester Phone on Case
   */
  public static final String FIELD_REQUESTER_PHONE = Case.SC_RequesterPhone__c.getDescribe().getLocalName();
  /**
   * @description stores the field API name of Requester Type on Case
   */
  public static final String FIELD_REQUESTER_TYPE = Case.SC_RequesterType__c.getDescribe().getLocalName();
  /**
   * @description stores the field API name of Source system on Case
   */
  public static final String FIELD_SOURCE_SYSTEM = Case.SC_SourceSystem__c.getDescribe().getLocalName();
  /**
   * @description stores the field API name of SubStatus on Case
   */
  public static final String FIELD_SUB_STATUS = Case.SC_SubStatus__c.getDescribe().getLocalName();
  /**
   * @description stores the field API name of WorkFlow Case Number on Case
   */
  public static final String FIELD_WORKFLOW_CASE_NUMBER = Case.RSC_WorkflowCaseNumber__c.getDescribe().getLocalName();
  /**
   * @description stores the Object API name of Case
   */
	public static final String OBJECT_NAME = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
  /**
   * @description stores the API name of Clone fieldset on Case
   */
  public static final String FIELD_SET_CLONE_CASE = 'RSC_Clone';
  /**
   * @description stores the API name of Requester fields fieldset on Case
   */
  public static final String FIELD_SET_REQUESTER_FIELDS = 'RSC_RequesterFields';
  /**
   * @description stores the constant for the Origin picklist Phone
   */
  public static final String PICK_ORIGIN = 'Phone';
  /**
   * @description stores the constant for the Priority picklist Medium
   */
  public static final String PRIORITY_MEDIUM = 'Medium';
  /**
	 * @description stores the constant for the Priority picklist Low
	 */
	public static final String PRIORITY_LOW = 'Low';
	/**
   * @description stores the constant for the Priority picklist Normal used to send to Horizon
   */
  public static final String PRIORITY_NORMAL = 'Normal';
  /**
   * @description stores the constant for the Requester type as Customer
   */
  public static final String REQUESTER_TYPE_CUSTOMER = 'Customer';
  /**
   * @description stores the APIName  for the RecordType Retail
   */
  public static final String RT_RETAIL = 'RSC_Retail';
  /**
   * @description stores the constant for the SourceSystem
   */
  public static final String SOURCE_SYSTEM_CHANNEL = 'Service Console';
  /**
   * @description stores the constant for the Status picklist Closed
   */
  public static final String STATUS_CLOSED = 'Closed';
  /**
   * @description stores the constant for the Status picklist In Progress
   */
  public static final String STATUS_IN_PROGRESS = 'In Progress';
  /**
   * @description stores the constant for the Status picklist New
   */
  public static final String STATUS_NEW = 'New';
  /**
   * @description stores the constant for the Status picklist Resolved
   */
  public static final String STATUS_RESOLVED = 'Resolved';
  /**
   * @description stores the constant for the SubStatus picklist On Hold
   */
  public static final String SUB_STATUS_ON_HOLD = 'On Hold';
  /**
   * @description stores the constant for the SunStatus picklist Terminated
   */
  public static final String SUB_STATUS_TERMINATED = 'Terminated';
  /**
   * @description stores the constant for the Status used to send to Horizon
   */
  public static final String WORKFLOW_STATUS_CLOSED = 'Closed';
  /**
   * @description stores the constant for the SubStatus as Pend used to send to Horizon
   */
  public static final String WORKFLOW_STATUS_PEND = 'Pend';
  /**
   * @description stores the constant for the Status as WIP(In-Progress) used to send to Horizon
   */
  public static final String WORKFLOW_STATUS_WIP = 'WIP(In-Progress)';
  /**
   * @description stores the client type as Company registration or trust
   */
  public static final String COMPANY_TRUST_TYPE = 'CoRegNumber';
  /**
   * @description stores the client type as ID or passport type
   */
  public static final String IDENTITY_TYPE = 'IdentityNumber';
	/**
	 * @description Authentication Status Authenticated
	 */
	public static final String AUTHENTICATION_STATUS_AUTHENTICATED = 'Authenticated';
	/**
	 * @description Authentication Status Not Authenticated
	 */
	public static final String AUTHENTICATION_STATUS_NOT_AUTHENTICATED = 'Not Authenticated';
	/**
	 * @description Authentication Status Overridden
	 */
	public static final String AUTHENTICATION_STATUS_OVERRIDDEN = 'Overridden';

  /**
   * @description Method to define the fields to retrieve for most query's
   *
   * @return A list of fields
   */
  private static Set<String> getDefaultFields()
  {
    return new Set<String>
    {
        Case.CaseNumber.getDescribe().getLocalName(),
        Case.Comments.getDescribe().getLocalName(),
				Case.ContactId.getDescribe().getLocalName(),
        Case.CreatedDate.getDescribe().getLocalName(),
        Case.LastModifiedDate.getDescribe().getLocalName(),
        Case.OwnerId.getDescribe().getLocalName(),
        Case.Priority.getDescribe().getLocalName(),
        Case.RSC_Department__c.getDescribe().getLocalName(),
        Case.RSC_Team__c.getDescribe().getLocalName(),
				Case.SC_AssignedTo__c.getDescribe().getLocalName(),
				Case.SC_CaseExtension__c.getDescribe().getLocalName(),
        Case.SC_ConsultantCode__c.getDescribe().getLocalName(),
        Case.SC_Requester__c.getDescribe().getLocalName(),
        Case.Subject.getDescribe().getLocalName(),
				FIELD_ACCOUNT_ALTERNATIVE_EMAIL,
				FIELD_ACCOUNT_ALTERNATIVE_MOBILE,
				FIELD_ACCOUNT_ALTERNATIVE_PHONE,
				FIELD_ACCOUNT_ALTERNATIVE_WORK_PHONE,
				FIELD_ACCOUNT_BANK_ACCOUNT_NUMBER,
				FIELD_ACCOUNT_BANK_NAME,
        FIELD_ACCOUNT_BIRTH_DATE,
				FIELD_ACCOUNT_BUSINESS_ALTERNATIVE_EMAIL,
				FIELD_ACCOUNT_BUSINESS_ALTERNATIVE_MOBILE,
				FIELD_ACCOUNT_BUSINESS_ALTERNATIVE_PHONE,
				FIELD_ACCOUNT_BUSINESS_EMAIL,
				FIELD_ACCOUNT_BUSINESS_MOBILE,
        FIELD_ACCOUNT_ID,
        FIELD_ACCOUNT_IDENTIFICATION_NUMBER,
        FIELD_ACCOUNT_IDENTIFICATION_TYPE,
        FIELD_ACCOUNT_INITIAL,
				FIELD_ACCOUNT_IS_PERSON_ACCOUNT,
				FIELD_ACCOUNT_NAME,
				FIELD_ACCOUNT_PARENT_ACCOUNT,
				FIELD_ACCOUNT_PERSON_BUSINESS_ALTERNATIVE_EMAIL,
				FIELD_ACCOUNT_PERSON_BUSINESS_ALTERNATIVE_MOBILE,
				FIELD_ACCOUNT_PERSON_BUSINESS_EMAIL,
				FIELD_ACCOUNT_PERSON_BUSINESS_MOBILE,
				FIELD_ACCOUNT_PERSON_EMAIL,
				FIELD_ACCOUNT_PERSON_MOBILE,
				FIELD_ACCOUNT_PHONE,
        FIELD_ACCOUNT_RECORDTYPE,
        FIELD_ACCOUNT_REGISTRATION_TRUST_NUMBER,
				FIELD_ACCOUNT_RESIDENTIAL_CITY,
				FIELD_ACCOUNT_RESIDENTIAL_COUNTRY,
				FIELD_ACCOUNT_RESIDENTIAL_LINE_ONE,
				FIELD_ACCOUNT_RESIDENTIAL_LINE_THREE,
				FIELD_ACCOUNT_RESIDENTIAL_LINE_TWO,
				FIELD_ACCOUNT_RESIDENTIAL_POSTAL_CODE,
				FIELD_ACCOUNT_RESIDENTIAL_SUBURB,
        FIELD_ACCOUNT_SALUTATION,
				FIELD_ACCOUNT_WORK_PHONE,
				FIELD_ASSOCIATED_CONTRACT_EXTENSION_FIELDSET,
				FIELD_CASE_EXTENSION_CLIENT_CELL_NUMBER,
				FIELD_CASE_EXTENSION_FIELDSET,
        FIELD_CASE_ID,
				FIELD_CLIENT_FIRST_NAME,
				FIELD_CLIENT_ID_NUMBER,
				FIELD_CLIENT_LAST_NAME,
				FIELD_CLIENT_TITLE,
        FIELD_CONSULTANT_CODE_NAME,
        FIELD_CREATED_DATE,
				FIELD_FINANCIAL_ADVISER_FIRST_NAME,
				FIELD_FINANCIAL_ADVISER_LAST_NAME,
        FIELD_IS_RELATED,
        FIELD_ORIGIN,
				FIELD_OWNER_LAST_NAME,
        FIELD_OWNER_NAME,
				FIELD_OWNER_TITLE,
        FIELD_PROFILE_NAME,
        FIELD_REQUESTER_EMAIL,
        FIELD_REQUESTER_MOBILE,
        FIELD_REQUESTER_NAME,
        FIELD_REQUESTER_PHONE,
        FIELD_REQUESTER_TYPE,
				FIELD_SERVICE_TYPE,
        FIELD_SERVICE_TYPE_ASSIGNABLE,
        FIELD_SERVICE_TYPE_CODE,
				FIELD_SERVICE_TYPE_COMMUNICATIONS_LABEL,
        FIELD_SERVICE_TYPE_DEPARTMENT,
				FIELD_SERVICE_TYPE_IS_LATEST_VERSION,
				FIELD_SERVICE_TYPE_KNOWLEDGE_ARTICLE,
				FIELD_SERVICE_TYPE_KNOWLEDGE_ARTICLE_ID,
        FIELD_SERVICE_TYPE_NAME,
				FIELD_STATUS,
        FIELD_SUB_STATUS,
				FIELD_WORKFLOW_CASE_NUMBER
    };
  }

  /**
   * @description This method is use to get a Case with the particular Id
   *
   * @param recordId The record of the Case
   *
   * @return A single Case
   */
  public static Case findById(Id recordId)
  {
    return (Case)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordId, getDefaultFields());
  }

  /**
   * @description Will find a list of envelope by Id
   *
   * @param caseIds The Set of case Ids to retrieve
   *
   * @return List of Cases
   */
  public static List<Case> findById(Set<Id> caseIds)
  {
    return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, caseIds, getDefaultFields());
  }

  /**
   * @description This method is use to get the case with the workflow case number
   *
   * @param workflowCaseNumbers Workflow case numbers
   *
   * @return List<Case>
   */
  public static List<Case> findByWorkflowCaseNumber(Set<Object> workflowCaseNumbers)
  {
    CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters
				(
						OBJECT_NAME,
						getDefaultFields()
				);

		searchParameters.searchConditions.inX(FIELD_WORKFLOW_CASE_NUMBER, workflowCaseNumbers);

		searchParameters.childSearchParameters.add(new CMN_DAL_Search.SOQLSearchParameters
				(
						SC_DAL_DocumentChecklistItem.OBJECT_NAME,
						SC_DAL_DocumentChecklistItem.getDefaultFields(),
						RELATED_DOCUMENT_CHECKLIST
				));

		searchParameters.childSearchParameters.add(new CMN_DAL_Search.SOQLSearchParameters
				(
						SC_DAL_AssociatedContract.OBJECT_NAME,
						SC_DAL_AssociatedContract.getDefaultFields(),
						RELATED_ASSOCIATED_CONTRACTS
				));

		return CMN_DAL_Search.getObjects(searchParameters);
  }

  /**
	 * @description Will find cases by provided Ids returned the case and its associated records
   *
	 * @param caseIds Ids to filter the cases by
   *
	 * @return List of Items with child records
   */
	public static List<Case> findByIdWithChildDetails(Set<Id> caseIds)
  {
    CMN_SOQL_Builder associatedContracts =
        new CMN_SOQL_Builder()
            .selectX(SC_DAL_AssociatedContract.getDefaultFields())
            .fromX(RELATED_ASSOCIATED_CONTRACTS);

    CMN_SOQL_Builder documentChecklistItems =
        new CMN_SOQL_Builder()
            .selectX(SC_DAL_DocumentChecklistItem.getDefaultFields())
            .fromX(RELATED_DOCUMENT_CHECKLIST);

		CMN_SOQL_Builder contentDocumentLinks =
				new CMN_SOQL_Builder()
						.selectX(SC_DAL_ContentDocumentLink.getDefaultFields())
						.fromX(RELATED_CONTENT_DOCUMENT);

    CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();
		andCondition.add(new CMN_SOQL_Query.SetCondition(FIELD_CASE_ID, CMN_SOQL_Query.Operator.INX, CMN_UTIL_System.setToList(caseIds)));

    CMN_SOQL_Builder builder =
        new CMN_SOQL_Builder()
            .selectX(getDefaultFields())
            .selectX(associatedContracts)
            .selectX(documentChecklistItems)
						.selectX(contentDocumentLinks)
            .fromX(OBJECT_NAME)
            .whereX(andCondition);

    return Database.query(builder.toSoql());

  }
  
	/**
   * @description Will return all Cases created by unit tests
   *
   * @return A list of Cases
   */
  @TestVisible
  private static List<Case> getAll()
  {
    return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
  }

  /**
   * @description Will return list of  Child Cases related to Parent Case
   *
   * @param parentRecordId will take the id of parent case
   *
   * @return A list of Cases
   */
  public static List<Case> findByParent(Id parentRecordId)
  {
    return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_PARENT_CASE_ID, new Set<Id> {parentRecordId}, getDefaultFields());
  }

  /**
   * @description Will return list of  Child Cases related to Account
   *
   * @param accountId will take the id of Account associated with Case
   *
   * @return list of found Cases
   */
  public static List<Case> findByAccountId(Id accountId)
  {
    return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_ACCOUNT_ID, new Set<Id> {accountId}, getDefaultFields());
  }
	/**
	 * @description This method is use to get the case with the workflow case number and client Identification number
	 *
	 * @param workflowCaseNumbers Workflow case numbers
	 * @param clientIdNumber client Identification numbers of case extension
	 *
	 * @return List<Case>
	 */
	public static List<Case> findByCaseClientNumber(Set<Object> workflowCaseNumbers, String clientIdNumber)
	{
		CMN_DAL_Search.SOQLSearchParameters searchCases = new CMN_DAL_Search.SOQLSearchParameters
				(
						OBJECT_NAME,
						getDefaultFields()
				);

		searchCases.searchConditions.inX(FIELD_WORKFLOW_CASE_NUMBER, workflowCaseNumbers);
		searchCases.searchConditions.equalsX(FIELD_CLIENT_ID_NUMBER, clientIdNumber);

		searchCases.childSearchParameters.add(new CMN_DAL_Search.SOQLSearchParameters
				(
						SC_DAL_AssociatedContract.OBJECT_NAME,
						SC_DAL_AssociatedContract.getDefaultFields(),
						RELATED_ASSOCIATED_CONTRACTS
				));

		return CMN_DAL_Search.getObjects(searchCases);
	}
}