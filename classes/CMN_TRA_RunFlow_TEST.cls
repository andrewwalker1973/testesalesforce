/**
 * @description Copyright 2021 Google LLC
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
 * @see CMN_TRA_RunFlow https://github.com/mitchspano/apex-trigger-actions-framework/blob/master/README.md#metadata-driven-trigger-actions
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_TRA_RunFlow_TEST
{
	private static final String MY_ACCOUNT = 'My Account';
	private static final String OLD_NAME = 'Old Name';
	private static final String SAMPLE_FLOW_NAME = 'CMN_FLOW_TriggerRunFlowTest';
	private static Account myAccount = new Account
			(
					Name = MY_ACCOUNT,
					Id = CMN_DAL_SObjectDomain.generateIncrementalId(Schema.Account.SObjectType)
			);
	private static Account oldAccount = new Account
			(
					Name = OLD_NAME,
					Id = myAccount.Id
			);

	@IsTest
	private static void beforeInsert()
	{
		Exception myException;
		Test.startTest();
		CMN_TRA_RunFlow triggerActionFlow = new CMN_TRA_RunFlow();
		triggerActionFlow.flowName = SAMPLE_FLOW_NAME;
		try
		{
			triggerActionFlow.beforeInsert(new List<SObject> {myAccount});
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(
				null,
				myException,
				'There should be no exception thrown when this method is called with a valid flow.'
		);
	}

	@IsTest
	private static void afterInsert()
	{
		Exception myException;
		Test.startTest();
		CMN_TRA_RunFlow triggerActionFlow = new CMN_TRA_RunFlow();
		triggerActionFlow.flowName = SAMPLE_FLOW_NAME;
		try
		{
			triggerActionFlow.afterInsert(new List<SObject> {myAccount});
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(
				null,
				myException,
				'There should be no exception thrown when this method is called with a valid flow.'
		);
	}

	@IsTest
	private static void beforeUpdate()
	{
		Exception myException;
		Test.startTest();
		CMN_TRA_RunFlow triggerActionFlow = new CMN_TRA_RunFlow();
		triggerActionFlow.flowName = SAMPLE_FLOW_NAME;
		try
		{
			triggerActionFlow.beforeUpdate(
					new List<SObject> {myAccount},
					new List<SObject> {myAccount}
			);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(
				null,
				myException,
				'There should be no exception thrown when this method is called with a valid flow.'
		);
	}
	@IsTest
	private static void afterUpdate()
	{
		Exception myException;
		Test.startTest();
		CMN_TRA_RunFlow triggerActionFlow = new CMN_TRA_RunFlow();
		triggerActionFlow.flowName = SAMPLE_FLOW_NAME;
		try
		{
			triggerActionFlow.afterUpdate(
					new List<SObject> {myAccount},
					new List<SObject> {myAccount}
			);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(
				null,
				myException,
				'There should be no exception thrown when this method is called with a valid flow.'
		);
	}
	@IsTest
	private static void beforeDelete()
	{
		Exception myException;
		Test.startTest();
		CMN_TRA_RunFlow triggerActionFlow = new CMN_TRA_RunFlow();
		triggerActionFlow.flowName = SAMPLE_FLOW_NAME;
		try
		{
			triggerActionFlow.beforeDelete(new List<SObject> {myAccount});
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(
				null,
				myException,
				'There should be no exception thrown when this method is called with a valid flow.'
		);
	}
	@IsTest
	private static void afterDelete()
	{
		Exception myException;
		Test.startTest();
		CMN_TRA_RunFlow triggerActionFlow = new CMN_TRA_RunFlow();
		triggerActionFlow.flowName = SAMPLE_FLOW_NAME;
		try
		{
			triggerActionFlow.afterDelete(new List<SObject> {myAccount});
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(
				null,
				myException,
				'There should be no exception thrown when this method is called with a valid flow.'
		);
	}
	@IsTest
	private static void afterUndelete()
	{
		Exception myException;
		Test.startTest();
		CMN_TRA_RunFlow triggerActionFlow = new CMN_TRA_RunFlow();
		triggerActionFlow.flowName = SAMPLE_FLOW_NAME;
		try
		{
			triggerActionFlow.afterUndelete(new List<SObject> {myAccount});
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(
				null,
				myException,
				'There should be no exception thrown when this method is called with a valid flow.'
		);
	}
}