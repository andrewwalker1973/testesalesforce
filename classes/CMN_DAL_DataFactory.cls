/**
 * @description Used to create Data, mostly for unit tests
 *
 * @author darrion.james.singh@accenture.com latika.kharbanda@accenture.com
 *
 * @date 2020, November 2022
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ApexCRUDViolation, PMD.ExcessiveClassLength')
public without sharing class CMN_DAL_DataFactory
{
	@TestVisible
	private static final Integer NUMBER_HEADERS_AND_ATTACHMENTS_TO_CREATE = 10;
	@TestVisible
	private static final Integer NUMBER_OF_ACTIVE_USERS_TO_RETRIEVE = 3;
	private static final String DEFAULT_CHRON_EXPRESSION = '0 0 * * * ?';
	private static final String DUMMY_FILE_PATH = '/dummy/local/directory/';
	private static final String FULL_MONTH_DATE_FORMAT = 'MMMMM';
	private static final String TEXT_FILE_EXTENSION = '.txt';

	/**
	 * @description Will create feature switch that indicates a particular API should be disabled for the running user
	 *
	 * @param apiName The class name of the API to disable
	 */
	@TestVisible
	private static void disableAPI(String apiName)
	{
		CMN_FeatureSwitches__c newSwitch = CMN_FeatureSwitches__c.getInstance();
		newSwitch.CMN_APIsToDisableList1__c = apiName;

		upsert newSwitch;
	}

	/**
	 * @description Will create feature switch that indicates a particular API should be mocked for the running user
	 *
	 * @param apiName The class name of the API to Mock
	 */
	@TestVisible
	private static void mockAPI(String apiName)
	{
		CMN_FeatureSwitches__c newSwitch = CMN_FeatureSwitches__c.getInstance();
		newSwitch.CMN_APIsToMockList1__c = apiName;

		upsert newSwitch;
	}

	/**
	 * @description Will Create feature custom setting and upsert it
	 *
	 * @param setupOwnerId The owner of the custom setting
	 */
	@TestVisible
	private static void createFeatureSwitch(Id setupOwnerId)
	{
		CMN_FeatureSwitches__c newSwitch = CMN_FeatureSwitches__c.getInstance();

		newSwitch.SetupOwnerId = setupOwnerId;

		newSwitch.CMN_DisableAllOutboundAPICalls__c = false;
		newSwitch.CMN_MockAllOutboundAPICalls__c = false;

		upsert newSwitch;
	}

	/**
	 * @description This method is use to create new record in Custom Setting newSpcUsersToEnable
	 *
	 * @param name Setting Name
	 * @param profileName Profile Name for Setting
	 * @param userName User Name for Setting
	 *
	 * @return A new Custom Setting Row
	 */
	@TestVisible
	private static CMN_SPC_UsersToEnable__c newSpcUsersToEnable(String name, String profileName, String userName)
	{
		CMN_SPC_UsersToEnable__c newUsersToEnable = new CMN_SPC_UsersToEnable__c();

		newUsersToEnable.Name = name;

		newUsersToEnable.CMN_SPC_EnableProfileName__c = profileName;
		newUsersToEnable.CMN_SPC_EnableUsername__c = userName;

		return newUsersToEnable;
	}

	/**
	 * @description Will create a row in the custom setting CMN_TriggersToDisable__c, thereby disabling said trigger
	 *
	 * @param triggerName The name of the trigger to disable
	 */
	@TestVisible
	private static void disableTrigger(String triggerName)
	{
		CMN_TriggersToDisable__c newTriggersToDisable = new CMN_TriggersToDisable__c();

		newTriggersToDisable.Name = triggerName;
		newTriggersToDisable.CMN_ClassName__c = triggerName;

		insert newTriggersToDisable;
	}

	/**
	 * @description This method is use to get the user with profile
	 *
	 * @param profileName The profile that should be linked to the new user
	 *
	 * @return A user that's not inserted
	 */
	public static User newUser(String profileName)
	{
		User newUser = new User();

		newUser.ProfileId = CMN_DAL_Profile.findByName(profileName).Id;

		newUser.Username = CMN_DAL_SObjectDomain.generateRandomEmail();
		newUser.Email = newUser.Username.toLowerCase();
		newUser.FederationIdentifier = newUser.Email;
		newUser.LastName = CMN_DAL_SObjectDomain.generateRandomName();
		newUser.FirstName = CMN_DAL_SObjectDomain.generateRandomName();
		newUser.Alias = CMN_DAL_SObjectDomain.generateRandomName().substring(0, 7);
		newUser.CommunityNickname = CMN_DAL_SObjectDomain.generateRandomName();

		User currentUser = CMN_DAL_User.getCurrentUser();

		newUser.TimeZoneSidKey = currentUser.TimeZoneSidKey;
		newUser.LocaleSidKey = currentUser.LocaleSidKey;
		newUser.EmailEncodingKey = currentUser.EmailEncodingKey;
		newUser.LanguageLocaleKey = currentUser.LanguageLocaleKey;

		newUser.MobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();

		newUser.IsActive = true;

		return newUser;
	}

	/**
	 * @description Will insert a list of users with particular profileName
	 *
	 * @param profileName The profile that should be linked to the new user
	 * @param numberOfUsers The number of Users to create
	 *
	 * @return A list of committed user
	 */
	@TestVisible
	private static List<User> insertUsers(String profileName, Integer numberOfUsers)
	{
		List<User> newUsers = new List<User>();

		for(Integer i = 0; i < numberOfUsers; i++)
		{
			newUsers.add(newUser(profileName));
		}

		insert newUsers;
		return newUsers;
	}

	/**
	 * @description Will create an account and set's it record type based on developer name
	 *
	 * @return A new account (uncommitted)
	 */
	public static Account newAccount()
	{
		Account newAccount = new Account();

		newAccount.AnnualRevenue = CMN_DAL_SObjectDomain.generateRandomDecimal();
		newAccount.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();

		return newAccount;
	}

	/**
	 * @description Method is use return the new Business Account
	 *
	 * @return A new account (uncommitted)
	 */
	public static Account newBusinessAccount()
	{
		Account newAccount = newAccount();
		return newAccount;
	}

	/**
	 * @description Method is use insert a new Business Account (Can Use this method in Test class)
	 *
	 * @return a new account (committed)
	 */
	@TestVisible
	private static Account insertBusinessAccount()
	{
		Account newAccount = newBusinessAccount();

		insert newAccount;

		return newAccount;
	}

	/**
	 * @description Method is use return the a new Contact
	 *
	 * @return newly created Contact, not committed yet
	 */
	public static Contact newContact()
	{
		Contact newContact = new Contact();

		newContact.LastName = CMN_DAL_SObjectDomain.generateRandomName();
		newContact.MobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		newContact.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		newContact.HomePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		newContact.Email = CMN_DAL_SObjectDomain.generateRandomEmail();
		newContact.Birthdate = CMN_DAL_SObjectDomain.generateRandomDate();
		newContact.HasOptedOutOfFax = true;

		return newContact;
	}

	/**
	 * @description Will save email binary attachments as content associated with an Object
	 *
	 * @param linkToObjectId The object against which the attachments should be saved
	 * @param binaryAttachments The binary attachments of an email
	 *
	 * @return Newly created ContentVersion, not inserted
	 */
	public static List<ContentVersion> newContentVersionsFromBinaryAttachments(Id linkToObjectId, List<Messaging.InboundEmail.BinaryAttachment> binaryAttachments)
	{
		List<ContentVersion> newContentVersions = new List<ContentVersion>();

		if(binaryAttachments != null)
		{
			for(Messaging.InboundEmail.BinaryAttachment binaryAttachment : binaryAttachments)
			{
				newContentVersions.add(newContentVersion(linkToObjectId, binaryAttachment.fileName, binaryAttachment.body));
			}
		}

		return newContentVersions;
	}

	/**
	 * @description Will save email text attachments as content associated with an Object
	 *
	 * @param linkToObjectId The object against which the attachments should be saved
	 * @param textAttachments The text attachments of an email
	 *
	 * @return Newly created ContentVersion, not inserted
	 */
	public static List<ContentVersion> newContentVersionsFromTextAttachments(Id linkToObjectId, List<Messaging.InboundEmail.TextAttachment> textAttachments)
	{
		List<ContentVersion> newContentVersions = new List<ContentVersion>();

		if(textAttachments != null)
		{
			for(Messaging.InboundEmail.TextAttachment textAttachment : textAttachments)
			{
				newContentVersions.add(newContentVersion(linkToObjectId, textAttachment.fileName, Blob.valueOf(textAttachment.body)));
			}
		}

		return newContentVersions;
	}

	/**
	 * @description Will create a new Content Version
	 *
	 * @param linkToObjectId To which object should this Content be linked
	 * @param fileName The file name of the Content
	 * @param body The binary body of the content
	 *
	 * @return A newly created item, (not inserted)
	 */
	public static ContentVersion newContentVersion(Id linkToObjectId, String fileName, Blob body)
	{
		ContentVersion newContentVersion = new ContentVersion();

		newContentVersion.FirstPublishLocationId = linkToObjectId;
		newContentVersion.PathOnClient = fileName;
		newContentVersion.Title = fileName;
		newContentVersion.VersionData = body;

		return newContentVersion;
	}

	/**
	 * @description Will generate an inbound email envelope
	 *
	 * @return Email Envelope
	 */
	@TestVisible
	private static Messaging.InboundEnvelope newInboundEnvelope()
	{
		Messaging.InboundEnvelope newEnvelope = new Messaging.InboundEnvelope();

		newEnvelope.fromAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		newEnvelope.toAddress = CMN_DAL_SObjectDomain.generateRandomEmail();

		return newEnvelope;
	}

	/**
	 * @description Will generate an inbound email
	 *
	 * @return Inbound Email
	 */
	@TestVisible
	private static Messaging.InboundEmail newInboundEmail()
	{
		Messaging.InboundEmail newEmail = new Messaging.InboundEmail();

		newEmail.fromAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		newEmail.fromName = CMN_DAL_SObjectDomain.generateRandomName();
		newEmail.subject = CMN_DAL_SObjectDomain.generateRandomDescription();
		newEmail.plainTextBody = CMN_DAL_SObjectDomain.generateRandomDescription();
		newEmail.messageId = CMN_DAL_SObjectDomain.generateRandomNumber();

		newEmail.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
		newEmail.textAttachments = new List<Messaging.InboundEmail.TextAttachment>();
		newEmail.headers = new List<Messaging.InboundEmail.Header>();

		for(Integer i = 0; i < NUMBER_HEADERS_AND_ATTACHMENTS_TO_CREATE; i++)
		{
			Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();

			binaryAttachment.body = Blob.valueOf(CMN_DAL_SObjectDomain.generateRandomDescription());
			binaryAttachment.fileName = DUMMY_FILE_PATH + CMN_DAL_SObjectDomain.generateRandomName() + TEXT_FILE_EXTENSION;
			binaryAttachment.mimeTypeSubType = TEXT_FILE_EXTENSION;

			newEmail.binaryAttachments.add(binaryAttachment);

			Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();

			textAttachment.body = binaryAttachment.body.toString();
			textAttachment.fileName = binaryAttachment.fileName;
			textAttachment.mimeTypeSubType = binaryAttachment.mimeTypeSubType;

			newEmail.textAttachments.add(textAttachment);

			Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();

			header.name = CMN_DAL_SObjectDomain.generateRandomName();
			header.value = CMN_DAL_SObjectDomain.generateRandomName();

			newEmail.headers.add(header);
		}

		return newEmail;
	}

	/**
	 * @description This method is use to get the scheduler class to run the schedule job
	 *
	 * @param schedulerClassName The name of the class to run
	 *
	 * @return a scheduler object not inserted
	 */
	@TestVisible
	private static CMN_JobScheduler__c newJobScheduler(String schedulerClassName)
	{
		CMN_JobScheduler__c scheduler = new CMN_JobScheduler__c();

		scheduler.CMN_Description__c = CMN_DAL_SObjectDomain.generateRandomDescription();
		scheduler.CMN_SchedulerName__c = CMN_DAL_SObjectDomain.generateRandomName();
		scheduler.CMN_ScheduleClassName__c = schedulerClassName;
		scheduler.CMN_CronExpression__c = DEFAULT_CHRON_EXPRESSION;

		return scheduler;
	}

	/**
	 * @description This method is use to insert the object in scheduler class
	 *
	 * @param schedulerClassName The name of the class to run
	 *
	 * @return a newly inserted row
	 */
	@TestVisible
	private static CMN_JobScheduler__c insertJobScheduler(String schedulerClassName)
	{
		CMN_JobScheduler__c scheduler = newJobScheduler(schedulerClassName);

		CMN_DAL_SObjectDomain.insertDBObject(scheduler);

		return scheduler;
	}

	/**
	 * @description This method is use to display Webservice call queue date.
	 *
	 * @return A webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newWebserviceQueue()
	{
		CMN_WebserviceCallQueue__c queueItem = new CMN_WebserviceCallQueue__c();

		queueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_QUEUED;
		queueItem.CMN_Retries__c = 0;

		return queueItem;
	}

	/**
	 * @description This method is use to display Webservice call queue date.
	 *
	 * @param serviceName The name of the webservice class
	 *
	 * @return A webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newWebserviceQueue(String serviceName)
	{
		CMN_WebserviceCallQueue__c queueItem = newWebserviceQueue();

		queueItem.CMN_Service__c = serviceName;

		return queueItem;
	}

	/**
	 * @description This method is use to display Webservice call queue date.
	 *
	 * @param serviceName The name of the webservice class
	 *
	 * @return An inbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newInboundWebserviceQueue(String serviceName)
	{
		CMN_WebserviceCallQueue__c queueItem = newWebserviceQueue(serviceName);

		queueItem.CMN_Type__c = CMN_DAL_WebserviceCallQueue.TYPE_INBOUND;
		queueItem.CMN_StatusCode__c = CMN_UTIL_String.EMPTY;
		queueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_COMPLETED;
		queueItem.CMN_Response__c = CMN_UTIL_String.EMPTY;
		queueItem.CMN_Request__c = RestContext.request?.requestBody != null ? System.RestContext.request.requestBody.toString() : CMN_UTIL_String.EMPTY;
		queueItem.CMN_Errors__c = CMN_UTIL_String.EMPTY;

		return queueItem;
	}

	/**
	 * @description This method is use to get the outbound of webservice call queue.
	 *
	 * @param serviceName The name of the service for this queue item
	 *
	 * @return An outbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName)
	{
		CMN_WebserviceCallQueue__c queueItem = newWebserviceQueue(serviceName);
		queueItem.CMN_Type__c = CMN_DAL_WebserviceCallQueue.TYPE_OUTBOUND;

		return queueItem;
	}

	/**
	 * @description This method is use to get the outbound of webservice call queue.
	 *
	 * @param serviceName The name of the webservice class
	 * @param triggeringObjectId The object that is triggering the service class
	 *
	 * @return An outbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName, Id triggeringObjectId)
	{
		CMN_WebserviceCallQueue__c queueItem = newOutboundWebserviceQueue(serviceName);

		queueItem.CMN_TriggeringObjectId__c = triggeringObjectId;

		return queueItem;
	}

	/**
	 * @description This method is use to get the outbound of webservice call queue.
	 *
	 * @param serviceName The name of the webservice class
	 * @param triggeringObjectId The object that is triggering the service class
	 * @param requestParameters The name/value pair of parameters used in construction of the request
	 *
	 * @return An outbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName, Id triggeringObjectId, Map<String, String> requestParameters)
	{
		CMN_WebserviceCallQueue__c queueItem = newOutboundWebserviceQueue(serviceName, triggeringObjectId);

		CMN_DTO_NameValues dtoNameValues = new CMN_DTO_NameValues(requestParameters);
		queueItem.CMN_Request_Parameters__c = dtoNameValues.items.isEmpty() ? queueItem.CMN_Request_Parameters__c : dtoNameValues.serialize();

		return queueItem;
	}

	/**
	 * @description This method is use to get the outbound of webservice call queue.
	 *
	 * @param serviceName The name of the webservice class
	 * @param triggeringObjectId The object that is triggering the service class
	 * @param parameterName The name of additional parameter to passed to service
	 * @param parameterValue The value of the additional parameter
	 *
	 * @return An outbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName, Id triggeringObjectId, String parameterName, String parameterValue)
	{
		return newOutboundWebserviceQueue(serviceName, triggeringObjectId, new Map<String, String>
		{
				parameterName => parameterValue
		});
	}

	/**
	 * @description Will instantiate a new case with relevant fields filled
	 *
	 * @param contactId The Contact to which this case should be related, can be null
	 *
	 * @return A completed case, note this case is not saved to the database
	 */
	public static Case newCase(Id contactId)
	{
		Case newCase = new Case();

		newCase.Subject = CMN_DAL_SObjectDomain.generateRandomName();
		newCase.Description = CMN_DAL_SObjectDomain.generateRandomDescription();
		newCase.ContactId = contactId;
		newCase.Reason = CMN_DAL_SObjectDomain.generateRandomName();

		return newCase;
	}

	/**
	 * @description Will instantiate a new foo with relevant fields filled
	 *
	 * @return A completed foo, note this foo IS saved to the database
	 */
	public static CMN_Foobar__c insertFoobar()
	{
		CMN_Foobar__c newFoo = newFoobar();
		insert newFoo;
		return newFoo;
	}

	/**
	 * @description Will instantiate a list of items with relevant fields initialised
	 *
	 * @param numberOfItems Number of items to create
	 *
	 * @return A list of items not committed
	 */
	public static List<CMN_Foobar__c> newFoobars(Integer numberOfItems)
	{
		List<CMN_Foobar__c> newItems = new List<CMN_Foobar__c>();

		for(Integer i = 0; i < numberOfItems; i++)
		{
			newItems.add(newFoobar());
		}

		return newItems;
	}

	/**
	 * @description Will instantiate a new foo with relevant fields filled
	 *
	 * @return A completed foo, note this foo is not saved to the database
	 */
	public static CMN_Foobar__c newFoobar()
	{
		CMN_Foobar__c newFoo = new CMN_Foobar__c();

		newFoo.CMN_Checkbox__c = CMN_DAL_SObjectDomain.generateRandomBoolean();
		newFoo.CMN_Datetime__c = CMN_DAL_SObjectDomain.generateRandomDateTime();
		newFoo.CMN_Email__c = CMN_DAL_SObjectDomain.generateRandomEmail();
		newFoo.CMN_NumberInteger__c = CMN_DAL_SObjectDomain.generateRandomInteger(2);
		newFoo.CMN_Phone__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newFoo.CMN_Text__c = CMN_DAL_SObjectDomain.generateRandomDescription();
		newFoo.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newFoo.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(CMN_Foobar__c.SObjectType, CMN_DAL_Foobar.RT_DEFAULT);

		return newFoo;
	}

	/**
	 * @description Will instantiate a new recurring Holiday
	 *
	 * @param aDate The date for the recurring holiday
	 *
	 * @return A completed Holiday, note this Holiday is not saved to the database
	 */
	public static Holiday newRecurringHoliday(Date aDate)
	{
		Holiday newHoliday = new Holiday();
		Datetime aDatetime = Datetime.newInstance(aDate.year(), aDate.month(), aDate.day());

		newHoliday.RecurrenceStartDate = aDate;
		newHoliday.RecurrenceDayOfMonth = aDate.day();
		newHoliday.RecurrenceMonthOfYear = aDatetime.format(FULL_MONTH_DATE_FORMAT);
		newHoliday.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newHoliday.IsAllDay = true;
		newHoliday.IsRecurrence = true;
		newHoliday.RecurrenceType = CMN_DAL_Holiday.PICK_RECURS_YEARLY;

		return newHoliday;
	}

	/**
	 * @description Will create a new (uncommitted) content workspace
	 *
	 * @param name The name to give the content workspace
	 *
	 * @return A content workspace object
	 */
	@TestVisible
	private static ContentWorkspace newContentWorkspace(String name)
	{
		ContentWorkspace library = new ContentWorkspace();
		library.Name = String.isBlank(name) ? CMN_DAL_SObjectDomain.generateRandomName() : name;
		library.DeveloperName = CMN_DAL_SObjectDomain.generateRandomName();
		library.Description = CMN_DAL_SObjectDomain.generateRandomDescription();
		return library;
	}

	/**
	 * @description Will create new (uncommitted) content folders
	 *
	 * @param num Number of folders to create
	 * @param parentFolderId id of parent folder to house the folders
	 *
	 * @return List of content folder objects
	 */
	@TestVisible
	private static List<ContentFolder> newContentFolders(Integer num, Id parentFolderId)
	{
		List<ContentFolder> folders = new List<ContentFolder>();
		for(Integer i = 0; i < num; i++)
		{
			folders.add(newContentFolder(parentFolderId));
		}
		return folders;
	}

	/**
	 * @description Will create a new (uncommitted) content folder
	 *
	 * @return A content folder object
	 */
	@TestVisible
	private static ContentFolder newContentFolder()
	{
		return newContentFolder(CMN_UTIL_String.EMPTY);
	}

	/**
	 * @description Will create a new (uncommitted) content folder
	 *
	 * @param name The name to give the content folder
	 *
	 * @return A content folder object
	 */
	@TestVisible
	private static ContentFolder newContentFolder(String name)
	{
		ContentFolder folder = new ContentFolder();
		folder.Name = String.isBlank(name) ? CMN_DAL_SObjectDomain.generateRandomName() : name;
		return folder;
	}

	/**
	 * @description Will create a new (uncommitted) content folder
	 *
	 * @param parentFolderId The Id of the parent content workspace
	 *
	 * @return A content folder object
	 */
	@TestVisible
	private static ContentFolder newContentFolder(Id parentFolderId)
	{
		ContentFolder fol = newContentFolder();
		fol.ParentContentFolderId = parentFolderId;
		return fol;
	}

	/**
	 * @description Generates new content versions
	 *
	 * @param num number of content versions
	 * @param contentWorkspaceId Id of the library the content versions should be published
	 *
	 * @return List of Content versions
	 */
	@TestVisible
	private static List<ContentVersion> newContentVersions(Integer num, Id contentWorkspaceId)
	{
		List<ContentVersion> contentVersions = new List<ContentVersion>();
		for(Integer i = 0; i < num; i++)
		{
			ContentVersion version = newContentVersion();
			version.FirstPublishLocationId = contentWorkspaceId;
			contentVersions.add(version);
		}
		return contentVersions;
	}

	/**
	 * @description Generates new content version
	 *
	 * @return Content version
	 */
	@TestVisible
	private static ContentVersion newContentVersion()
	{
		return newContentVersion(null);
	}

	/**
	 * @description Generates new content version
	 *
	 * @param title Title of the document
	 *
	 * @return Content version
	 */
	@TestVisible
	private static ContentVersion newContentVersion(String title)
	{
		return newContentVersion(null, String.isBlank(title) ?
				CMN_DAL_SObjectDomain.generateRandomName() : title, Blob.valueOf(CMN_DAL_SObjectDomain.generateRandomDescription()));
	}

	/**
	 * @description Method is use return the a new Object Share Configuration
	 *
	 * @param objectApiName object api name for which sharing is being configured
	 * @param accessLevel access level to set the Apex Share
	 * @param shareFromId Id of the user who is granting access to the records
	 * @param shareWithId Id of the user who should be granted access to the records
	 *
	 * @return newly created Object Share Configuration, not committed yet
	 */
	@TestVisible
	private static CMN_ObjectShareConfiguration__c newObjectShareConfiguration(String objectApiName, String accessLevel, Id shareFromId, Id shareWithId)
	{
		CMN_ObjectShareConfiguration__c objectShare = new CMN_ObjectShareConfiguration__c();

		objectShare.CMN_AccessLevel__c = accessLevel;
		objectShare.CMN_ObjectAPIName__c = objectApiName;
		objectShare.CMN_ShareFrom__c = shareFromId;
		objectShare.CMN_ShareWith__c = shareWithId;

		return objectShare;
	}

	/**
	 * @description Method to return a new share record for the shareObject
	 *
	 * @param dtoShareDescribe A dto containing relevant information about the share object
	 * @param relatedRecordId Record Id for which access needs to be granted
	 * @param accessLevel Access level for share record
	 * @param userOrGroupId User or Group Id to whom access needs to be granted
	 *
	 * @return Newly created Share object record, not committed yet
	 */
	public static SObject newSObjectShare(CMN_DAL_ObjectShare.DTO_ObjectShareDescribe dtoShareDescribe, Id relatedRecordId, String accessLevel, Id userOrGroupId)
	{
		SObject shareObject = dtoShareDescribe.newShareObject();

		shareObject.put(CMN_DAL_ObjectShare.FIELD_ROW_CAUSE, CMN_DAL_ObjectShare.ROW_CAUSE_MANUAL);
		shareObject.put(CMN_DAL_ObjectShare.FIELD_USER_OR_GROUP_ID, userOrGroupId);
		shareObject.put(dtoShareDescribe.accessLevel, accessLevel);
		shareObject.put(dtoShareDescribe.parentIdFieldName, relatedRecordId);

		if(CMN_DAL_ObjectShare.OBJECT_ACCOUNT_SHARE.equalsIgnoreCase(dtoShareDescribe.shareObjectName))
		{
			//NB: The opportunity access level must be set when creating an account share else an exception is thrown
			shareObject.put(CMN_DAL_ObjectShare.FIELD_OPPORTUNITY_ACCESS_LEVEL, CMN_DAL_ObjectShare.ACCESS_LEVEL_NONE);
		}

		return shareObject;
	}

	/**
	 * @description Method to return a new share record for the shareObject
	 *
	 * @param relatedRecordId Record Id for which access needs to be granted
	 * @param accessLevel Access level for share record
	 * @param userOrGroupId User or Group Id to whom access needs to be granted
	 *
	 * @return Newly created Share object record, not committed yet
	 */
	public static SObject newSObjectShare(Id relatedRecordId, String accessLevel, Id userOrGroupId)
	{
		return newSObjectShare(CMN_DAL_ObjectShare.getShareDescribe(relatedRecordId), relatedRecordId, accessLevel, userOrGroupId);
	}

	/**
	 * @description Will publish log events
	 *
	 * @param numberOfItems Number of items to create
	 */
	@TestVisible
	private static void publishLogEvents(Integer numberOfItems)
	{
		for(Integer i = 0; i < numberOfItems; i++)
		{
			CMN_DAL_Logger.log(String.valueOf(i), 'CMN_DAL_Logger_TEST/testLimitBreach', LoggingLevel.INFO);
		}
	}

	/**
	 * @description Will generate Communication Attachment Data Transfer Objects
	 *
	 * @param templateAttachments List of templates to use when generating DTOs
	 *
	 * @return List of items
	 */
	@TestVisible
	private static List<CMN_DTO_CommunicationAttachment> createCommunicationAttachmentDto(List<CMN_CommunicationTemplateAttachment__c> templateAttachments)
	{
		List<CMN_DTO_CommunicationAttachment> communicationAttachments = new List<CMN_DTO_CommunicationAttachment>();

		for(CMN_CommunicationTemplateAttachment__c attachment : templateAttachments)
		{
			CMN_DTO_CommunicationAttachment dtoCommunicationAttachment = new CMN_DTO_CommunicationAttachment();
			dtoCommunicationAttachment.attachmentId = attachment.Id;
			dtoCommunicationAttachment.attachmentDefinitionId = attachment.SC_Definition__c;
			dtoCommunicationAttachment.definitionName = attachment.SC_Definition__r.Name;
			dtoCommunicationAttachment.isSelected = true;
			dtoCommunicationAttachment.reason = CMN_DAL_SObjectDomain.generateRandomDescription();
			communicationAttachments.add(dtoCommunicationAttachment);
		}

		return communicationAttachments;
	}

	/**
	 * @description Method to create and return the Communication Template record
	 *
	 * @param numberOfRecords store the number of records
	 * @param selectorClass name of the selector class
	 * @param apiName the CMN_APIName__c api name
	 *
	 * @return List of Communication Templates
	 */
	@TestVisible
	private static List<CMN_CommunicationTemplate__c> createCommunicationTemplate(Integer numberOfRecords, String selectorClass, String apiName)
	{
		List<CMN_CommunicationTemplate__c> cmnCommunicationTemplates = new List<CMN_CommunicationTemplate__c>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			cmnCommunicationTemplates.add(newCommunicationTemplate(selectorClass, apiName));
		}

		insert cmnCommunicationTemplates;
		return cmnCommunicationTemplates;
	}

	/**
	 * @description Method to create and return the Communication Template record
	 *
	 * @param selectorClass name of the selector class
	 * @param apiName the CMN_APIName__c api name
	 *
	 * @return Instance of Communication Template
	 */
	@TestVisible
	private static CMN_CommunicationTemplate__c newCommunicationTemplate(String selectorClass, String apiName)
	{
		CMN_CommunicationTemplate__c template = new CMN_CommunicationTemplate__c();

		template.Name = CMN_DAL_SObjectDomain.generateRandomName();
		template.CMN_Code__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		template.CMN_SelectorClassName__c = selectorClass;
		template.CMN_APIName__c = apiName;

		return template;
	}

	/**
	 * @description Method to create and return the Communication Template record
	 *
	 * @param numberOfRecords store the number of records
	 * @param selectorClass name of the selector class
	 *
	 * @return List of Communication Templates
	 */
	@TestVisible
	private static List<CMN_CommunicationTemplate__c> createCommunicationTemplate(Integer numberOfRecords, String selectorClass)
	{
		return createCommunicationTemplate(numberOfRecords, selectorClass, null);
	}

	/**
	 * @description Method to create and return the Communication Template Object Definition record
	 *
	 * @param objectAPIName API name of the Sobject to be defined
	 *
	 * @return A Communication Template Object Definition record
	 */
	@TestVisible
	private static CMN_CommunicationTemplateObjectDef__c createCommunicationTemplateObjectDefinition(String objectAPIName)
	{
		CMN_CommunicationTemplateObjectDef__c objectDefinition = new CMN_CommunicationTemplateObjectDef__c();

		objectDefinition.Name = CMN_DAL_SObjectDomain.generateRandomName();
		objectDefinition.CMN_ApiName__c = objectAPIName;
		objectDefinition.CMN_Code__c = CMN_DAL_SObjectDomain.generateRandomName();

		insert objectDefinition;

		return objectDefinition;
	}

	/**
	 * @description Method to create and return the Communication Template Object Map record
	 *
	 * @param templateId store the Id of the Communication Template
	 * @param definitionId store the Id of the Communication Template Object Definition
	 *
	 * @return An instance of Communication Template Object Map
	 */
	@TestVisible
	private static CMN_CommunicationTemplateObjectMap__c createCommTemplateObjectMap(Id templateId, Id definitionId)
	{
		CMN_CommunicationTemplateObjectMap__c templateObjectMap = new CMN_CommunicationTemplateObjectMap__c();
		templateObjectMap.CMN_ObjectDefinition__c = definitionId;
		templateObjectMap.CMN_CommunicationTemplate__c = templateId;

		insert templateObjectMap;

		return templateObjectMap;
	}

	/**
	 * @description Method to create and return the Communication Template Object Field record
	 *
	 * @param fieldAPIName API name of the field of an object
	 * @param templateObjectDefinitionId Id of the template object definition to be associated with the object fields
	 *
	 * @return Communication Template Object Field
	 */
	@TestVisible
	private static CMN_CommunicationTemplateObjectField__c createCommunicationTemplateObjectField(String fieldAPIName, Id templateObjectDefinitionId)
	{
		CMN_CommunicationTemplateObjectField__c objectField = new CMN_CommunicationTemplateObjectField__c();

		objectField.Name = fieldAPIName;
		objectField.CMN_Code__c = CMN_DAL_SObjectDomain.generateRandomName();
		objectField.CMN_ObjectDefinition__c = templateObjectDefinitionId;

		insert objectField;

		return objectField;
	}

	/**
	 * @description Method to create and return the Communication Template Attachment record
	 *
	 * @param templateId store the Id of the Communication Template
	 * @param numberOfRecords store the number of records
	 *
	 * @return List of Communication Template Attachments
	 */
	@TestVisible
	private static List<CMN_CommunicationTemplateAttachment__c> createCommunicationTemplateAttachments(Id templateId, Integer numberOfRecords)
	{
		List<CMN_CommunicationTemplateAttachment__c> communicationTemplateAttachments = new List<CMN_CommunicationTemplateAttachment__c>();

		for(Integer i = 0; i < numberOfRecords; i++)
		{
			CMN_CommunicationTemplateAttachment__c templateAttachment = new CMN_CommunicationTemplateAttachment__c();
			templateAttachment.SC_Template__c = templateId;

			communicationTemplateAttachments.add(templateAttachment);
		}

		insert communicationTemplateAttachments;

		return communicationTemplateAttachments;
	}

	/**
	 * @description Will create Permission Set Assignment records for the given list of users and permission set name
	 *
	 * @param users List of users
	 * @param permissionSetName Permission Set Name
	 */
	@TestVisible
	private static void createPermissionSetAssignments(List<User> users, String permissionSetName)
	{
		PermissionSet foundPermissionSet = CMN_DAL_PermissionSet.findByName(permissionSetName);

		List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();

		for(User userRecord : users)
		{
			PermissionSetAssignment newAssignment = new PermissionSetAssignment();

			newAssignment.PermissionSetId = foundPermissionSet.Id;
			newAssignment.AssigneeId = userRecord.Id;

			newAssignments.add(newAssignment);
		}

		insert newAssignments;
	}

	/**
	 * @description Will create a list of CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory
	 *
	 * @return List of CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory
	 */
	@TestVisible
	private static List<CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory> getDtoLoginHistories()
	{
		List<CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory> dtoLoginHistories = new List<CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory>();
		List<User> users = CMN_DAL_User.findActiveUsers(NUMBER_OF_ACTIVE_USERS_TO_RETRIEVE);

		CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory loginHistory1 = new CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory();
		loginHistory1.userId = users[0].Id;
		loginHistory1.loginTime = CMN_UTIL_Date.iso8601StringToDateTime('2022-05-05T09:57:46.000+0000');
		dtoLoginHistories.add(loginHistory1);

		CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory loginHistory2 = new CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory();
		loginHistory2.userId = users[0].Id;
		loginHistory2.loginTime = CMN_UTIL_Date.iso8601StringToDateTime('2022-05-05T13:45:08.000+0000');
		dtoLoginHistories.add(loginHistory2);

		CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory loginHistory3 = new CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory();
		loginHistory3.userId = users[1].Id;
		loginHistory3.loginTime = CMN_UTIL_Date.iso8601StringToDateTime('2022-05-05T17:55:56.000+0000');
		dtoLoginHistories.add(loginHistory3);

		CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory loginHistory4 = new CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory();
		loginHistory4.userId = users[1].Id;
		loginHistory4.loginTime = CMN_UTIL_Date.iso8601StringToDateTime('2022-05-27T18:24:35.000+0000');
		dtoLoginHistories.add(loginHistory4);

		CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory loginHistory5 = new CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory();
		loginHistory5.userId = users[2].Id;
		loginHistory5.loginTime = CMN_UTIL_Date.iso8601StringToDateTime('2022-05-05T11:44:38.000+0000');
		dtoLoginHistories.add(loginHistory5);

		CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory loginHistory6 = new CMN_BATCH_ProcessLoginHistory.DTO_LoginHistory();
		loginHistory6.userId = users[2].Id;
		loginHistory6.loginTime = CMN_UTIL_Date.iso8601StringToDateTime('2022-06-05T19:23:55.000+0000');
		dtoLoginHistories.add(loginHistory6);

		return dtoLoginHistories;
	}

	/**
	 * @description Method to create login frequency records with concatenated strings
	 *
	 * @param numberOfRecords Number of records to create
	 * @param concatenatedStrings Set of concatenated strings
	 *
	 * @return List of Login Frequency
	 */
	@TestVisible
	private static List<CMN_LoginFrequency__c> createLoginFrequencyRecords(Integer numberOfRecords, Set<String> concatenatedStrings)
	{
		List<CMN_LoginFrequency__c> newLoginFrequencyRecords = new List<CMN_LoginFrequency__c>();

		Iterator<String> concatenatedString = concatenatedStrings.iterator();
		for(Integer i = 0; i < numberOfRecords; i++)
		{
			CMN_LoginFrequency__c loginFrequency = new CMN_LoginFrequency__c();
			loginFrequency.CMN_UniqueLoginCount__c = CMN_DAL_SObjectDomain.generateRandomDecimal(1, 0);
			loginFrequency.CMN_TotalLoginCount__c = CMN_DAL_SObjectDomain.generateRandomDecimal(1, 0);
			loginFrequency.CMN_UserIdWithLoginYearAndMonth__c = concatenatedString.next();

			newLoginFrequencyRecords.add(loginFrequency);
		}

		insert newLoginFrequencyRecords;

		return newLoginFrequencyRecords;
	}
}