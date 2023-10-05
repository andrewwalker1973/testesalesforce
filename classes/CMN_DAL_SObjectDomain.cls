/**
 * @description Common Object domain class containing utility methods for performing DML operations or setting object fields in unit tests
 *
 * @see CMN_DAL_SObjectDomain_TEST
 *
 * @author vishakha.saini@accenture.com, jason.van.beukering@accenture.com
 *
 * @date December 2021, May 2023
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.ExcessivePublicCount,PMD.ExcessiveClassLength')
public virtual inherited sharing class CMN_DAL_SObjectDomain implements ISObjectDomain
{
	/**
	 * @description used when logging insert, update or delete DML operation errors
	 */
	@TestVisible
	private static final String CLASS_METHOD_UPDATE_DATABASE = 'CMN_DAL_SObjectDomain/updateDatabase';
	/**
	 * @description used when logging upsert DML operation errors
	 */
	private SObjectType objectType;

	/**
	 * @description Construct which initialises object with a type
	 *
	 * @param objectType The type to use when constructing object
	 */
	public CMN_DAL_SObjectDomain(SObjectType objectType)
	{
		this.objectType = objectType;
	}

	/**
	 * @description ISObjectDomain interface if extending class is required to hold state variables
	 * or for mocking purposes
	 */
	public interface ISObjectDomain
	{
		/**
		 * @description Returns the SObjectType this Domain class represents
		 *
		 * @return object type
		 */
		SObjectType sObjectType();
	}

	/**
	 * @description Use to indicate what type of DML operation to perform
	 */
	public enum DatabaseOperation
	{
		/**
		 * @description Create new records
		 */
		DBO_INSERT,
		/**
		 * @description Update existing records
		 */
		DBO_UPDATE,
		/**
		 * @description Delete existing records
		 */
		DBO_DELETE,
		/**
		 * @description Restore previously deleted records
		 */
		DBO_UNDELETE,
		/**
		 * @description Will upsert provided records
		 */
		DBO_UPSERT
	}

	@TestVisible
	private static final String CONTACT_EMAIL_SUFFIX = '@example.com';

	/**
	 * @description API name of the created by id field on an SObject
	 */
	public static final String FIELD_CREATED_BY_ID = 'CreatedById';
	/**
	 * @description API name of the created date field on an SObject
	 */
	public static final String FIELD_CREATED_DATE = 'CreatedDate';
	/**
	 * @description API name of the modified date field on an SObject
	 */
	public static final String FIELD_LAST_MODIFIED_DATE = 'LastModifiedDate';

	/**
	 * @description API name of the Id field on an SObject
	 */
	public static final String FIELD_ID = 'Id';
	/**
	 * @description API name of the OwnerId field on an SObject
	 */
	public static final String FIELD_OWNER_ID = 'OwnerId';
	/**
	 * @description API name of the Name field on an SObject
	 */
	public static final String FIELD_NAME = 'Name';
	/**
	 * @description API name of the RecordType Id field on an SObject
	 */
	public static final String FIELD_RECORD_TYPE_ID = 'RecordTypeId';
	/**
	 * @description Join field for related activities
	 */
	public static final String RELATED_OPEN_ACTIVITIES = 'OpenActivities';
	/**

	 * @description The default number of rows that are processed by batch apex
	 *
	 * @see Database.Batchable
	 */
	public static final Integer DEFAULT_BATCH_SIZE = 200;
	/**

	 * @description The maximum number of rows that can be processed by batch apex
	 *
	 * @see Database.Batchable
	 */
	public static final Integer MAXIMUM_BATCH_SIZE = 2000;

	/**
	 * @description Maximum number of jobs that can be run at once
	 */
	public static final Integer NUMBER_OF_PARALLEL_JOBS = 5;
	/**
	 * @description Maximum number of records that can be queried
	 *
	 * @deprecated Method added for backward compatibility on higher environments. Remove method and all references after Object Share is deployed to QAY.
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	public static final Integer LIMIT_NUMBER_OF_RECORDS = CMN_DAL_Search.LIMIT_NUMBER_OF_RECORDS;

	//Various Lengths
	private static final Integer DEFAULT_INTEGER_LENGTH = 8;
	private static final Integer DEFAULT_NAME_LEN = 15;
	private static final Integer FL_NAME = 80;
	private static final String PHONE_FMT = '({0})-{1}-{2}';

	/**
	 * @description override if required
	 *
	 * @return object type
	 */
	public SObjectType sObjectType()
	{
		return this.objectType;
	}

	/**
	 * @description This method is use to insert the Object
	 *
	 * @param obj as input
	 */
	public static void insertDBObject(SObject obj)
	{
		insertDBObject(obj, true);
	}

	/**
	 * @description This method is use to check the updates
	 *
	 * @param obj as input
	 * @param allOrNothing as input
	 *
	 * @return Will return a list of dml results or throws an exception
	 */
	public static Database.SaveResult insertDBObject(SObject obj, Boolean allOrNothing)
	{
		return insertDBObjects(new List<SObject> {obj}, allOrNothing).iterator().next();
	}

	/**
	 * @description This method is use to insert the Object
	 *
	 * @param listOfObjects as input
	 */
	public static void insertDBObjects(List<SObject> listOfObjects)
	{
		insertDBObjects(listOfObjects, true);
	}

	/**
	 * @description This method is use to insert the Object
	 *
	 * @param listOfObjects as input
	 * @param allOrNothing as input
	 *
	 * @return Will return a list of DML results
	 */
	public static List<Database.SaveResult> insertDBObjects(List<SObject> listOfObjects, Boolean allOrNothing)
	{
		return (List<Database.SaveResult>)updateDatabase(listOfObjects, DatabaseOperation.DBO_INSERT, allOrNothing);
	}

	/**
	 * @description This method is use to check update action
	 *
	 * @param obj as input
	 */
	public static void updateDBObject(SObject obj)
	{
		updateDBObject(obj, true);
	}

	/**
	 * @description This method is use to check update action
	 *
	 * @param obj as input
	 * @param allOrNothing as input
	 *
	 * @return Will return a list of dml results or throws an exception
	 */
	public static Database.SaveResult updateDBObject(SObject obj, Boolean allOrNothing)
	{
		return updateDBObjects(new List<SObject> {obj}, allOrNothing).iterator().next();
	}

	/**
	 * @description This method is use to check update action
	 *
	 * @param listOfObjects as input
	 */
	public static void updateDBObjects(List<SObject> listOfObjects)
	{
		updateDBObjects(listOfObjects, true);
	}

	/**
	 * @description This method is use to check update operation
	 *
	 * @param listOfObjects as input
	 * @param allOrNothing as input
	 *
	 * @return Will return a list of dml results or throws an exception
	 */
	public static List<Database.SaveResult> updateDBObjects(List<SObject> listOfObjects, Boolean allOrNothing)
	{
		return (List<Database.SaveResult>)updateDatabase(listOfObjects, DatabaseOperation.DBO_UPDATE, allOrNothing);
	}

	/**
	 * @description Call this method to upsert an object
	 *
	 * @param obj The item to upsert
	 *
	 * @throws DmlException The type of exception that could be thrown
	 */
	public static void upsertDBObject(SObject obj)
	{
		upsertDBObject(obj, true);
	}

	/**
	 * @description Call this method to upsert an object
	 *
	 * @param obj The item to upsert
	 * @param allOrNothing set to true if you if you expect all operations to succeed
	 *
	 * @return Will return a list of dml results or throws an exception
	 *
	 * @throws DmlException The type of exception that could be thrown
	 */
	public static Database.UpsertResult upsertDBObject(SObject obj, Boolean allOrNothing)
	{
		return upsertDBObjects(new List<SObject> {obj}, allOrNothing).iterator().next();
	}

	/**
	 * @description Call this method to upsert objects
	 *
	 * @param listOfObjects The items to upsert
	 *
	 * @throws DmlException The type of exception that could be thrown
	 */
	public static void upsertDBObjects(List<SObject> listOfObjects)
	{
		upsertDBObjects(listOfObjects, true);
	}

	/**
	 * @description Performs an upsert operation
	 *
	 * @param listOfObjects Objects to upsert
	 * @param allOrNothing Indicate if all a partial commit is allowed (i.e. if some object updates are invalid, whole transaction doesn't rollback)
	 *
	 * @return Will return a list of dml results or throws an exception
	 */
	public static List<Database.UpsertResult> upsertDBObjects(List<SObject> listOfObjects, Boolean allOrNothing)
	{
		List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>();

		if(!listOfObjects.isEmpty())
		{
			SObjectType objectType = listOfObjects.isEmpty() ? null : listOfObjects.iterator().next().getSObjectType();
			List<SObject> upsertObjects = CMN_UTIL_Array.createEmptySObjectList(objectType);
			upsertObjects.addAll(listOfObjects);

			upsertResults = (List<Database.UpsertResult>)updateDatabase(upsertObjects, DatabaseOperation.DBO_UPSERT, allOrNothing);
		}

		return upsertResults;
	}

	/**
	 * @description Performs an upsert operation
	 *
	 * @param listOfObjects Objects to upsert
	 * @param objectType Since upsert operations cannot be generic, this is used to typecast in list to correct type
	 * @param allOrNothing Indicate if all a partial commit is allowed (i.e. if some object updates are invalid, whole transaction doesn't rollback)
	 *
	 * @return Indicates whether all operations succeeded
	 *
	 * @deprecated Method added for backward compatibility on higher environments. Remove method and all references after Object Share is deployed to QAY.
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	public static Boolean dynamicUpsertDBObjects(List<SObject> listOfObjects, SObjectType objectType, Boolean allOrNothing)
	{
		objectType = null; // Not used
		return !CMN_UTIL_Logger.errorDMLOperationResults(updateDatabase
				(listOfObjects, DatabaseOperation.DBO_UPSERT, allOrNothing, false, true, false), CLASS_METHOD_UPDATE_DATABASE);
	}

	/**
	 * @description This method is use to check update action
	 *
	 * @param obj as input
	 */
	public static void deleteDBObject(SObject obj)
	{
		deleteDBObject(obj, true);
	}

	/**
	 * @description This method is use to check the updates
	 *
	 * @param obj as input
	 * @param allOrNothing as input
	 *
	 * @return Will return a list of dml results or throws an exception
	 */
	public static Database.DeleteResult deleteDBObject(SObject obj, Boolean allOrNothing)
	{
		return deleteDBObjects(new List<SObject> {obj}, allOrNothing).iterator().next();
	}

	/**
	 * @description This method is use to check update action
	 *
	 * @param listOfObjects as input
	 */
	public static void deleteDBObjects(List<SObject> listOfObjects)
	{
		deleteDBObjects(listOfObjects, true);
	}

	/**
	 * @description This method is use to check update action
	 *
	 * @param listOfObjects as input
	 * @param allOrNothing as input
	 *
	 * @return Will return a list of dml results or throws an exception
	 */
	public static List<Database.DeleteResult> deleteDBObjects(List<SObject> listOfObjects, Boolean allOrNothing)
	{
		return (List<Database.DeleteResult>)updateDatabase(listOfObjects, DatabaseOperation.DBO_DELETE, allOrNothing);
	}

	/**
	 * @description Call this method to undelete a deleted object
	 *
	 * @param obj The item to restore
	 *
	 * @throws DmlException The type of exception that could be thrown
	 */
	public static void undeleteDBObject(SObject obj)
	{
		undeleteDBObject(obj, true);
	}

	/**
	 * @description Call this method to undelete a deleted object
	 *
	 * @param obj The item to restore
	 * @param allOrNothing set to true if you if you expect all operations to succeed
	 *
	 * @return Will return a list of dml results or throws an exception
	 *
	 * @throws DmlException The type of exception that could be thrown
	 */
	public static Database.UndeleteResult undeleteDBObject(SObject obj, Boolean allOrNothing)
	{
		return undeleteDBObjects(new List<SObject> {obj}, allOrNothing).iterator().next();
	}

	/**
	 * @description Call this method to undelete deleted objects
	 *
	 * @param listOfObjects The items to restore
	 *
	 * @throws DmlException The type of exception that could be thrown
	 */
	public static void undeleteDBObjects(List<SObject> listOfObjects)
	{
		undeleteDBObjects(listOfObjects, true);
	}

	/**
	 * @description Call this method to undelete a deleted object
	 *
	 * @param listOfObjects The items to restore
	 * @param allOrNothing set to true if you if you expect all operations to succeed
	 *
	 * @return Will return a list of dml results or throws an exception
	 *
	 * @throws DmlException The type of exception that could be thrown
	 */
	public static List<Database.UndeleteResult> undeleteDBObjects(List<SObject> listOfObjects, Boolean allOrNothing)
	{
		return (List<Database.UndeleteResult>)updateDatabase(listOfObjects, DatabaseOperation.DBO_UNDELETE, allOrNothing);
	}

	/**
	 * @description Will perform a Database update on the list of SObject provided
	 *
	 * @param listOfObjects A list of SObjects to be processed
	 * @param operation The DML operation to perform
	 * @param allOrNothing Whether partial update can happen; if true a single failure will abort transaction
	 *
	 * @return Will return list of DML results
	 */
	public static List<Object> updateDatabase(List<SObject> listOfObjects, DatabaseOperation operation, Boolean allOrNothing)
	{
		return updateDatabase(listOfObjects, operation, allOrNothing, true, true, true);
	}

	/**
	 * @description Will perform a Database update on the list of SObject provided
	 *
	 * @param listOfObjects A list of SObjects to be processed
	 * @param operation The DML operation to perform
	 * @param allOrNothing Whether partial update can happen; if true a single failure will abort transaction
	 * @param logErrors Will ensure any errors are logged
	 * @param singleObjectType Indicates if the list only has a single object type, if set the method won't try and separate objects by ObjectType
	 * @param reRaiseError If set to true and an error is thrown when attempting to perform DML operation, then re-raise the exception
	 *
	 * @return Will return list of DML results
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static List<Object> updateDatabase
			(List<SObject> listOfObjects, DatabaseOperation operation, Boolean allOrNothing, Boolean logErrors, Boolean singleObjectType, Boolean reRaiseError)
	{
		List<Object> dmlResults;

		if(listOfObjects.isEmpty())
		{
			switch on operation
		{
				when DBO_DELETE
				{
					return new List<Database.DeleteResult>();
				}
				when DBO_UNDELETE
				{
					return new List<Database.UndeleteResult>();
				}
				when DBO_UPSERT
				{
					return new List<Database.UpsertResult>();
				}
				when else
				{
					return new List<Database.SaveResult>();
				}
			}
		}

		Savepoint saveTransaction = null;

		//If we are only committing single object we don't need to initiate a transaction as an error will roll back all changes anyway
		if(allOrNothing && !singleObjectType)
		{
			saveTransaction = Database.setSavepoint();
		}

		//The code below is to prevent an issue when multiple object types are included in the update list according to articles below
		//https://developer.salesforce.com/docs/atlas.en-us.232.0.api.meta/api/sforce_api_calls_create.htm#MixedSaveTitle
		//https://developer.salesforce.com/docs/atlas.en-us.232.0.api.meta/api/sforce_api_calls_update.htm
		Map<SObjectType, List<SObject>> typeToObjectMap = new Map<SObjectType, List<SObject>>();

		SObjectType objectType;

		//If we're told this is a single object type, don't do any segmentation
		//Delete and Upsert operations don't need segmentation
		//Upsert can only be one object type
		//Delete can be a variety of object types without failing
		//Or if list only has one record then it can only be of one type
		if(singleObjectType || operation == DatabaseOperation.DBO_DELETE || operation == DatabaseOperation.DBO_UPSERT || listOfObjects.size() == 1)
		{
			typeToObjectMap.put(objectType, listOfObjects);
		}
		else
		{
			for(SObject anObject : listOfObjects)
			{
				objectType = anObject.getSObjectType();

				List<SObject> objectsForType = typeToObjectMap.get(objectType);

				if(objectsForType == null)
				{
					objectsForType = new List<SObject>();
					typeToObjectMap.put(objectType, objectsForType);
				}

				objectsForType.add(anObject);
			}
		}

		try
		{
			dmlResults = performDMLOperation(typeToObjectMap, operation, allOrNothing);

			if(logErrors && !allOrNothing)
			{
				CMN_UTIL_Logger.errorDMLOperationResults(dmlResults, CLASS_METHOD_UPDATE_DATABASE);
			}
		}
		catch(Exception error)
		{
			if(logErrors)
			{
				CMN_UTIL_Logger.error(error, CLASS_METHOD_UPDATE_DATABASE);
			}

			if(saveTransaction != null)
			{
				Database.rollback(saveTransaction);
			}

			if(reRaiseError)
			{
			throw error;
		}
		}

		return dmlResults;
	}

	/**
	 * @description Will perform the DML operation provided on the given a list of SObject
	 *
	 * @param typeToObjectMap A map of objects to update per Object Type
	 * @param operation The DML operation to perform
	 * @param allOrNothing Whether partial update can happen; if true a single failure will abort transaction
	 *
	 * @return Will return list of DML results
	 */
	private static List<Object> performDMLOperation(Map<SObjectType, List<SObject>> typeToObjectMap, DatabaseOperation operation, Boolean allOrNothing)
	{
		List<Object> dmlResults;

		for(SObjectType objectType : typeToObjectMap.keySet())
		{
			dmlResults = performDMLOperation(typeToObjectMap.get(objectType), operation, allOrNothing);
		}

		return dmlResults;
	}

	/**
	 * @description Will perform the DML operation provided on the given a list of SObject
	 *
	 * @param listOfObjects A list of objects to perform DML operation against, these must be of on type only
	 * @param operation The DML operation to perform
	 * @param allOrNothing Whether partial update can happen; if true a single failure will abort transaction
	 *
	 * @return Will return list of DML results
	 */
	private static List<Object> performDMLOperation(List<SObject> listOfObjects, DatabaseOperation operation, Boolean allOrNothing)
	{
		List<Object> dmlResults;

		switch on operation
		{
			when DBO_INSERT
			{
				dmlResults = Database.insert(listOfObjects, allOrNothing);
			}
			when DBO_UPDATE
			{
				dmlResults = Database.update(listOfObjects, allOrNothing);
			}
			when DBO_DELETE
			{
				dmlResults = Database.delete(listOfObjects, allOrNothing);
			}
			when DBO_UPSERT
			{
				dmlResults = Database.upsert(listOfObjects, allOrNothing);
			}
			when else
			{
				dmlResults = Database.undelete(listOfObjects, allOrNothing);
			}
		}

		return dmlResults;
	}

	/**
	 * @description This method is use to run the Operation trigger
	 *
	 * @return This will return all the trigger operations
	 */
	public static DatabaseOperation getTriggerDBOperation()
	{
		if(Trigger.isInsert)
		{
			return DatabaseOperation.DBO_INSERT;
		}
		else if(Trigger.isUpdate)
		{
			return DatabaseOperation.DBO_UPDATE;
		}
		else if(Trigger.isDelete)
		{
			return DatabaseOperation.DBO_DELETE;
		}
		else
		{
			return DatabaseOperation.DBO_UNDELETE;
		}
	}

	/**
	 * @description Generates random boolean value
	 *
	 * @return Either true or false
	 */
	public static Boolean generateRandomBoolean()
	{
		return CMN_UTIL_Random.nextBoolean();
	}

	/**
	 * @description Will generate a random Currency with Decimal with double digit precision
	 *
	 * @return the decimal generated as a string
	 */
	public static String generateRandomCurrencyAsString()
	{
		return String.valueOf(generateRandomDecimalAsString(2));
	}

	/**
	 * @description Method is use to generate Date
	 *
	 * @return Date
	 */
	public static Date generateRandomDate()
	{
		Date randomDate = Date.today();
		Date epochDate = CMN_UTIL_Date.getEpochDate();
		Integer daysBetween = epochDate.daysBetween(randomDate);
		//Generate years to subtract from current date
		Integer daysToSubtract = CMN_UTIL_Random.nextInteger(daysBetween, false);

		return randomDate.addDays(-daysToSubtract);
	}

	/**
	 * @description Method is use to generate DateTime
	 *
	 * @return DateTime
	 */
	public static Datetime generateRandomDateTime()
	{
		Date randomDate = Date.today();
		Date epochDate = CMN_UTIL_Date.getEpochDate();
		Integer daysBetween = epochDate.daysBetween(randomDate);
		//Generate years to subtract from current date
		Integer daysToSubtract = CMN_UTIL_Random.nextInteger(daysBetween, false);

		return System.now().addDays(-daysToSubtract);
	}

	/**
	 * @description Will generate a random Double with Decimal with double digit precision
	 *
	 * @return the decimal generated
	 */
	public static Decimal generateRandomDecimal()
	{
		return generateRandomDecimal(2);
	}

	/**
	 * @description Will generate a random Double with Decimal with double digit precision
	 *
	 * @param length The length of number to generate
	 * @param scale the scale of the number
	 *
	 * @return the decimal generated
	 *
	 * @see Decimal.setScale
	 */
	public static Decimal generateRandomDecimal(Integer length, Integer scale)
	{
		Double randomDouble = generateRandomDouble(length);
		return Decimal.valueOf(randomDouble).setScale(scale);
	}

	/**
	 * @description Will generate a random Double with Decimal with double digit precision
	 *
	 * @param scale the scale of the number
	 *
	 * @return the decimal generated
	 *
	 * @see Decimal.setScale
	 */
	public static Decimal generateRandomDecimal(Integer scale)
	{
		Double randomDouble = generateRandomDouble();
		return Decimal.valueOf(randomDouble).setScale(scale);
	}

	/**
	 * @description Will generate a random Double with Decimal with double digit precision
	 *
	 * @param scale the scale of the number
	 *
	 * @return the decimal generated as a string
	 *
	 * @see Decimal.setScale
	 */
	public static String generateRandomDecimalAsString(Integer scale)
	{
		return String.valueOf(generateRandomDecimal(scale));
	}

	/**
	 * @description Method is use to generate description
	 *
	 * @return String
	 */
	public static String generateRandomDescription()
	{
		return CMN_UTIL_Random.randomAlphabetic(FL_NAME);
	}

	/**
	 * @description Will generate a random Double
	 *
	 * @return the double generated
	 */
	public static Double generateRandomDouble()
	{
		Double randomDouble = generateRandomDouble(DEFAULT_INTEGER_LENGTH);
		return randomDouble;
	}

	/**
	 * @description Will generate a random Double
	 *
	 * @param length The length of number to generate
	 *
	 * @return the double generated
	 */
	public static Double generateRandomDouble(Integer length)
	{
		Double randomDouble = Math.random() * Math.pow(10, length);
		return randomDouble;
	}

	/**
	 * @description Method is use to generate Email
	 *
	 * @return String
	 */
	public static String generateRandomEmail()
	{
		return generateRandomName() + CONTACT_EMAIL_SUFFIX;
	}

	/**
	 * @description Method is use to generate Integer
	 *
	 * @return randomInteger
	 */
	public static Integer generateRandomInteger()
	{
		return generateRandomInteger(DEFAULT_INTEGER_LENGTH);
	}

	/**
	 * @description Generate random Integer of specified length within Integer limits
	 *
	 * @param length as input
	 *
	 * @return result
	 */
	public static Integer generateRandomInteger(Integer length)
	{
		Integer startNumber = (Integer)Math.pow(10, length - 1);
		return Math.round((Math.random() * (9 * startNumber) + startNumber));
	}

	/**
	 * @description <p>
	 * Returns a random integer within the specified range.
	 * </p>
	 *
	 * @param min the smallest value that can be returned, must be non-negative
	 * @param max the upper bound (not included)
	 *
	 * @return the random integer
	 *
	 * @throws IllegalArgumentException if {@code startInclusive > endExclusive} or if
	 *             {@code startInclusive} is negative
	 */
	public static Integer generateRandomInteger(Integer min, Integer max)
	{
		return CMN_UTIL_Random.nextInteger(min, max);
	}

	/**
	 * @description Method is use to generate Name
	 *
	 * @return String
	 */
	public static String generateRandomName()
	{
		return CMN_UTIL_Random.randomAlphabetic(DEFAULT_NAME_LEN);
	}

	/**
	 * @description Method is use to generate Number
	 *
	 * @return generateRandomNumber
	 */
	public static String generateRandomNumber()
	{
		return generateRandomNumber(DEFAULT_INTEGER_LENGTH);
	}

	/**
	 * @description Method is use to generate Number with length
	 *
	 * @param length as input
	 *
	 * @return integer
	 */
	public static String generateRandomNumber(Integer length)
	{
		return CMN_UTIL_Random.randomNumeric(length);
	}

	/**
	 * @description Will generate a random Percentage between 0 and 100 with double digit precision
	 *
	 * @return the percentage generated as a string
	 */
	public static Decimal generateRandomPercentage()
	{
		return generateRandomDecimal(2, 2);
	}

	/**
	 * @description Will generate a random Percentage between 0 and 100 with double digit precision
	 *
	 * @return the percentage generated as a string
	 */
	public static String generateRandomPercentageAsString()
	{
		return String.valueOf(generateRandomPercentage());
	}

	/**
	 * @description Method is use to generate phone number
	 *
	 * @return String
	 */
	public static String generateRandomPhoneNumber()
	{
		String areaCode1 = CMN_UTIL_Random.random(3, 0, 9, false, true);

		//Ensure we only have numbers with 3 digits
		String phoneNumber1 = CMN_UTIL_Random.random(3, 100, 999, false, true);

		//Ensure we only have numbers with 4 digits
		String phoneNumber2 = CMN_UTIL_Random.random(4, 1000, 9999, false, true);

		return String.format(PHONE_FMT, new List<String> {areaCode1, phoneNumber1, phoneNumber2});
	}

	/**
	 * @description Method will retrieve the Id for the RecordType of an Object by DeveloperName (if it exists), else it will return a null
	 * This method can be called many times in the same transaction context but will only ever do one query
	 *
	 * @param objectType Object Type for which you want to retrieve the Record Type
	 * @param recordTypeName Developer Name for the recordtype
	 *
	 * @return Null or Id of the Record Type
	 */
	public static Id getRecordTypeByDeveloperName(SObjectType objectType, String recordTypeName)
	{
		return getRecordTypeInfo(objectType, recordTypeName)?.recordTypeId;
	}

	/**
	 * @description Method will return the record type information requested
	 *
	 * @param objectType Object Type for which you want to retrieve the Record Type
	 * @param recordTypeName Developer Name for the recordtype
	 *
	 * @return Null or RecordTypeInfo
	 */
	public static RecordTypeInfo getRecordTypeInfo(SObjectType objectType, String recordTypeName)
	{
		return objectType != null && String.isNotBlank(recordTypeName) ? objectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName) : null;
	}

	/**
	 * @description Method is use to get the sObject Type
	 *
	 * @param objectTypeName as input
	 *
	 * @return result
	 */
	public static SObject newObject(String objectTypeName)
	{
		SObjectType objType = CMN_UTIL_System.getSObjectTypeByName(objectTypeName);

		return objType == null ? null : objType.newSObject();
	}

	/**
	 * @description Will initialise a new object taking taking the value for the existing object
	 *
	 * @param existingObject The existing object to use to create new object
	 * @param ignoredFields Any fields here will be ignored for initialization
	 *
	 * @return An new object that's have had some or all of it's fields initialized
	 */
	public static SObject newObjectFromExisting(SObject existingObject, Set<SObjectField> ignoredFields)
	{
		SObject newObject;

		if(existingObject != null)
		{
			//We want to retain some of the fields and set to default some of the others
			newObject = existingObject.clone(true, true, false, true);

			Set<String> existingObjectPopulatedFields = existingObject.getPopulatedFieldsAsMap().keySet();
			Map<String, SObjectField> allFieldsMap = CMN_UTIL_System.getObjectFieldMap(newObject.getSObjectType().getDescribe().getLocalName());

			for(String populatedFieldName : existingObjectPopulatedFields)
			{
				SObjectField objectField = allFieldsMap.get(populatedFieldName.toLowerCase());
				DescribeFieldResult fieldDescribe = objectField?.getDescribe();

				if(fieldDescribe?.isUpdateable() == true)
				{
					if(ignoredFields?.contains(objectField) == true)
					{
						newObject.put(populatedFieldName, existingObject.get(populatedFieldName));
					}
					else if(!populatedFieldName.equalsIgnoreCase(FIELD_OWNER_ID))
					{
						newObject.put(populatedFieldName, fieldDescribe.defaultValue);
					}
				}
			}
		}

		return newObject;
	}

	/**
	 * @description Will check that the error provided is due to a validation rule
	 *
	 * @param error The exception to check
	 * @param dmlType DML Type of the exception
	 */
	@TestVisible
	private static void assertIsCorrectDmlError(Exception error, StatusCode dmlType)
	{
		System.assertEquals(DmlException.class.getName(), error.getTypeName(), 'Exception of the wrong type');
		DmlException dmlError = (DmlException)error;
		System.assertEquals(dmlType, dmlError.getDmlType(0), 'Incorrect DML Type');
	}

	/**
	 * @description Generate a fake/mock Salesforce incremental Id for the given SObjectType
	 *
	 * @param sobjectType as input
	 *
	 * @return incremental id
	 *
	 * @deprecated Method added for backward compatibility on higher environments. Remove method and all references after Object Share is deployed to QAY.
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	public static Id generateIncrementalId(SObjectType sobjectType)
	{
		return CMN_UTIL_Random.randomSObjectId(sobjectType);
	}

	/**
	 * @description Method is use to generate sobject id
	 *
	 * @param sType as input
	 *
	 * @return String
	 *
	 * @deprecated Method added for backward compatibility on higher environments. Remove method and all references after Object Share is deployed to QAY.
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	public static Id generateRandomSObjectId(SObjectType sType)
	{
		return CMN_UTIL_Random.randomSObjectId(sType);
	}
}