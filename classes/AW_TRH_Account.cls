/**
 * @description Trigger handler for the Account Object
 *
 * @see AW_TRH_Account_TEST @story ST-821
 *
 * @author pavan.thammali@liberty.co.za vishakha.saini@accenture.com
 *
 * @date 2019, March 2023
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity')
public inherited sharing class AW_TRH_Account extends CMN_TRH_BaseObject
{
	private AW_AccountOwnerConfig__mdt masterAccountOwnerConfiguration;
	private AW_FeatureSwitches__c switches;
	private Id businessAccountRecordTypeId;
	private Id personAccountRecordTypeId;
	private Map<Id, AW_Country__c> countriesById = new Map<Id, AW_Country__c>();
	private Map<Id, User> mapUsers = new Map<Id, User>();
	private Map<String, SObject> skfToMasterAccountMap = new Map<String, SObject>();
	private Set<Id> adviserAccountRecordTypes;
	private Set<Id> masterAccountRecordTypes;
	private Set<String> fieldsToCheckForChanges;
	private User masterAccountOwner;
	private final List<Account> newAccounts = Trigger.new;
	private final List<CMN_WebserviceCallQueue__c> queueItemsToInsert = new List<CMN_WebserviceCallQueue__c>();
	private final List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
	private final List<SObject> updatedRelatedRecordsSet = new List<SObject>();
	private final List<Task> tasksToUpdate = new List<Task>();
	private final Map<Id, Opportunity> mapLeadIdAndOpportunity = new Map<Id, Opportunity>();
	private static final AW_Country__c COUNTRY_SOUTH_AFRICA = AW_DAL_Country.findByName(AW_DAL_Country.SOUTH_AFRICA);
	private static final Integer CLOSE_DATE_NUMBER_OF_MONTHS = 2;
	private static final String ERROR_INVALID_ID = 'The identification number is incorrect.';

	@TestVisible
	private static final Set<String> SUPPORTED_CHILD_RELATIONSHIPS = new Set<String>
	{
			'AW_PersonLifeEvents__r',
			'BusinessMilestones',
			'Cases',
			'Emails',
			'Envelopes__r',
			'FNA__r',
			'FinServ__ClientAssetsAndLiabilities__r',
			'FinServ__ClientFinancialAccounts__r',
			'FinServ__ClientFinancialGoals__r',
			'InsurancePolicies',
			'Opportunities',
			'Outstanding_Requirements__r'
	};

	/**
	 * @description Sets variables used in various methods to ensure code is bulkified
	 */
	private void populateCommonVariables()
	{
		personAccountRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, AW_DAL_Account.RT_PERSON_ACCOUNT);
		businessAccountRecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, AW_DAL_Account.RT_BUSINESS_ACCOUNT);
		adviserAccountRecordTypes = new Set<Id>
		{
				personAccountRecordTypeId, businessAccountRecordTypeId
		};

		switches = AW_DAL_FeatureSwitches.getFeatureSwitch(UserInfo.getUserId());

		if(Trigger.isBefore && Trigger.isInsert)
		{
			//To be used to check if a master account is created so that the owner can be set
			masterAccountRecordTypes = new Set<Id>();
			for(String recordTypeName : AW_DAL_Account.MASTER_ACCOUNT_RECORDTYPE_NAMES)
			{
				masterAccountRecordTypes.add(CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, recordTypeName));
			}

			masterAccountOwnerConfiguration = AW_DAL_AccountOwnerConfig.findMasterAccountOwnerInfo();
			if(masterAccountOwnerConfiguration != null && String.isNotBlank(masterAccountOwnerConfiguration.AW_UserId__c))
			{
				masterAccountOwner = AW_DAL_User.findById(CMN_UTIL_String.validateId(masterAccountOwnerConfiguration.AW_UserId__c));
			}
		}
	}

	/**
	 * @description Before trigger will look to link child records to existing parent records
	 * It will also close some tasks on account owner change
	 */
	public override void bulkBefore()
	{
		super.bulkBefore();

		populateCommonVariables();

		if(Trigger.isInsert || Trigger.isUpdate)
		{
			Set<String> skfIdsForAccountsToLinkToMaster = new Set<String>();
			Set<Id> accountsToCheckForOrphans = new Set<Id>();
			Set<Id> countryIds = new Set<Id>();
			Set<Id> setUserIds = new Set<Id>();

			for(Account newAccount : newAccounts)
			{
				if(adviserAccountRecordTypes.contains(newAccount.RecordTypeId) &&
						(String.isNotBlank(newAccount.AW_IdentificationNumber__pc) ||
								String.isNotBlank(newAccount.AW_CompanyRegistrationTrustNumber__c)))
				{
					setUserIds.add(newAccount.OwnerId);
				}

				if(String.isNotBlank(newAccount.AW_PassportCountryOfIssue__pc) && adviserAccountRecordTypes.contains(newAccount.RecordTypeId))
				{
					countryIds.add(newAccount.AW_PassportCountryOfIssue__pc);
				}

				if(Trigger.isUpdate)
				{
					Account oldAccount = (Account)Trigger.oldMap.get(newAccount.Id);
					if
					(
							newAccount.FinServ__Status__c != oldAccount.FinServ__Status__c &&
									AW_DAL_Account.STATUS_ACTIVE.equalsIgnoreCase(newAccount.FinServ__Status__c) &&
									newAccount.AW_ParentAccount__c == null &&
									adviserAccountRecordTypes.contains(newAccount.RecordTypeId) &&
									String.isNotBlank(newAccount.AW_SKF_Id__c)
					)
					{
						skfIdsForAccountsToLinkToMaster.add(newAccount.AW_SKF_Id__c);
					}
					if(newAccount.OwnerId != oldAccount.OwnerId)
					{
						accountsToCheckForOrphans.add(newAccount.Id);
					}
				}
			}

			if(!setUserIds.isEmpty())
			{
				mapUsers = new Map<Id, User>(AW_DAL_User.findById(setUserIds));
			}

			if(!countryIds.isEmpty())
			{
				countriesById = new Map<Id, AW_Country__c>(AW_DAL_Country.findById(countryIds));
			}

			if(Trigger.isUpdate && !accountsToCheckForOrphans.isEmpty())
			{
				//Whenever a related task has the task category orphan and the label 'Change of Consultant form', close the task.
				for(Task openTask : AW_DAL_Task.findOpenOrphanedTasks(accountsToCheckForOrphans))
				{
					openTask.Status = AW_DAL_Task.STATUS_COMPLETED;
					openTask.AW_Change_of_Consultant_Form__c = AW_DAL_Task.CHANGE_OF_CONSULTANT_FORM_STATUS_COMPLETED;

					tasksToUpdate.add(openTask);
				}
			}

			if(!skfIdsForAccountsToLinkToMaster.isEmpty())
			{
				List<Account> masterAccounts = AW_DAL_Account.findMasterBySkfId(skfIdsForAccountsToLinkToMaster);
				skfToMasterAccountMap = CMN_UTIL_System.convertListToSingleStringMap(masterAccounts, Account.AW_SKF_Id__c.getDescribe().getLocalName());
			}
		}
	}

	/**
	 * @description Context method overrides will be called before insertion of Object. .
	 *
	 * @param so New SObject record
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);

		Account newAccount = (Account)so;

		setSourceSystemId(null, newAccount);

		if(newAccount.RecordTypeId == personAccountRecordTypeId)
		{
			Boolean validAccount = validateAndProcessSouthAfricanIdentityNumber(null, newAccount);

			if(validAccount)
			{
				//This code ensures that during lead conversion  to a person account we set the birthdate using a custom field
				//This is due to issue where Salesforce only converts Standard Lead fields to Standard Contact Fields
				if(newAccount.AW_Birthdate_for_Lead_Conversion__pc != null && newAccount.PersonBirthdate == null)
				{
					newAccount.PersonBirthdate = newAccount.AW_Birthdate_for_Lead_Conversion__pc;
				}

				setReviewMonth(newAccount);
			}
		}

		//Set owner correctly for master accounts
		if(masterAccountOwner != null && masterAccountRecordTypes.contains(newAccount.RecordTypeId))
		{
			newAccount.OwnerId = masterAccountOwner.Id;
		}
	}

	/**
	 * @description Context method overrides will be called before update of Object.
	 *
	 * @param oldSo Old SObject record
	 * @param so New SObject record
	 */
	public override void beforeUpdate(SObject oldSo, SObject so)
	{
		super.beforeUpdate(oldSo, so);

		Account oldAccount = (Account)oldSo;
		Account newAccount = (Account)so;

		setSourceSystemId(oldAccount, newAccount);

		if(newAccount.RecordTypeId == personAccountRecordTypeId)
		{
			Boolean validAccount = validateAndProcessSouthAfricanIdentityNumber(oldAccount, newAccount);

			if(validAccount)
			{
				setReviewMonth(newAccount);
			}
		}
		if(String.isNotBlank(newAccount.AW_SKF_Id__c) && !skfToMasterAccountMap.isEmpty())
		{
			AW_DAL_Account.copyAccountData((Account)skfToMasterAccountMap.get(newAccount.AW_SKF_Id__c), newAccount);
		}
	}

	/**
	 * @description After trigger code processes parent records (i.e. link or unlink child records)
	 */
	public override void bulkAfter()
	{
		super.bulkAfter();

		populateCommonVariables();

		if(Trigger.isUpdate || Trigger.isInsert)
		{

			fieldsToCheckForChanges = new Set<String>();

			//dynamically get the fields from the field set and then use the same for comparison in the trigger.
			Map<String, Schema.FieldSet> fieldSetMap = CMN_UTIL_SObjectDescribe.getDescribe(Account.SObjectType).getFieldSetsMap();

			if(!fieldSetMap.isEmpty())
			{
				FieldSet itemsToCheck = fieldSetMap.get(AW_DAL_Account.FIELDSET_PROSPECT);

				if(itemsToCheck != null)
				{
					fieldsToCheckForChanges = new Set<String>();

					for(FieldSetMember fields : itemsToCheck.getFields())
					{
						fieldsToCheckForChanges.add(fields.getFieldPath());
					}
				}
			}

			Map<String, Account> mapNationalIdAndProspectAccount = new Map<String, Account>();
			Map<String, String> mapNationalIDAndAdvisorId = new Map<String, String>();

			Set<Id> accountIds = new Set<Id>();
			Set<Id> setUserIds = new Set<Id>();

			for(Account newAccount : newAccounts)
			{
				if(Trigger.isUpdate)
				{
					Account oldAccount = (Account)Trigger.oldMap.get(newAccount.Id);
					if
					(
							AW_DAL_Account.STATUS_ACTIVE.equalsIgnoreCase(newAccount.FinServ__Status__c) &&
									adviserAccountRecordTypes.contains(newAccount.RecordTypeId) &&
									newAccount.AW_ParentAccount__c != null &&
									newAccount.AW_ParentAccount__c != oldAccount.AW_ParentAccount__c
					)
					{
						accountIds.add(newAccount.Id);
					}
				}

				//filtering prospect accounts with identification number
				if(AW_DAL_Account.STATUS_PROSPECT.equalsIgnoreCase(newAccount.FinServ__Status__c) &&
						String.isNotBlank(newAccount.AW_IdentificationNumber__pc) &&
						newAccount.RecordTypeId == personAccountRecordTypeId)
				{
					mapNationalIdAndProspectAccount.put(newAccount.AW_IdentificationNumber__pc, newAccount);
					mapNationalIDAndAdvisorId.put(newAccount.AW_IdentificationNumber__pc, newAccount.OwnerId);
				}

				setUserIds.add(newAccount.OwnerId);
				setUserIds.add(newAccount.LastModifiedById);
			}

			// link related records to the master account
			if(Trigger.isUpdate && !accountIds.isEmpty())
			{
				List<Account> activeAccounts = AW_DAL_Account.findByIdWithRelatedObjects(accountIds);

				Set<Id> personContactIds = new Set<Id>();

				for(Account editAccount : activeAccounts)
				{
					if(editAccount.AW_ParentAccount__c != null)
					{
						for(String relatedObject : SUPPORTED_CHILD_RELATIONSHIPS)
						{
							if(editAccount.getSObjects(relatedObject) != null && !editAccount.getSObjects(relatedObject).isEmpty()) //NOPMD
							{
								updatedRelatedRecordsSet.addAll(setMasterAccountLookup(editAccount.getSObjects(relatedObject), editAccount.AW_ParentAccount__c));
							}
						}
						personContactIds.add(editAccount.PersonContactId);
					}
				}

				if(!personContactIds.isEmpty())
				{
					List<Contact> personContacts = AW_DAL_Contact.findByIdWithChildDetails(personContactIds);
					for(Contact personContact : personContacts)
					{
						if(personContact.Account.AW_ParentAccount__c != null) //NOPMD
						{
							updatedRelatedRecordsSet.addAll(setMasterAccountLookup(personContact.PersonLifeEvents, personContact.Account.AW_ParentAccount__c));
						}
					}
				}
			}

			// convert related leads to opportunity
			fetchLeadsToBeConverted(mapNationalIdAndProspectAccount, mapNationalIDAndAdvisorId);

			mapUsers = new Map<Id, User>(AW_DAL_User.findById(setUserIds));
		}
	}

	/**
	 * @description Context method overrides will be called after insertion of Object.
	 *
	 * @param so New SObject record
	 */
	public override void afterInsert(SObject so)
	{
		super.afterInsert(so);
		notifyExternalSystemsOfClientChange((Account)so);
	}

	/**
	 * @description Context method overrides will be called after undelete of Object.
	 *
	 * @param so New SObject record
	 */
	public override void afterUndelete(SObject so)
	{
		super.afterUndelete(so);
		afterInsert(so);
	}

	/**
	 * @description Context method overrides will be called after update of Object.
	 *
	 * @param oldSo Old SObject record
	 * @param so New SObject record
	 */
	public override void afterUpdate(SObject oldSo, SObject so)
	{
		super.afterUpdate(oldSo, so);
		notifyExternalSystemsOfClientChange((Account)so);
	}

	/**
	 * @description Context method overrides will be called after the end of trigger executions .
	 */
	public override void andFinally()
	{
		CMN_DAL_SObjectDomain.insertDBObjects(queueItemsToInsert);
		CMN_DAL_SObjectDomain.updateDatabase(updatedRelatedRecordsSet, CMN_DAL_SObjectDomain.DatabaseOperation.DBO_UPDATE, true, true, false, true);
		CMN_DAL_SObjectDomain.updateDBObjects(tasksToUpdate);

		// convert related leads to opportunity
		if(!leadConverts.isEmpty())
		{
			//insert opportunities then opportunity id can be used while lead conversion
			if(!mapLeadIdAndOpportunity.isEmpty())
			{
				CMN_DAL_SObjectDomain.insertDBObjects(mapLeadIdAndOpportunity.values());
			}

			//set the related opportunity ids.
			for(Database.LeadConvert objLeadConvert : leadConverts)
			{
				Opportunity opportunityObj = mapLeadIdAndOpportunity.get(objLeadConvert.getLeadId());
				objLeadConvert.setOpportunityId(opportunityObj.Id);
			}

			Database.convertLead(leadConverts);
		}
	}

	/**
	 * @description This ensures that the review month is set to the Date of Birth if the Date Of Birth is now Blank  and Review Month is Blank
	 *
	 * @param newAccount New Account record
	 */
	private static void setReviewMonth(Account newAccount)
	{
		if(String.isBlank(newAccount.AW_ReviewMonth__pc) && newAccount.PersonBirthdate != null)
		{
			newAccount.AW_ReviewMonth__pc = CMN_UTIL_Date.monthNameFromDate(newAccount.PersonBirthdate);
		}
	}

	/**
	 * @description Method will check to see if this account has a valid ID (if not it sets and Error)
	 * If the ID is valid then it will set the Date of Birth and Gender
	 *
	 * @param oldAccount Old Account record
	 * @param newAccount New Account record
	 *
	 * @return A flag indicating whether this account has a valid ID. The ID is only checked under certain circumstances
	 */
	private Boolean validateAndProcessSouthAfricanIdentityNumber(Account oldAccount, Account newAccount)
	{
		Boolean validIdNumber = true;

		Boolean identityIsNotBlank = String.isNotBlank(newAccount.AW_IdentificationNumber__pc);
		Boolean identityHasChanged = oldAccount == null ? true : newAccount.AW_IdentificationNumber__pc != oldAccount.AW_IdentificationNumber__pc;
		Boolean identityTypeHasChanged = oldAccount == null ? true : newAccount.AW_IdentificationType__pc != oldAccount.AW_IdentificationType__pc;
		Boolean isSouthAfricanIdentityNumber = AW_DAL_Account.PICK_SA_ID_TYPE.equalsIgnoreCase(newAccount.AW_IdentificationType__pc);

		if(identityIsNotBlank && isSouthAfricanIdentityNumber && (identityHasChanged || identityTypeHasChanged))
		{
			if(AW_UTIL_IdentityNumber.isValidIdentityNumber(newAccount.AW_IdentificationNumber__pc))
			{
				newAccount.PersonBirthdate = AW_UTIL_IdentityNumber.extractDateOfBirthFromIdentityNumber(newAccount.AW_IdentificationNumber__pc);
				newAccount.FinServ__Gender__pc = AW_UTIL_IdentityNumber.getGenderFromIdentityNumber(newAccount.AW_IdentificationNumber__pc);
			}
			else if(newAccount.AW_BypassValidationRules__c != true && switches.AW_DisableAccountValidationRules__c == false)
			{
				newAccount.AW_IdentificationNumber__pc.addError(ERROR_INVALID_ID);
				validIdNumber = false;
			}
		}
		// bug #117358

		if(AW_DAL_Account.PICK_SA_ID_TYPE.equalsIgnoreCase(newAccount.AW_IdentificationType__pc) &&
				((newAccount.AW_Nationality__c == null && newAccount.AW_Country_Of_Birth__c == null) ||
						(newAccount.AW_Nationality__c != null && newAccount.AW_Country_Of_Birth__c == null) ||
						(newAccount.AW_Nationality__c == null && newAccount.AW_Country_Of_Birth__c != null)))
		{
			newAccount.CMN_SAResidentIndicator__c = SC_DAL_Account.STATUS_RESIDENT_YES;
			newAccount.AW_Nationality__c = newAccount.AW_Nationality__c == null ? COUNTRY_SOUTH_AFRICA?.Id : newAccount.AW_Nationality__c;
			newAccount.AW_Country_Of_Birth__c = newAccount.AW_Country_Of_Birth__c == null ? COUNTRY_SOUTH_AFRICA?.Id : newAccount.AW_Country_Of_Birth__c;
		}
		else if(AW_DAL_Account.PICK_PASSPORT_TYPE.equalsIgnoreCase(newAccount.AW_IdentificationType__pc) &&
				newAccount.AW_Nationality__c == null && newAccount.AW_Country_Of_Birth__c == null)
		{
			newAccount.CMN_SAResidentIndicator__c = newAccount.CMN_SAResidentIndicator__c == SC_DAL_Account.STATUS_RESIDENT_YES ?
					SC_DAL_Account.STATUS_RESIDENT_YES : SC_DAL_Account.STATUS_RESIDENT_NO;
			newAccount.AW_Nationality__c = newAccount.AW_PassportCountryOfIssue__pc;
			newAccount.AW_Country_Of_Birth__c = newAccount.AW_PassportCountryOfIssue__pc;

		}//bug #117358
		if(identityIsNotBlank == false)
		{
			newAccount.AW_IdentificationType__pc = null;
		}

		return validIdNumber;
	}

	public override Boolean allowRecursion()
	{
		return false;
	}

	/**
	 * @description Whenever an prospect account is created or updated, call the webservice to sync the modified record
	 *                   with the external systems.
	 *
	 * @param newAccount The newly updated account
	 */
	private void notifyExternalSystemsOfClientChange(Account newAccount)
	{
		User accountOwner = mapUsers.get(newAccount.OwnerId);
		User accountModifier = mapUsers.get(newAccount.LastModifiedById);
		if(
				newAccount.RecordTypeId == personAccountRecordTypeId &&
						String.isNotBlank(newAccount.AW_IdentificationNumber__pc) &&
						String.isNotBlank(accountOwner.AW_UACFID__c) &&
						String.isNotBlank(accountOwner.AW_ConsultantCode__c) &&
						(
								AW_DAL_Profile.PROFILE_ADVISER.equalsIgnoreCase(accountOwner.Profile.Name) ||
										AW_DAL_Profile.PROFILE_SALES_LEADER.equalsIgnoreCase(accountOwner.Profile.Name) ||
										AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(accountOwner.Profile.Name)

						) &&
						!AW_DAL_Profile.PROFILE_LIBERTY_SERVICE_ACCOUNT.equalsIgnoreCase(accountModifier.Profile.Name))
		{

			Boolean hasChanged = Trigger.isInsert || Trigger.isUndelete;

			if(Trigger.isUpdate && fieldsToCheckForChanges != null)
			{
				for(String fieldSet : fieldsToCheckForChanges)
				{
					if(newAccount.get(fieldSet) != Trigger.oldMap.get(newAccount.Id).get(fieldSet))
					{
						hasChanged = true;
						break;
					}
				}
			}

			if(hasChanged)
			{
				queueItemsToInsert.add(CMN_DAL_DataFactory.newOutboundWebserviceQueue(AW_API_RestOutboundClientUpdated.SERVICE_NAME, newAccount.Id));
			}
		}
	}

	/**
	 * @description Will copy Master Account Id on an SObject
	 *
	 * @param sobjects List of SObject
	 * @param masterAccountId Id of the parent account
	 *
	 * @return List of updated SObject
	 */
	private static List<SObject> setMasterAccountLookup(List<SObject> sobjects, Id masterAccountId)
	{
		if(!sobjects.isEmpty() && masterAccountId != null)
		{
			for(SObject anObject : sobjects)
			{
				anObject.put(AW_DAL_Account.FIELD_MASTER_ACCOUNT_LOOKUP, masterAccountId);
			}
		}

		return sobjects;
	}

	/**
	 * @description fetch leads to be converted & prepare list of leads with required information for conversion
	 *
	 * @param mapNationalIdAndProspectAccount Map of National Id & Prospect Account
	 * @param mapNationalIDAndAdvisorId Map of National Id & Adviser Id
	 */
	private void fetchLeadsToBeConverted(Map<String, Account> mapNationalIdAndProspectAccount, Map<String, String> mapNationalIDAndAdvisorId)
	{
		List<Lead> listLeadsToConvert = new List<Lead>();
		Set<String> listNationalIds = mapNationalIDAndAdvisorId.keySet();

		if(!mapNationalIdAndProspectAccount.isEmpty())
		{
			//fetching list of leads which needs to be converted
			listLeadsToConvert = AW_DAL_Lead.findByIdentificationNumberAndOwner(listNationalIds, mapNationalIDAndAdvisorId.values());

			//preparing leads with required data for conversion
			for(Lead objLead : listLeadsToConvert)
			{
				Account objAccount = mapNationalIdAndProspectAccount.get(objLead.AW_IdentificationNumber__c);
				if(objLead.OwnerId == objAccount.OwnerId)
				{
					Opportunity opportunityObj = new Opportunity();

					String opportunityName = (String.isNotBlank(objLead.AW_ProductInterest__c) ?
							(String.isNotBlank(objLead.AW_SubProductInterest__c) ?
									objLead.AW_ProductInterest__c + ' ' + objLead.AW_SubProductInterest__c
									: objLead.AW_ProductInterest__c)
							: objLead.Name);

					opportunityObj.Name = opportunityName;
					opportunityObj.StageName = AW_DAL_Opportunity.OPPORTUNITY_STAGE_QUALIFIED;
					opportunityObj.CloseDate = Date.today().addMonths(CLOSE_DATE_NUMBER_OF_MONTHS);
					opportunityObj.OwnerId = objLead.OwnerId;
					opportunityObj.AccountId = objAccount.Id;

					mapLeadIdAndOpportunity.put(objLead.Id, opportunityObj);

					Database.LeadConvert objLeadConvert = new Database.LeadConvert();
					objLeadConvert.setLeadId(objLead.Id);
					objLeadConvert.setConvertedStatus(AW_DAL_Lead.STATUS_CONVERTED);
					objLeadConvert.setAccountId(objAccount.Id);
					objLeadConvert.setContactId(objAccount.PersonContactId);

					leadConverts.add(objLeadConvert);
				}
			}
		}
	}
	/**
	 * @description Whenever an prospect or business account is created or updated, the modified record
	 *                   updates the source system ID.
	 *
	 * @param oldAccount Old Account
	 * @param newAccount New Account
	 */
	private void setSourceSystemId(Account oldAccount, Account newAccount)
	{
		User accountOwner = mapUsers.get(newAccount.OwnerId);

		if(adviserAccountRecordTypes.contains(newAccount.RecordTypeId) && // Check record type id for ring-fencing
				String.isNotBlank(accountOwner?.AW_UACFID__c) &&
				(String.isNotBlank(newAccount.AW_IdentificationNumber__pc) ||
						String.isNotBlank(newAccount.AW_CompanyRegistrationTrustNumber__c)) &&
				// Check if relevant fields have been updated
				(oldAccount == null ||
						newAccount.AW_IdentificationNumber__pc != oldAccount.AW_IdentificationNumber__pc ||
						newAccount.AW_CompanyRegistrationTrustNumber__c != oldAccount.AW_CompanyRegistrationTrustNumber__c ||
						newAccount.OwnerId != oldAccount.OwnerId ||
						newAccount.AW_PassportCountryOfIssue__pc != oldAccount.AW_PassportCountryOfIssue__pc) &&
				// Check if user with relevant profile is the account owner
				(AW_DAL_Profile.PROFILE_ADVISER.equalsIgnoreCase(accountOwner?.Profile.Name) ||
						AW_DAL_Profile.PROFILE_SALES_LEADER.equalsIgnoreCase(accountOwner?.Profile.Name) ||
						AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(accountOwner?.Profile.Name))
		)
		{
			String countryCode = CMN_UTIL_String.EMPTY;
			String sourceSystemId;

			if(String.isNotBlank(newAccount.AW_PassportCountryOfIssue__pc))
			{
				AW_Country__c country = countriesById.get(newAccount.AW_PassportCountryOfIssue__pc);
				countryCode = String.valueOf(country.AW_CountryCode__c);
			}

			if(newAccount.RecordTypeId == personAccountRecordTypeId)
			{
				sourceSystemId = newAccount.AW_IdentificationNumber__pc + countryCode + accountOwner.AW_UACFID__c;
			}
			else if(newAccount.RecordTypeId == businessAccountRecordTypeId)
			{
				sourceSystemId = newAccount.AW_CompanyRegistrationTrustNumber__c + accountOwner.AW_UACFID__c;
			}

			newAccount.FinServ__SourceSystemId__c = sourceSystemId;
			newAccount.FinServ__SourceSystemId__pc = sourceSystemId;
		}
		else if(newAccount.RecordTypeId == businessAccountRecordTypeId && String.isBlank(newAccount.AW_CompanyRegistrationTrustNumber__c))
		{
			newAccount.FinServ__SourceSystemId__c = null;
			newAccount.FinServ__SourceSystemId__pc = null;
		}
	}
}