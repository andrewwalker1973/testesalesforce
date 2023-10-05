/**
 * @description Copyright 2020 Google LLC
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * https://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @see CMN_TRA_BaseObject https://github.com/mitchspano/apex-trigger-actions-framework/blob/master/README.md#metadata-driven-trigger-actions
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_TRA_BaseObject_TEST
{
	private static final String ACCOUNT_OBJECT_NAME = 'Account';
	private static final Account MY_ACCOUNT = new Account
			(
					Id = CMN_UTIL_Random.randomSObjectId(Account.SObjectType),
					Name = 'My Account'
			);
	private static BaseTest base = new BaseTest();

	@IsTest
	private static void beforeInsert()
	{
		MY_ACCOUNT.Id = null;
		Exception myException;
		Test.startTest();
		base.context = System.TriggerOperation.BEFORE_INSERT;
		base.triggerNew = new List<SObject> {MY_ACCOUNT};
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void afterInsert()
	{
		Exception myException;
		Test.startTest();
		base.context = System.TriggerOperation.AFTER_INSERT;
		base.triggerNew = new List<SObject> {MY_ACCOUNT};
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void beforeUpdate()
	{
		Exception myException;
		Test.startTest();
		base.context = System.TriggerOperation.BEFORE_UPDATE;
		base.triggerNew = new List<SObject> {MY_ACCOUNT};
		base.triggerOld = new List<SObject> {MY_ACCOUNT};
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void afterUpdate()
	{
		Exception myException;
		Test.startTest();
		base.context = System.TriggerOperation.AFTER_UPDATE;
		base.triggerNew = new List<SObject> {MY_ACCOUNT};
		base.triggerOld = new List<SObject> {MY_ACCOUNT};
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void beforeDelete()
	{
		Exception myException;
		Test.startTest();
		base.context = System.TriggerOperation.BEFORE_DELETE;
		base.triggerOld = new List<SObject> {MY_ACCOUNT};
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void afterDelete()
	{
		Exception myException;
		Test.startTest();
		base.context = System.TriggerOperation.AFTER_DELETE;
		base.triggerOld = new List<SObject> {MY_ACCOUNT};
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void afterUndelete()
	{
		Exception myException;
		Test.startTest();
		base.context = System.TriggerOperation.AFTER_UNDELETE;
		base.triggerNew = new List<SObject> {MY_ACCOUNT};
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void idToNumberOfTimesSeenBeforeUpdate()
	{
		Exception myException;
		Test.startTest();
		base.context = System.TriggerOperation.BEFORE_UPDATE;
		base.triggerNew = new List<SObject> {MY_ACCOUNT};
		base.triggerOld = new List<SObject> {MY_ACCOUNT};
		try
		{
			base.run();
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(
				2,
				CMN_TRA_BaseObject.idToNumberOfTimesSeenBeforeUpdate.get(MY_ACCOUNT.Id)
		);
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void idToNumberOfTimesSeenAfterUpdate()
	{
		Exception myException;
		Test.startTest();
		base.context = System.TriggerOperation.AFTER_UPDATE;
		base.triggerNew = new List<SObject> {MY_ACCOUNT};
		base.triggerOld = new List<SObject> {MY_ACCOUNT};
		try
		{
			base.run();
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(
				2,
				CMN_TRA_BaseObject.idToNumberOfTimesSeenAfterUpdate.get(MY_ACCOUNT.Id)
		);
		System.assertEquals(null, myException);
	}

	/**
	 * @description Tests that exception handling occurs as expected
	 */
	@IsTest
	private static void runFail()
	{
		CMN_DAL_Logger.ignoreTestMode = true;

		Exception myException;
		Test.startTest();
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();

		System.assertNotEquals(null, myException, 'myException should not be null');
		System.assertEquals(CMN_TRA_BaseObject.HANDLER_OUTSIDE_TRIGGER_MESSAGE, myException.getMessage(), 'Incorrect exception message found');

		CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod
				(
						String.format
								(
										CMN_TRA_BaseObject.CLASS_METHOD_FORMAT,
										new List<String> {CMN_UTIL_String.EMPTY, CMN_UTIL_String.EMPTY}
								)
				);

		System.assertNotEquals(null, appLog, 'No App Log found');
		System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c, 'Incorrect error level found');
		System.assertEquals(CMN_TRA_BaseObject.TriggerBaseException.class.getName(), appLog.CMN_ExceptionType__c, 'Incorrect exception type found');
	}

	@IsTest
	private static void runTrue()
	{
		MY_ACCOUNT.Id = null;
		Exception myException;
		base.context = System.TriggerOperation.BEFORE_INSERT;
		base.triggerNew = new List<SObject> {MY_ACCOUNT};
		Test.startTest();
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
		System.assertEquals(true, base.hasBeenExecuted);
	}

	@IsTest
	private static void runFalse()
	{
		MY_ACCOUNT.Id = null;
		CMN_TRA_BaseObject.bypass(ACCOUNT_OBJECT_NAME);
		Exception myException;
		base.context = System.TriggerOperation.BEFORE_INSERT;
		base.triggerNew = new List<SObject> {MY_ACCOUNT};
		Test.startTest();
		try
		{
			base.run();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
		System.assertEquals(false, base.hasBeenExecuted);
	}

	@IsTest
	private static void bypass()
	{
		Exception myException;
		Test.startTest();
		try
		{
			CMN_TRA_BaseObject.bypass(ACCOUNT_OBJECT_NAME);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
		System.assert(CMN_TRA_BaseObject.bypassedObjects.contains(ACCOUNT_OBJECT_NAME));
	}

	@IsTest
	private static void clearBypass()
	{
		Exception myException;
		Test.startTest();
		try
		{
			CMN_TRA_BaseObject.bypass(ACCOUNT_OBJECT_NAME);
			CMN_TRA_BaseObject.clearBypass(ACCOUNT_OBJECT_NAME);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
		System.assert(!CMN_TRA_BaseObject.bypassedObjects.contains(ACCOUNT_OBJECT_NAME));
	}

	@IsTest
	private static void isBypassed()
	{
		Boolean isBypassed;
		CMN_TRA_BaseObject.bypass(ACCOUNT_OBJECT_NAME);
		Exception myException;
		Test.startTest();
		try
		{
			isBypassed = CMN_TRA_BaseObject.isBypassed(ACCOUNT_OBJECT_NAME);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
		System.assertEquals(true, isBypassed);
	}

	@IsTest
	private static void clearAllBypasses()
	{
		CMN_TRA_BaseObject.bypass(ACCOUNT_OBJECT_NAME);
		Exception myException;
		Test.startTest();
		try
		{
			CMN_TRA_BaseObject.clearAllBypasses();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
		System.assertEquals(0, CMN_TRA_BaseObject.bypassedObjects.size());
	}

	@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
	private class BaseTest extends CMN_TRA_BaseObject implements CMN_TRA_Interfaces.CMN_INT_BeforeInsert, CMN_TRA_Interfaces.CMN_INT_AfterInsert,
			CMN_TRA_Interfaces.CMN_INT_BeforeUpdate, CMN_TRA_Interfaces.CMN_INT_AfterUpdate, CMN_TRA_Interfaces.CMN_INT_BeforeDelete,
			CMN_TRA_Interfaces.CMN_INT_AfterDelete, CMN_TRA_Interfaces.CMN_INT_AfterUndelete
	{
		public Boolean hasBeenExecuted = false;
		public void beforeInsert(List<SObject> newList)
		{
			this.hasBeenExecuted = true;
		}
		public void afterInsert(List<SObject> newList)
		{
			this.hasBeenExecuted = true;
		}
		public void beforeUpdate(List<SObject> newList, List<SObject> oldList)
		{
			this.hasBeenExecuted = true;
		}
		public void afterUpdate(List<SObject> newList, List<SObject> oldList)
		{
			this.hasBeenExecuted = true;
		}
		public void beforeDelete(List<SObject> oldList)
		{
			this.hasBeenExecuted = true;
		}
		public void afterDelete(List<SObject> newList)
		{
			this.hasBeenExecuted = true;
		}
		public void afterUndelete(List<SObject> newList)
		{
			this.hasBeenExecuted = true;
		}
	}
}