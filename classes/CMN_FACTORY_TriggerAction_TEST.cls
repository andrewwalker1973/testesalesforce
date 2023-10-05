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
 * @see CMN_FACTORY_TriggerAction https://github.com/mitchspano/apex-trigger-actions-framework/blob/master/README.md#metadata-driven-trigger-actions
 *
 * @author mitchspano, jason.van.beukering@accenture.com
 *
 * @date June 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity')
private class CMN_FACTORY_TriggerAction_TEST
{
	private static final String ACCOUNT_OBJECT_NAME = CMN_DAL_Account.OBJECT_NAME;
	private static final String BOGUS_CLASS_NAME = 'Bogus';
	private static final String MY_ACCOUNT = 'My Account';
	private static final String TEST_AFTER_DELETE = CMN_FACTORY_TriggerAction_TEST.class.getName() + '.TestAfterDelete';
	private static final String TEST_AFTER_INSERT = CMN_FACTORY_TriggerAction_TEST.class.getName() + '.TestAfterInsert';
	private static final String TEST_AFTER_UNDELETE = CMN_FACTORY_TriggerAction_TEST.class.getName() + '.TestAfterUndelete';
	private static final String TEST_AFTER_UPDATE = CMN_FACTORY_TriggerAction_TEST.class.getName() + '.TestAfterUpdate';
	private static final String TEST_BEFORE_DELETE = CMN_FACTORY_TriggerAction_TEST.class.getName() + '.TestBeforeDelete';
	private static final String TEST_BEFORE_INSERT = CMN_FACTORY_TriggerAction_TEST.class.getName() + '.TestBeforeInsert';
	private static final String TEST_BEFORE_UPDATE = CMN_FACTORY_TriggerAction_TEST.class.getName() + '.TestBeforeUpdate';

	private static Account myAccount = new Account
			(
					Name = MY_ACCOUNT,
					Id = CMN_UTIL_Random.randomSObjectId(Account.SObjectType)
			);
	private static CMN_TriggerSetting__mdt setting = new CMN_TriggerSetting__mdt
			(
					CMN_ObjectApiName__c = ACCOUNT_OBJECT_NAME,
					Id = CMN_UTIL_Random.randomSObjectId(CMN_TriggerSetting__mdt.SObjectType)
			);
	private static CMN_FACTORY_TriggerAction handler = new CMN_FACTORY_TriggerAction();

	@IsTest
	private static void beforeInsert()
	{
		handler.triggerNew = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_BEFORE_INSERT,
				Before_Insert__r = setting,
				Before_Insert__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.beforeInsertActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.beforeInsert(handler.triggerNew);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void beforeInsertIncorrectType()
	{
		handler.triggerNew = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_AFTER_INSERT,
				Before_Insert__r = setting,
				Before_Insert__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.beforeInsertActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.beforeInsert(handler.triggerNew);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_TYPE_ERROR,
						new List<String>
						{
								TEST_AFTER_INSERT,
								String.valueOf(System.TriggerOperation.BEFORE_INSERT),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void beforeInsertIncorrectClass()
	{
		handler.triggerNew = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = BOGUS_CLASS_NAME,
				Before_Insert__r = setting,
				Before_Insert__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.beforeInsertActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.beforeInsert(handler.triggerNew);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_CLASS_ERROR,
						new List<String>
						{
								BOGUS_CLASS_NAME,
								String.valueOf(System.TriggerOperation.BEFORE_INSERT),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void afterInsert()
	{
		handler.triggerNew = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_AFTER_INSERT,
				After_Insert__r = setting,
				After_Insert__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterInsertActionMetadata = new List<CMN_TriggerAction__mdt> {action};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterInsert(handler.triggerNew);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void afterInsertIncorrectType()
	{
		handler.triggerNew = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_BEFORE_INSERT,
				After_Insert__r = setting,
				After_Insert__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterInsertActionMetadata = new List<CMN_TriggerAction__mdt> {action};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterInsert(handler.triggerNew);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_TYPE_ERROR,
						new List<String>
						{
								TEST_BEFORE_INSERT,
								String.valueOf(System.TriggerOperation.AFTER_INSERT),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void afterInsertIncorrectClass()
	{
		handler.triggerNew = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = BOGUS_CLASS_NAME,
				After_Insert__r = setting,
				After_Insert__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterInsertActionMetadata = new List<CMN_TriggerAction__mdt> {action};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterInsert(handler.triggerNew);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_CLASS_ERROR,
						new List<String>
						{
								BOGUS_CLASS_NAME,
								String.valueOf(System.TriggerOperation.AFTER_INSERT),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void beforeUpdate()
	{
		handler.triggerNew = new List<Account> {myAccount};
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_BEFORE_UPDATE,
				Before_Update__r = setting,
				Before_Update__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.beforeUpdateActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.beforeUpdate(handler.triggerNew, handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void beforeUpdateIncorrectType()
	{
		handler.triggerNew = new List<Account> {myAccount};
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_BEFORE_INSERT,
				Before_Update__r = setting,
				Before_Update__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.beforeUpdateActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.beforeUpdate(handler.triggerNew, handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_TYPE_ERROR,
						new List<String>
						{
								TEST_BEFORE_INSERT,
								String.valueOf(System.TriggerOperation.BEFORE_UPDATE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void beforeUpdateIncorrectClass()
	{
		handler.triggerNew = new List<Account> {myAccount};
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = BOGUS_CLASS_NAME,
				Before_Update__r = setting,
				Before_Update__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.beforeUpdateActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.beforeUpdate(handler.triggerNew, handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_CLASS_ERROR,
						new List<String>
						{
								BOGUS_CLASS_NAME,
								String.valueOf(System.TriggerOperation.BEFORE_UPDATE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void afterUpdate()
	{
		handler.triggerNew = new List<Account> {myAccount};
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_AFTER_UPDATE,
				After_Update__r = setting,
				After_Update__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterUpdateActionMetadata = new List<CMN_TriggerAction__mdt> {action};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterUpdate(handler.triggerNew, handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void afterUpdateIncorrectType()
	{
		handler.triggerNew = new List<Account> {myAccount};
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_BEFORE_INSERT,
				After_Update__r = setting,
				After_Update__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterUpdateActionMetadata = new List<CMN_TriggerAction__mdt> {action};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterUpdate(handler.triggerNew, handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_TYPE_ERROR,
						new List<String>
						{
								TEST_BEFORE_INSERT,
								String.valueOf(System.TriggerOperation.AFTER_UPDATE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void afterUpdateIncorrectClass()
	{
		handler.triggerNew = new List<Account> {myAccount};
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = BOGUS_CLASS_NAME,
				After_Update__r = setting,
				After_Update__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterUpdateActionMetadata = new List<CMN_TriggerAction__mdt> {action};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterUpdate(handler.triggerNew, handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_CLASS_ERROR,
						new List<String>
						{
								BOGUS_CLASS_NAME,
								String.valueOf(System.TriggerOperation.AFTER_UPDATE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void beforeDelete()
	{
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_BEFORE_DELETE,
				Before_Delete__r = setting,
				Before_Delete__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.beforeDeleteActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.beforeDelete(handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void beforeDeleteIncorrectType()
	{
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_BEFORE_INSERT,
				Before_Delete__r = setting,
				Before_Delete__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.beforeDeleteActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.beforeDelete(handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_TYPE_ERROR,
						new List<String>
						{
								TEST_BEFORE_INSERT,
								String.valueOf(System.TriggerOperation.BEFORE_DELETE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void beforeDeleteIncorrectClass()
	{
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = BOGUS_CLASS_NAME,
				Before_Delete__r = setting,
				Before_Delete__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.beforeDeleteActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.beforeDelete(handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_CLASS_ERROR,
						new List<String>
						{
								BOGUS_CLASS_NAME,
								String.valueOf(System.TriggerOperation.BEFORE_DELETE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void afterDelete()
	{
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_AFTER_DELETE,
				After_Delete__r = setting,
				After_Delete__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterDeleteActionMetadata = new List<CMN_TriggerAction__mdt> {action};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterDelete(handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void afterDeleteIncorrectType()
	{
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_BEFORE_INSERT,
				After_Delete__r = setting,
				After_Delete__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterDeleteActionMetadata = new List<CMN_TriggerAction__mdt> {action};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterDelete(handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_TYPE_ERROR,
						new List<String>
						{
								TEST_BEFORE_INSERT,
								String.valueOf(System.TriggerOperation.AFTER_DELETE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void afterDeleteIncorrectClass()
	{
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = BOGUS_CLASS_NAME,
				After_Delete__r = setting,
				After_Delete__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterDeleteActionMetadata = new List<CMN_TriggerAction__mdt> {action};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterDelete(handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_CLASS_ERROR,
						new List<String>
						{
								BOGUS_CLASS_NAME,
								String.valueOf(System.TriggerOperation.AFTER_DELETE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void afterUndelete()
	{
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_AFTER_UNDELETE,
				After_Undelete__r = setting,
				After_Undelete__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterUndeleteActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterUndelete(handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
	}

	@IsTest
	private static void afterUndeleteIncorrectType()
	{
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = TEST_BEFORE_INSERT,
				After_Undelete__r = setting,
				After_Undelete__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterUndeleteActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterUndelete(handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_TYPE_ERROR,
						new List<String>
						{
								TEST_BEFORE_INSERT,
								String.valueOf(System.TriggerOperation.AFTER_UNDELETE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	@IsTest
	private static void afterUndeleteIncorrectClass()
	{
		handler.triggerOld = new List<Account> {myAccount};
		CMN_TriggerAction__mdt action = new CMN_TriggerAction__mdt(
				Apex_Class_Name__c = BOGUS_CLASS_NAME,
				After_Undelete__r = setting,
				After_Undelete__c = setting.Id,
				Order__c = 1,
				Bypass_Execution__c = false
		);
		handler.afterUndeleteActionMetadata = new List<CMN_TriggerAction__mdt>
		{
				action
		};
		Exception myException;
		Test.startTest();
		try
		{
			handler.afterUndelete(handler.triggerOld);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(null, myException);
		System.assertEquals(
				myException.getMessage(),
				String.format(
						CMN_FACTORY_TriggerAction.INVALID_CLASS_ERROR,
						new List<String>
						{
								BOGUS_CLASS_NAME,
								String.valueOf(System.TriggerOperation.AFTER_UNDELETE),
								ACCOUNT_OBJECT_NAME
						}
				)
		);
	}

	/**
	 * @description Checks that action metadata is fetched in different scenarios
	 */
	@IsTest
	private static void actionMetadata()
	{
		handler.triggerNew = new List<Account> {myAccount};
		handler.triggerOld = new List<Account> {myAccount};
		System.assertNotEquals(null, handler.beforeInsertActionMetadata);
		System.assertNotEquals(null, handler.afterInsertActionMetadata);
		System.assertNotEquals(null, handler.beforeUpdateActionMetadata);
		System.assertNotEquals(null, handler.afterUpdateActionMetadata);
		System.assertNotEquals(null, handler.beforeDeleteActionMetadata);
		System.assertNotEquals(null, handler.afterDeleteActionMetadata);
		System.assertNotEquals(null, handler.afterUndeleteActionMetadata);
	}

	/**
	 * @description Checks that action metadata is fetched for Foobar
	 */
	@IsTest
	private static void foobarActionMetadata()
	{
		CMN_Foobar__c cmnFoobar = CMN_DAL_DataFactory.newFoobar();
		handler.triggerNew = new List<CMN_Foobar__c> {cmnFoobar};
		handler.triggerOld = new List<CMN_Foobar__c> {cmnFoobar};
		System.assertNotEquals(null, handler.beforeInsertActionMetadata);
	}

	@IsTest
	private static void bypass()
	{
		Exception myException;
		Test.startTest();
		try
		{
			CMN_FACTORY_TriggerAction.bypass(TEST_BEFORE_INSERT);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
		System.assert(
				CMN_FACTORY_TriggerAction.bypassedActions.contains(TEST_BEFORE_INSERT)
		);
	}

	@IsTest
	private static void clearBypass()
	{
		Exception myException;
		Test.startTest();
		try
		{
			CMN_FACTORY_TriggerAction.bypass(TEST_BEFORE_INSERT);
			CMN_FACTORY_TriggerAction.clearBypass(TEST_BEFORE_INSERT);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
		System.assert(
				!CMN_FACTORY_TriggerAction.bypassedActions.contains(TEST_BEFORE_INSERT)
		);
	}

	@IsTest
	private static void isBypassed()
	{
		Boolean isBypassed;
		CMN_FACTORY_TriggerAction.bypass(TEST_BEFORE_INSERT);
		Exception myException;
		Test.startTest();
		try
		{
			isBypassed = CMN_FACTORY_TriggerAction.isBypassed(TEST_BEFORE_INSERT);
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
		CMN_FACTORY_TriggerAction.bypass(TEST_BEFORE_INSERT);
		Exception myException;
		Test.startTest();
		try
		{
			CMN_FACTORY_TriggerAction.clearAllBypasses();
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertEquals(null, myException);
		System.assertEquals(0, CMN_FACTORY_TriggerAction.bypassedActions.size());
	}

	@SuppressWarnings('PMD.ApexDoc, ApexUnusedDeclaration, ApexDocValidation')
	public class TestBeforeInsert implements CMN_TRA_Interfaces.CMN_INT_BeforeInsert
	{
		public void beforeInsert(List<SObject> newList)
		{
		}
	}

	@SuppressWarnings('PMD.ApexDoc, ApexUnusedDeclaration, ApexDocValidation')
	public class TestAfterInsert implements CMN_TRA_Interfaces.CMN_INT_AfterInsert
	{
		public void afterInsert(List<SObject> newList)
		{
		}
	}

	@SuppressWarnings('PMD.ApexDoc, ApexUnusedDeclaration, ApexDocValidation')
	public class TestBeforeUpdate implements CMN_TRA_Interfaces.CMN_INT_BeforeUpdate
	{
		public void beforeUpdate(List<SObject> newList, List<SObject> oldList)
		{
		}
	}

	@SuppressWarnings('PMD.ApexDoc, ApexUnusedDeclaration, ApexDocValidation')
	public class TestAfterUpdate implements CMN_TRA_Interfaces.CMN_INT_AfterUpdate
	{
		public void afterUpdate(List<SObject> newList, List<SObject> oldList)
		{
		}
	}

	@SuppressWarnings('PMD.ApexDoc, ApexUnusedDeclaration, ApexDocValidation')
	public class TestBeforeDelete implements CMN_TRA_Interfaces.CMN_INT_BeforeDelete
	{
		public void beforeDelete(List<SObject> oldList)
		{
		}
	}

	@SuppressWarnings('PMD.ApexDoc, ApexUnusedDeclaration, ApexDocValidation')
	public class TestAfterDelete implements CMN_TRA_Interfaces.CMN_INT_AfterDelete
	{
		public void afterDelete(List<SObject> newList)
		{
		}
	}

	@SuppressWarnings('PMD.ApexDoc, ApexUnusedDeclaration, ApexDocValidation')
	public class TestAfterUndelete implements CMN_TRA_Interfaces.CMN_INT_AfterUndelete
	{
		public void afterUndelete(List<SObject> newList)
		{
		}
	}
}