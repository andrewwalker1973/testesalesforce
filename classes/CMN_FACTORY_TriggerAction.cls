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
 * @see CMN_FACTORY_TriggerAction_TEST https://github.com/mitchspano/apex-trigger-actions-framework/blob/master/README.md#metadata-driven-trigger-actions
 *
 * @author mitchspano, jason.van.beukering@accenture.com
 *
 * @date June 2022
 */
@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
public inherited sharing class CMN_FACTORY_TriggerAction extends CMN_TRA_BaseObject implements CMN_TRA_Interfaces.CMN_INT_BeforeInsert,
		CMN_TRA_Interfaces.CMN_INT_AfterInsert, CMN_TRA_Interfaces.CMN_INT_BeforeUpdate, CMN_TRA_Interfaces.CMN_INT_AfterUpdate,
		CMN_TRA_Interfaces.CMN_INT_BeforeDelete, CMN_TRA_Interfaces.CMN_INT_AfterDelete, CMN_TRA_Interfaces.CMN_INT_AfterUndelete
{
	@TestVisible
	private static Set<String> bypassedActions = new Set<String>();

	public void beforeInsert(List<SObject> newList)
	{
		this.executeActions(TriggerOperation.BEFORE_INSERT, newList, null);
	}

	public void afterInsert(List<SObject> newList)
	{
		this.executeActions(TriggerOperation.AFTER_INSERT, newList, null);
	}

	public void beforeUpdate(List<SObject> newList, List<SObject> oldList)
	{
		this.executeActions(TriggerOperation.BEFORE_UPDATE, newList, oldList);
	}

	public void afterUpdate(List<SObject> newList, List<SObject> oldList)
	{
		this.executeActions(TriggerOperation.AFTER_UPDATE, newList, oldList);
	}

	public void beforeDelete(List<SObject> oldList)
	{
		this.executeActions(TriggerOperation.BEFORE_DELETE, null, oldList);
	}

	public void afterDelete(List<SObject> oldList)
	{
		this.executeActions(TriggerOperation.AFTER_DELETE, null, oldList);
	}

	public void afterUndelete(List<SObject> newList)
	{
		this.executeActions(TriggerOperation.AFTER_UNDELETE, newList, null);
	}

	private void executeActions(TriggerOperation context, List<SObject> newList, List<SObject> oldList)
	{
		List<CMN_TriggerAction__mdt> actionMetadata;

		switch on context
		{
			when BEFORE_INSERT
			{
				actionMetadata = this.beforeInsertActionMetadata;
			}
			when AFTER_INSERT
			{
				actionMetadata = this.afterInsertActionMetadata;
			}
			when BEFORE_UPDATE
			{
				actionMetadata = this.beforeUpdateActionMetadata;
			}
			when AFTER_UPDATE
			{
				actionMetadata = this.afterUpdateActionMetadata;
			}
			when BEFORE_DELETE
			{
				actionMetadata = this.beforeDeleteActionMetadata;
			}
			when AFTER_DELETE
			{
				actionMetadata = this.afterDeleteActionMetadata;
			}
			when AFTER_UNDELETE
			{
				actionMetadata = this.afterUndeleteActionMetadata;
			}
		}
		for(CMN_TriggerAction__mdt triggerMetadata : actionMetadata)
		{
			Object triggerAction;
			try
			{
				triggerAction = Type.forName(triggerMetadata.Apex_Class_Name__c).newInstance();

				if(triggerMetadata.Flow_Name__c != null)
				{
					((CMN_TRA_RunFlow)triggerAction).flowName = triggerMetadata.Flow_Name__c;
					((CMN_TRA_RunFlow)triggerAction).allowRecursion = triggerMetadata.Allow_Flow_Recursion__c;
				}
			}
			catch(System.NullPointerException e)
			{
				handleException(INVALID_CLASS_ERROR, triggerMetadata.Apex_Class_Name__c, context);
			}

			if(!CMN_FACTORY_TriggerAction.isBypassed(triggerMetadata.Apex_Class_Name__c) && !CMN_TRA_BaseObject.isBypassed(this.sObjectName))
			{
				this.validateType(context, triggerAction, triggerMetadata.Apex_Class_Name__c);

				switch on context
				{
					when BEFORE_INSERT
					{
						((CMN_TRA_Interfaces.CMN_INT_BeforeInsert)triggerAction).beforeInsert(newList);
					}
					when AFTER_INSERT
					{
						((CMN_TRA_Interfaces.CMN_INT_AfterInsert)triggerAction).afterInsert(newList);
					}
					when BEFORE_UPDATE
					{
						((CMN_TRA_Interfaces.CMN_INT_BeforeUpdate)triggerAction).beforeUpdate(newList, oldList);
					}
					when AFTER_UPDATE
					{
						((CMN_TRA_Interfaces.CMN_INT_AfterUpdate)triggerAction).afterUpdate(newList, oldList);
					}
					when BEFORE_DELETE
					{
						((CMN_TRA_Interfaces.CMN_INT_BeforeDelete)triggerAction).beforeDelete(oldList);
					}
					when AFTER_DELETE
					{
						((CMN_TRA_Interfaces.CMN_INT_AfterDelete)triggerAction).afterDelete(oldList);
					}
					when AFTER_UNDELETE
					{
						((CMN_TRA_Interfaces.CMN_INT_AfterUndelete)triggerAction).afterUndelete(newList);
					}
				}
			}
		}
	}

	private void validateType(TriggerOperation context, Object triggerAction, String className)
	{
		try
		{
			switch on context
			{
				when BEFORE_INSERT
				{
					triggerAction = ((CMN_TRA_Interfaces.CMN_INT_BeforeInsert)triggerAction);
				}
				when AFTER_INSERT
				{
					triggerAction = ((CMN_TRA_Interfaces.CMN_INT_AfterInsert)triggerAction);
				}
				when BEFORE_UPDATE
				{
					triggerAction = ((CMN_TRA_Interfaces.CMN_INT_BeforeUpdate)triggerAction);
				}
				when AFTER_UPDATE
				{
					triggerAction = ((CMN_TRA_Interfaces.CMN_INT_AfterUpdate)triggerAction);
				}
				when BEFORE_DELETE
				{
					triggerAction = ((CMN_TRA_Interfaces.CMN_INT_BeforeDelete)triggerAction);
				}
				when AFTER_DELETE
				{
					triggerAction = ((CMN_TRA_Interfaces.CMN_INT_AfterDelete)triggerAction);
				}
				when AFTER_UNDELETE
				{
					triggerAction = ((CMN_TRA_Interfaces.CMN_INT_AfterUndelete)triggerAction);
				}
			}
		}
		catch(System.TypeException e)
		{
			handleException(INVALID_TYPE_ERROR, className, context);
		}
	}

	@TestVisible
	private List<CMN_TriggerAction__mdt> beforeInsertActionMetadata
	{
		get
		{
			if(beforeInsertActionMetadata == null)
			{
				beforeInsertActionMetadata = CMN_DAL_TriggerAction.findActiveByObjectNameAndTriggerOperation(sObjectName, TriggerOperation.BEFORE_INSERT);
			}

			return beforeInsertActionMetadata;
		}
		set;
	}

	@TestVisible
	private List<CMN_TriggerAction__mdt> afterInsertActionMetadata
	{
		get
		{
			if(afterInsertActionMetadata == null)
			{

				afterInsertActionMetadata = CMN_DAL_TriggerAction.findActiveByObjectNameAndTriggerOperation(sObjectName, TriggerOperation.AFTER_INSERT);
			}

			return afterInsertActionMetadata;
		}
		set;
	}

	@TestVisible
	private List<CMN_TriggerAction__mdt> beforeUpdateActionMetadata
	{
		get
		{
			if(beforeUpdateActionMetadata == null)
			{
				beforeUpdateActionMetadata = CMN_DAL_TriggerAction.findActiveByObjectNameAndTriggerOperation(sObjectName, TriggerOperation.BEFORE_UPDATE);
			}

			return beforeUpdateActionMetadata;
		}
		set;
	}

	@TestVisible
	private List<CMN_TriggerAction__mdt> afterUpdateActionMetadata
	{
		get
		{
			if(afterUpdateActionMetadata == null)
			{
				afterUpdateActionMetadata = CMN_DAL_TriggerAction.findActiveByObjectNameAndTriggerOperation(sObjectName, TriggerOperation.AFTER_UPDATE);
			}

			return afterUpdateActionMetadata;
		}
		set;
	}

	@TestVisible
	private List<CMN_TriggerAction__mdt> beforeDeleteActionMetadata
	{
		get
		{
			if(beforeDeleteActionMetadata == null)
			{
				beforeDeleteActionMetadata = CMN_DAL_TriggerAction.findActiveByObjectNameAndTriggerOperation(sObjectName, TriggerOperation.BEFORE_DELETE);
			}

			return beforeDeleteActionMetadata;
		}
		set;
	}

	@TestVisible
	private List<CMN_TriggerAction__mdt> afterDeleteActionMetadata
	{
		get
		{
			if(afterDeleteActionMetadata == null)
			{
				afterDeleteActionMetadata = CMN_DAL_TriggerAction.findActiveByObjectNameAndTriggerOperation(sObjectName, TriggerOperation.AFTER_DELETE);
			}

			return afterDeleteActionMetadata;
		}
		set;
	}

	@TestVisible
	private List<CMN_TriggerAction__mdt> afterUndeleteActionMetadata
	{
		get
		{
			if(afterUndeleteActionMetadata == null)
			{
				afterUndeleteActionMetadata = CMN_DAL_TriggerAction.findActiveByObjectNameAndTriggerOperation(sObjectName, TriggerOperation.AFTER_UNDELETE);
			}

			return afterUndeleteActionMetadata;
		}
		set;
	}

	private void handleException(String error, String className, TriggerOperation triggerOperation
	)
	{
		throw new MetadataTriggerHandlerException
				(
						String.format(error,
								new List<String>
								{
										className,
										String.valueOf(triggerOperation),
										this.sObjectName
								}
						)
				);
	}

	@SuppressWarnings('ApexUnusedDeclaration')
	public static void bypass(String actionName)
	{
		CMN_FACTORY_TriggerAction.bypassedActions.add(actionName);
	}

	@SuppressWarnings('ApexUnusedDeclaration')
	public static void clearBypass(String actionName)
	{
		CMN_FACTORY_TriggerAction.bypassedActions.remove(actionName);
	}

	@SuppressWarnings('ApexUnusedDeclaration')
	public static Boolean isBypassed(String actionName)
	{
		return CMN_FACTORY_TriggerAction.bypassedActions.contains(actionName);
	}

	@SuppressWarnings('ApexUnusedDeclaration')
	public static void clearAllBypasses()
	{
		CMN_FACTORY_TriggerAction.bypassedActions.clear();
	}

	@TestVisible
	private static final String INVALID_TYPE_ERROR = 'Please check the Trigger Action Custom Metadata for the {1} context on the {2} sObject. ' +
			'The {0} class does not implement the Trigger Action interface specified for the {1} context.';

	@TestVisible
	private static final String INVALID_CLASS_ERROR = 'Please check the Trigger Action Custom Metadata for the {1} context on the {2} sObject. ' +
			'The {0} class does not exist.';

	class MetadataTriggerHandlerException extends Exception
	{
	}
}