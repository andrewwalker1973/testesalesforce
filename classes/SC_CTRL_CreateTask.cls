/**
 * @description This class is used to by components to create Log A Call
 *
 * @see SC_CTRL_CreateTask_TEST @story ST-308231
 *
 * @author uttpal.chandra@accenture.com
 *
 * @date November 2022
 */
public inherited sharing class SC_CTRL_CreateTask
{
	private static final Integer NUMBER_OF_SECONDS = 1000;

	/**
	 * @description Will return a list of pick list values for outbound tasks
	 *
	 * @param fieldName the name of the field from which to retrieve the picklist values
	 *
	 * @return A map of found pick list items Map<labelName, apiName>
	 */
	@AuraEnabled(Cacheable=true)
	public static Map<String, String> getPicklistLabel(String fieldName)
	{
		Map<String, String> picklistValue = CMN_UTIL_System.getPicklistEntriesMap(Task.SObjectType, fieldName);

		Map<String, String> filterPicklistValue = new Map<String, String>();
		for(String picklist : picklistValue.keySet())
		{
			if(picklistValue.get(picklist).startsWith(AW_DAL_Task.RT_OUTBOUND_TASK + '_'))
			{
				filterPicklistValue.put(picklist, picklistValue.get(picklist));
			}
		}

		return filterPicklistValue;
	}

	/**
	 * @description This method will create Task record
	 *
	 * @param taskDetail Contains task record
	 *
	 * @return newly committed task record
	 */
	@AuraEnabled
	public static Boolean createTask(Task taskDetail)
	{
		Boolean isSuccess = false;
		taskDetail.Status = AW_DAL_Task.STATUS_COMPLETED;
		taskDetail.TaskSubtype = AW_DAL_Task.PICK_CALL;
		taskDetail.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Task.SObjectType, AW_DAL_Task.RT_OUTBOUND_TASK);

		Database.SaveResult saveResults = CMN_DAL_SObjectDomain.insertDBObject(taskDetail,false);

		if(saveResults.isSuccess())
		{
			isSuccess = true;
		}
		return isSuccess;
	}

	/**
	 * @description This method validates the DateTime input by the user with Current Date Time and from future Date Time
	 *
	 * @param userDateTime Contains DateTime entered by User
	 *
	 *@param numberOfMonths Contains number of months
	 *
	 * @return Boolean
	 */
	@AuraEnabled
	public static Boolean compareTime(Datetime userDateTime , Integer numberOfMonths)
	{
		Boolean isSuccess = true;
		userDateTime = getCurrentUserDateTime(userDateTime);
		Datetime currentTimeRecord = getCurrentUserDateTime(System.now());

		Datetime futureTimeRecord = getCurrentUserDateTime(System.now().addMonths(numberOfMonths));

		if(userDateTime < currentTimeRecord || userDateTime > futureTimeRecord)
		{
			isSuccess = false;
		}
		return isSuccess;
	}

	/**
	 * @description This method will return current user DateTime
	 *
	 * @param dateTimeRecord Contains DateTime
	 *
	 * @return The current date time for the calling user
	 */
	@AuraEnabled
	public static Datetime getCurrentUserDateTime(Datetime dateTimeRecord)
	{
		Integer offset = UserInfo.getTimeZone().getOffset(dateTimeRecord);
		return dateTimeRecord.addSeconds(offset / NUMBER_OF_SECONDS);
	}
}