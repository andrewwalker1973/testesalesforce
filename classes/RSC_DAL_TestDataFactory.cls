/**
 * @description Factory to create test data specific to servicing.
 *
 * @author vijay.jayswal@accenture.com, jayanth.kumar.s@accenture.com
 *
 * @date 2021, December 2022
 */
@SuppressWarnings('PMD.ApexCRUDViolation,PMD.CyclomaticComplexity')
public without sharing class RSC_DAL_TestDataFactory
{
  @TestVisible
  private static final String BUSINESS_TYPE = 'Company';
  @TestVisible
  private static final String CONTACT_PREFERENCE = 'Mobile';
  @TestVisible
  private static final String CORRESPONDENCE_PREFERENCE = 'Postal';
  private static final String ENTITY_DOCUMENT_CODE = 'DocumentChecklistItem.DocumentTypeId';
  private static final String ENTITY_DOCUMENT_NAME = 'DocumentChecklistItem.Name';
  private static final String LITERAL_NAME = 'Name';
  private static final String LITERAL_TYPE = 'DocumentTypeId';

  /**
   * @description Method to create and return document check list item
   *
   * @param parentId The parent object against which the check list items should be created
   * @param numberOfRecords store the number of records
   *
   * @return List of Document Check List Items
   */
  @TestVisible
  private static List<DocumentChecklistItem> newDocumentCheckListItems(Id parentId, Integer numberOfRecords)
  {
    List<DocumentChecklistItem> documentChecklistItems = new List<DocumentChecklistItem>();

    Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(DocumentChecklistItem.SObjectType, SC_DAL_DocumentChecklistItem.RT_CASE_DOCUMENT);

    for(Integer i = 0; i < numberOfRecords; i++)
    {
      DocumentChecklistItem newListItem = new DocumentChecklistItem();

      DocumentType docType = SC_DAL_DocumentType.findRandomActive();

      newListItem.Name = docType.MasterLabel;
      newListItem.AW_DateVaulted__c = System.today();
      newListItem.AW_Vaulted__c = true;
      newListItem.CMN_VaultedId__c = CMN_DAL_SObjectDomain.generateRandomNumber();
      newListItem.DocumentTypeId = docType.Id;
      newListItem.ParentRecordId = parentId;
      newListItem.RecordTypeId = recordTypeId;
      newListItem.Status = SC_DAL_DocumentChecklistItem.STATUS_NEW;

      documentChecklistItems.add(newListItem);
    }

    return documentChecklistItems;
  }

  /**
   * @description Method to create and return document check list item
   *
   * @param parentId The parent object against which the check list items should be created
   * @param numberOfRecords store the number of records
   *
   * @return List of Document Check List Items that are inserted
   */
  @TestVisible
  private static List<DocumentChecklistItem> insertDocumentCheckListItems(Id parentId, Integer numberOfRecords)
  {
    List<DocumentChecklistItem> documentChecklistItems = newDocumentCheckListItems(parentId, numberOfRecords);
    insert documentChecklistItems;
    return documentChecklistItems;
  }

  /**
   * @description Method to return the new Case related to Account
   *
   * @param numberOfRecords store the number of records
   * @param accountId store the parent account Id
   *
   * @return created items
   */
  @TestVisible
  private static List<InsurancePolicy> createInsurancePolicies(Integer numberOfRecords, Id accountId)
  {
    List<InsurancePolicy> newPolicies = new List<InsurancePolicy>();

    Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(InsurancePolicy.SObjectType, SC_DAL_InsurancePolicy.RT_INSURANCE_POLICY);

    for(Integer i = 0; i < numberOfRecords; i++)
    {
      InsurancePolicy newPolicy = AW_DAL_TestDataFactory.newInsurancePolicy(accountId, recordTypeId);

      newPolicy.AW_CommencementDate__c = CMN_DAL_SObjectDomain.generateRandomDate();
      newPolicy.PolicyType = SC_DAL_InsurancePolicy.TYPE_HOME;
      newPolicy.PremiumAmount = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());
      newPolicy.Status = SC_DAL_InsurancePolicy.STATUS_IN_FORCE;

      newPolicies.add(newPolicy);
    }

    insert newPolicies;

    return newPolicies;
  }


  /**
   * @description Method to create and return ActionPlan Template
   *
   * @param numberOfRecords The number of records to be created
   * @param isItemsRequired flag to insert ActionPlanTemplate Item value
   * @param isAuthorityRequired Boolean flag to indicate if the authority document is required
   *
   * @return A List ActionPlanTemplate that's been committed
   */
  @TestVisible
  private static List<ActionPlanTemplate> insertActionPlanTemplates(Integer numberOfRecords, Boolean isItemsRequired, Boolean isAuthorityRequired)
  {
    List<ActionPlanTemplate> newTemplates = new List<ActionPlanTemplate>();

    Set<Id> versionId = new Set<Id>();

    List<String> entityFieldNames = new List<String>();
    entityFieldNames.add(ENTITY_DOCUMENT_NAME);
    entityFieldNames.add(ENTITY_DOCUMENT_CODE);

    for(Integer i = 0; i < numberOfRecords; i++)
    {
      ActionPlanTemplate newTemplate = new ActionPlanTemplate();
      newTemplate.Name = CMN_DAL_SObjectDomain.generateRandomName();
      newTemplate.TargetEntityType = SC_DAL_ServiceType.OBJECT_NAME;
      newTemplates.add(newTemplate);
    }

    insert newTemplates;

    if(isItemsRequired)
    {
      for(Integer i = 0; i < newTemplates.size(); i++)
      {
        versionId.add(newTemplates[i].Id);
      }

      List<ActionPlanTemplateVersion> versions = SC_DAL_ActionPlanTemplateVersion.findByTemplateId(versionId);

      for(ActionPlanTemplateVersion version : versions)
      {
        //newString contains the documentChecklist Item fields and hence that many actionPlanTemplateItems has to be created.
        insertActionPlanTemplateItems(entityFieldNames.size(), version, entityFieldNames, isAuthorityRequired);
      }
    }
    return newTemplates;
  }

  /**
   * @description Method to create and return ActionPlanTemplateItem
   *
   * @param numberOfRecords The number of records to be created
   * @param version The ActionPlanTemplateVersionId to be linked
   * @param entityFieldNames The list of entity field name of entity type
   * @param isAuthorityRequired Boolean flag to indicate if the authority document is required
   *
   * @return A List ActionPlanTemplateItem Item that's been committed
   */
  @TestVisible
  private static List<ActionPlanTemplateItem> insertActionPlanTemplateItems
      (Integer numberOfRecords, ActionPlanTemplateVersion version, List<String> entityFieldNames, Boolean isAuthorityRequired)
  {
    List<ActionPlanTemplateItem> newTemplateItems = new List<ActionPlanTemplateItem>();

    for(Integer i = 0; i < numberOfRecords; i++)
    {
      ActionPlanTemplateItem newTemplateItem = new ActionPlanTemplateItem();
      newTemplateItem.ActionPlanTemplateVersionId = version.Id;
      newTemplateItem.Name = CMN_DAL_SObjectDomain.generateRandomName();
      newTemplateItem.ItemEntityType = SC_DAL_DocumentChecklistItem.OBJECT_NAME;
      newTemplateItem.IsActive = true;
      newTemplateItem.IsRequired = true;
      newTemplateItems.add(newTemplateItem);
    }

    insert newTemplateItems;

    DocumentType authorizationType = isAuthorityRequired ?
        SC_DAL_DocumentType.findByDeveloperName(new Set<String> {SC_DAL_DocumentType.LETTER_OF_AUTHORITY_CODE}).iterator().next() : null;

    for(ActionPlanTemplateItem item : newTemplateItems)
    {
      insertActionPlanTemplateItemValues(entityFieldNames.size(), item.Id, entityFieldNames, authorizationType);
    }
    return newTemplateItems;
  }

  /**
   * @description Method to create and return ActionPlanTemplateItemValue
   *
   * @param numberOfRecords The number of records to be created
   * @param itemId The ActionPlanTemplateItem Id to be linked
   * @param entityFieldNames The list of entity field name of entity type
   * @param authorizationType Indicate if the values should be based on an Authorisation type of document
   *
   * @return A List ActionPlanTemplateItemValue Item that's been committed
   */
  @TestVisible
  private static List<ActionPlanTemplateItemValue> insertActionPlanTemplateItemValues
      (Integer numberOfRecords, Id itemId, List<String> entityFieldNames, DocumentType authorizationType)
  {
    List<ActionPlanTemplateItemValue> newTemplateItemValues = new List<ActionPlanTemplateItemValue>();

    for(Integer i = 0; i < numberOfRecords; i++)
    {
      ActionPlanTemplateItemValue newTemplateItemValue = new ActionPlanTemplateItemValue();
      newTemplateItemValue.ActionPlanTemplateItemId = itemId;
      newTemplateItemValue.IsActive = true;

      newTemplateItemValue.ItemEntityFieldName = entityFieldNames[i];

      if(ENTITY_DOCUMENT_NAME.equals(newTemplateItemValue.ItemEntityFieldName))
      {
        newTemplateItemValue.Name = LITERAL_NAME;
        newTemplateItemValue.ValueLiteral = authorizationType == null ? CMN_DAL_SObjectDomain.generateRandomName() : authorizationType.MasterLabel;
      }
      else
      {
        newTemplateItemValue.Name = LITERAL_TYPE;
        newTemplateItemValue.ValueLiteral = authorizationType == null ? SC_DAL_DocumentType.findRandomActive().Id : authorizationType.Id;
      }

      newTemplateItemValues.add(newTemplateItemValue);
    }

    insert newTemplateItemValues;
    return newTemplateItemValues;
  }

  /**
   * @description Method to return the Case
   *
   * @param numberOfRecords The number of records to be created
   * @param accountId store the parent account Id
   *
   * @return Case
   */
  @TestVisible
  private static List<Case> newCase(Integer numberOfRecords, Id accountId)
  {
    List<Case> newCase = new List<Case>();
    for(Integer i = 0; i < numberOfRecords; i++)
    {

      Case caseObj = new Case();
      caseObj.Status = SC_DAL_Case.STATUS_NEW;
      caseObj.Origin = SC_DAL_Case.PICK_ORIGIN;
      caseObj.AccountId = accountId;
      caseObj.Description = CMN_DAL_SObjectDomain.generateRandomName();
      caseObj.Subject = CMN_DAL_SObjectDomain.generateRandomName();
      caseObj.RSC_WorkflowCaseNumber__c = Decimal.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber());
      caseObj.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Case.SObjectType, SC_DAL_Case.RT_RETAIL);
      caseObj.SC_RequesterType__c = SC_DAL_Case.REQUESTER_TYPE_CUSTOMER;
      newCase.add(caseObj);
    }
    return newCase;
  }

  /**
   * @description Method to create and return the Content Version record
   *
   * @param linkToObjectId for document checklist item ID
   * @param file The content of the file attached to the Document Checklist Item
   * @param fileName The name of the file attached to the Document Checklist Item
   *
   * @return Single ContentVersion record
   */
  private static ContentVersion newContentVersion(String linkToObjectId, String file, String fileName)
  {
    ContentVersion newContentVersion = CMN_DAL_DataFactory.newContentVersion
        (
            linkToObjectId,
            fileName,
            EncodingUtil.base64Decode(EncodingUtil.urlDecode(file, CMN_API_HttpBase.UTF8_ENCODING_SCHEME))
        ) ;

    newContentVersion.IsMajorVersion = true;

    return newContentVersion;
  }

  /**
   * @description Method to create a new ContentVersion
   *
   * @param numberOfRecords The number of records to be created
   * @param linkToObjectId The Id of record to which ContentVersion has to be linked
   *
   * @return ContentVersion
   */
  @TestVisible
  private static List<ContentVersion> createNewContentVersion(Integer numberOfRecords, Id linkToObjectId)
  {
    List<ContentVersion> newContentVersionToUpload = new List<ContentVersion>();

    for(Integer i = 0; i < numberOfRecords; i++)
    {
      String fileName = CMN_DAL_SObjectDomain.generateRandomName() + CMN_UTIL_String.DOT + CMN_DAL_ContentVersion.FILE_TYPE_PDF;
      String file = CMN_DAL_SObjectDomain.generateRandomDescription();

      ContentVersion newContentVersion = newContentVersion(linkToObjectId, file, fileName);

      newContentVersionToUpload.add(newContentVersion);
    }

    insert newContentVersionToUpload;

    return newContentVersionToUpload;
  }

  /**
   * @description Method to create  new BusinessAccount
   *
   * @param recordTypeDevName The record type of account
   * @param numberOfAccounts The number of records to be created
   *
   * @return accounts
   */

  @TestVisible
  private static List<Account> createBusinessAccounts(String recordTypeDevName, Integer numberOfAccounts)
  {
    Id accountRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, recordTypeDevName);

    List<Account> newAccounts = new List<Account>();

    for(Integer i = 1; i <= numberOfAccounts; i++)
    {
      Account newAccount = new Account();

      newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
      newAccount.AW_SKF_Id__c = CMN_DAL_SObjectDomain.generateRandomNumber(); // Populating UUID
      newAccount.FinServ__Status__c = SC_DAL_Account.STATUS_PROSPECT;
      newAccount.AW_CompanyRegistrationTrustNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();
      newAccount.AW_CorrespondencePreference__c = CORRESPONDENCE_PREFERENCE;
      newAccount.AW_ContactPreference__c = CONTACT_PREFERENCE;
      newAccount.AW_BusinessType__c = BUSINESS_TYPE;

      newAccount.RecordTypeId = accountRecordTypeId;

      newAccounts.add(newAccount);
    }

    insert newAccounts;

    return newAccounts;
  }

  /**
   * @description Method to create  new Practice Accounts
   *
   * @param recordTypeDevName The record type of account
   * @param numberOfAccounts The number of records to be created
   *
   * @return accounts
   */
  public static List<Account> newPracticeAccounts(String recordTypeDevName, Integer numberOfAccounts)
  {
    Id accountRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, recordTypeDevName);

    List<Account> accounts = new List<Account>();

    for(Integer i = 1; i <= numberOfAccounts; i++)
    {
      Account newAccount = new Account();
      newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
      newAccount.RecordTypeId = accountRecordTypeId;

      accounts.add(newAccount);
    }

    return accounts;
  }

  /**
   * @description Method to create  new Practice Contacts
   *
   * @param recordTypeDevName The record type of Contact
   * @param numberOfContacts The number of records to be created
   * @param newAccount The practice account record to be linked with contact
   *
   * @return contacts
   */
  @TestVisible
  private static List<Contact> createPracticeContacts(String recordTypeDevName, Integer numberOfContacts, Account newAccount)
  {
    List<Contact> newContacts = newPracticeContacts(recordTypeDevName, numberOfContacts, newAccount);

    insert newContacts;

    return newContacts;
  }

  /**
   * @description Method to create new instance of Practice Contacts
   *
   * @param recordTypeDevName The record type of Contact
   * @param numberOfContacts The number of records to be created
   * @param newAccount The practice account record to be linked with contact
   *
   * @return contacts
   */
  public static List<Contact> newPracticeContacts(String recordTypeDevName, Integer numberOfContacts, Account newAccount)
  {
    Id contactRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Contact.SObjectType, recordTypeDevName);

    List<Contact> contactsToInsert = new List<Contact>();

    for(Integer i = 1; i <= numberOfContacts; i++)
    {
      Contact newContact = new Contact();
      newContact.LastName = CMN_DAL_SObjectDomain.generateRandomName();
      newContact.RecordTypeId = contactRecordTypeId;
      if(newAccount != null)
      {
        newContact.AccountId = newAccount.Id;
      }

      contactsToInsert.add(newContact);
    }
    return contactsToInsert;
  }

  /**
   * @description Method to create  new consultant codes for a particular contact
   *
   * @param contactId The ContactId to link the ConsultantCode record
   * @param numberOfRecords Number of items to create
   * @param isActive Indicates if the agreement related to this ConsultantCoe is active
   *
   * @return A list of items committed
   */
  @TestVisible
  private static List<SC_ConsultantCodes__c> insertConsultantCode(Id contactId, Integer numberOfRecords, Boolean isActive)
  {
    List<SC_ConsultantCodes__c> newConsultantCodes = newConsultantCodeRecords(contactId, numberOfRecords, isActive);

    insert newConsultantCodes;

    return newConsultantCodes;
  }

  /**
   * @description Method to create  new consultant codes for a particular contact
   *
   * @param contactId The ContactId to link the ConsultantCode record
   * @param numberOfRecords Number of records to be created
   * @param isActive Indicates if the agreement related to this ConsultantCoe is active
   *
   * @return A list of items not committed
   */
   public static List<SC_ConsultantCodes__c> newConsultantCodeRecords(Id contactId, Integer numberOfRecords, Boolean isActive)
  {
    List<SC_ConsultantCodes__c> consultantCodeList = new List<SC_ConsultantCodes__c>();
    for(Integer i = 1; i <= numberOfRecords; i++)
    {
      SC_ConsultantCodes__c consultantCodeRecord = new SC_ConsultantCodes__c();
      consultantCodeRecord.SC_ContactId__c = contactId;
      consultantCodeRecord.Name = AW_DAL_User.generateRandomConsultantCode();
      consultantCodeRecord.SC_AgreementStatus__c = isActive;

      consultantCodeList.add(consultantCodeRecord);
    }

    return consultantCodeList;
  }

  /**
   * @description Method to insert and return new content version record
   *
   * @param documentCheckListId number of communication log records to create
   * @param file content of the file to be added to content version
    * @param fileName file name to be associated with the Content version
   *
   * @return Single ContentVersion record
   */
  public static ContentVersion createContentVersion(String documentCheckListId, String file, String fileName)
  {
    String base64File = EncodingUtil.urlDecode(file, CMN_API_HttpBase.UTF8_ENCODING_SCHEME);
    ContentVersion newContentVersion = new ContentVersion();
    newContentVersion.Title = fileName;
    newContentVersion.PathOnClient = '/' + fileName;
    newContentVersion.FirstPublishLocationId = documentCheckListId;
    newContentVersion.VersionData = EncodingUtil.base64Decode(base64File);
    newContentVersion.IsMajorVersion = true;

    insert newContentVersion;

    return newContentVersion;
  }

  /**
   * @description This method is used to insert new contracts and link them to case
   *
   * @param caseId The record to which contracts are associated
   * @param selectedPolicyIds This list has selected policies Id
   *
   * @return list of associated contracts which are going to create
   */
  public static List<SC_AssociatedContract__c> createNewContractsForCase(String caseId, List<Id> selectedPolicyIds)
  {
    List<SC_AssociatedContract__c> newContracts = new List<SC_AssociatedContract__c>();

    if(selectedPolicyIds != null)
    {
      for(Id policyId : selectedPolicyIds)
      {
        SC_AssociatedContract__c associatedContract = new SC_AssociatedContract__c();
        Schema.SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(policyId);
        if(objectType == FinServ__FinancialAccount__c.SObjectType)
        {
          associatedContract.SC_FinancialAccount__c = policyId;
        }
        else if(objectType == InsurancePolicy.SObjectType)
        {
          associatedContract.SC_InsurancePolicy__c = policyId;
        }
        associatedContract.SC_Case__c = caseId;
        newContracts.add(associatedContract);
      }
    }
    return newContracts;
  }

  /**
   * @description This method is used to insert new contracts and link them to case
   *
   * @param selectedPolicyIds This list has selected policies Id
   *
   * @return list of associated contracts which are going to create
   */
  public static List<SC_AssociatedContract__c> createNewContracts(List<Id> selectedPolicyIds)
  {
    return createNewContractsForCase(null, selectedPolicyIds);
  }
  
  /**
   * @description Method to create and return the instance of Communication Log record
   *
   * @param numberOfItems number of communication log records to create
   * @param caseId Id of the case to associate the communication log record
   *
   * @return List of Communication Log records
   */
  @TestVisible
  private static List<CMN_CommunicationLog__c> newCommunicationLog(Integer numberOfItems, Id caseId)
  {
    List<CMN_CommunicationLog__c> newLogs = new List<CMN_CommunicationLog__c>();
    for(Integer i = 0; i < numberOfItems; i++)
    {
      CMN_CommunicationLog__c newLog = new CMN_CommunicationLog__c();

      newLog.Case__c = caseId;
      newLog.CMN_OtherComments__c = CMN_DAL_SObjectDomain.generateRandomName();
      newLog.CMN_SendReminder__c = true;

      newLogs.add(newLog);
    }

    return newLogs;
  }
  /**
   * @description Method to create and return the record of Insurance policy participant
   *
   * @param insurancePolicy To store the record of Insurance policy
   * @param participantsTypes Type of Roles store in a set of string
   *
   * @return List of InsurancePolicyParticipant
   */
  @TestVisible
  private static List<InsurancePolicyParticipant> createInsurancePolicyParticipants(InsurancePolicy insurancePolicy, Set<String> participantsTypes)
  {
    List<InsurancePolicyParticipant> createdInsurancePolicyParticipants = new List<InsurancePolicyParticipant>();
    for(String roleType : participantsTypes)
    {
      InsurancePolicyParticipant policyParticipant = new InsurancePolicyParticipant();

      policyParticipant.InsurancePolicyId = insurancePolicy.Id;
      policyParticipant.AW_FirstName__c = CMN_DAL_SObjectDomain.generateRandomName();
      policyParticipant.AW_LastName__c = CMN_DAL_SObjectDomain.generateRandomName();
      policyParticipant.Role = roleType;
      createdInsurancePolicyParticipants.add(policyParticipant);
    }
    return createdInsurancePolicyParticipants;
  }

  /**
   * @description Method to create and return the record of Financial Account Role
   *
   * @param financialAccount To store the record of Financial Account Role
   * @param participantsTypes Type of Roles store in a set of string
   *
   * @return List of Financial Account Role
   */
  @TestVisible
  private static List<FinServ__FinancialAccountRole__c> createFinancialAccountRoles(FinServ__FinancialAccount__c financialAccount, Set<String> participantsTypes)
  {
    List<FinServ__FinancialAccountRole__c> createdFinancialAccountRoles = new List<FinServ__FinancialAccountRole__c>();
    for(String roleType : participantsTypes)
    {
      FinServ__FinancialAccountRole__c financialAccountRole = new FinServ__FinancialAccountRole__c();

      financialAccountRole.FinServ__FinancialAccount__c = financialAccount.Id;
      financialAccountRole.AW_RoleFirstName__c = CMN_DAL_SObjectDomain.generateRandomName();
      financialAccountRole.AW_RoleLastName__c = CMN_DAL_SObjectDomain.generateRandomName();
      financialAccountRole.FinServ__Role__c = roleType;
      financialAccountRole.FinServ__Active__c = true;
      createdFinancialAccountRoles.add(financialAccountRole);
    }
    return createdFinancialAccountRoles;
  }
	
	/**
   * @description Method to create and return the instance of Case Comments
   *
   * @param numberOfComments The number of records to be created
   * @param caseToLink The case to be linked with caseComments
   *
   * @return List of Case Comments
   */
  @TestVisible
  private static List<CMN_CaseComment__c> createCaseComments(Integer numberOfComments, Id caseToLink)
  {
    List<CMN_CaseComment__c> newComments = new List<CMN_CaseComment__c>();

    for(Integer i = 0; i < numberOfComments; i++)
    {
      CMN_CaseComment__c newCaseComment = new CMN_CaseComment__c();
      newCaseComment.CMN_ExternalCommentId__c = CMN_DAL_SObjectDomain.generateRandomNumber();
      newCaseComment.CMN_Case__c = caseToLink;
      newCaseComment.CMN_Comment__c = CMN_DAL_SObjectDomain.generateRandomDescription();
      newComments.add(newCaseComment);
    }

    return newComments;
  }

  /**
   * @description Method to create and return the record of Case Comments
   *
   * @param numberOfComments The number of records to be created
   * @param caseToLink The case to be linked with caseComments
   *
   * @return List of Case Comments
   */
  @TestVisible
  private static List<CMN_CaseComment__c> insertCaseComments(Integer numberOfComments, Id caseToLink)
  {
    List<CMN_CaseComment__c> newComments = createCaseComments(numberOfComments, caseToLink);
    insert newComments;

    return newComments;
  }
}