/**
 * @description Test class related to the SC_CTRL_CreateTask
 *
 * @see SC_CTRL_CreateTask @story ST-308231
 *
 * @author uttpal.chandra@accenture.com
 *
 * @date October 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SC_CTRL_CreateTask_TEST
{
	private static final Integer INT_ONE = 1;
	/**
	 * @description Create data required for the unit test
	 */
	@TestSetup
	private static void setup()
	{
		AW_DAL_TestDataFactory.createMasterPersonAccount().iterator().next();
	}

	/**
	 * @description To get picklist value of given object and field
	 *
	 * @see SC_CTRL_CreateTask.getPicklistLabel
	 */
	@IsTest
	private static void getPickListLabel()
	{
		User foundAgent = SC_DAL_User.findRandomActiveAgent();

		System.runAs(foundAgent)
		{
			Test.startTest();

			Map<String, String> valueMap = SC_CTRL_CreateTask.getPicklistLabel(AW_DAL_Task.FIELD_SUBJECT);

			Test.stopTest();

			Assert.isFalse(valueMap.isEmpty(), 'No picklist value found');
		}
	}

	/**
	 * @description Test method to create Task
	 *
	 * @see SC_CTRL_CreateTask.createTask
	 */
	@IsTest
	private static void createTask()
	{
		User foundAgent = SC_DAL_User.findRandomActiveAgent();
		Case newCase = SC_DAL_DataFactory.newCase(SC_DAL_Account.getAll().iterator().next().Id);
		newCase.OwnerId = foundAgent.Id;
		insert newCase;

		Task newTask = new Task();

		System.runAs(foundAgent)
		{
			newTask.ReminderDateTime = CMN_DAL_SObjectDomain.generateRandomDateTime();
			newTask.Subject = CMN_DAL_SObjectDomain.generateRandomName();
			newTask.Description = CMN_DAL_SObjectDomain.generateRandomDescription();
			newTask.WhatId = newCase.Id;

			Test.startTest();

			SC_CTRL_CreateTask.createTask(newTask);

			Test.stopTest();

		}

		Task foundTask = AW_DAL_Task.getAll().iterator().next();

		Assert.areEqual(newTask.Id, foundTask.Id, 'Task record created');
	}

	/**
	 * @description Test method to compare Date Time
	 *
	 * @see SC_CTRL_CreateTask.compareTime
	 */
	@IsTest
	private static void compareDateTime()
	{
		User foundAgent = SC_DAL_User.findRandomActiveAgent();

		System.runAs(foundAgent)
		{
			Test.startTest();

			Boolean checkTime = SC_CTRL_CreateTask.compareTime(System.now(),INT_ONE);

			Test.stopTest();

			Assert.isFalse(checkTime, 'Reminder Date Time cannot be older than Current Date Time');
		}
	}
}