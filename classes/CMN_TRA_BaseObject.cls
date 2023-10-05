/**
 * @description Copyright 2020 Google LLC
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @see CMN_TRA_BaseObject_TEST https://github.com/mitchspano/apex-trigger-actions-framework/blob/master/README.md#metadata-driven-trigger-actions
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
@SuppressWarnings('PMD.ApexDoc,ApexDocValidation')
public inherited sharing virtual class CMN_TRA_BaseObject
{
	@TestVisible
	private static final String CLASS_METHOD_FORMAT = 'CMN_TRA_BaseObject/run for {0} {1}';
	@TestVisible
	private static final String HANDLER_OUTSIDE_TRIGGER_MESSAGE = 'Trigger handler called outside of Trigger execution';
	@TestVisible
	private static Set<String> bypassedObjects;
	@TestVisible
	public static Map<Id, Integer> idToNumberOfTimesSeenBeforeUpdate
	{
		get;
		private set;
	}
	@TestVisible
	public static Map<Id, Integer> idToNumberOfTimesSeenAfterUpdate
	{
		get;
		private set;
	}

	static
	{
		bypassedObjects = new Set<String>();
		idToNumberOfTimesSeenBeforeUpdate = new Map<Id, Integer>();
		idToNumberOfTimesSeenAfterUpdate = new Map<Id, Integer>();
	}

	@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
	public void run()
	{
		try
		{
			if(!validateRun())
			{
				return;
			}
			if(
					this.context == System.TriggerOperation.BEFORE_INSERT && this instanceof CMN_TRA_Interfaces.CMN_INT_BeforeInsert
			)
			{
				((CMN_TRA_Interfaces.CMN_INT_BeforeInsert)this).beforeInsert(triggerNew);
			}
			else if(
					this.context == System.TriggerOperation.AFTER_INSERT &&
							this instanceof CMN_TRA_Interfaces.CMN_INT_AfterInsert
			)
			{
				((CMN_TRA_Interfaces.CMN_INT_AfterInsert)this).afterInsert(triggerNew);
			}
			else if(
					this.context == System.TriggerOperation.BEFORE_UPDATE &&
							this instanceof CMN_TRA_Interfaces.CMN_INT_BeforeUpdate
			)
			{
				for(SObject obj : triggerNew)
				{
					if(!idToNumberOfTimesSeenBeforeUpdate.containsKey(obj.Id))
					{
						idToNumberOfTimesSeenBeforeUpdate.put(obj.Id, 1);
					}
					else
					{
						idToNumberOfTimesSeenBeforeUpdate.put(obj.Id, idToNumberOfTimesSeenBeforeUpdate.get(obj.Id) + 1);
					}
				}
				((CMN_TRA_Interfaces.CMN_INT_BeforeUpdate)this).beforeUpdate(triggerNew, triggerOld);
			}
			else if(
					this.context == System.TriggerOperation.AFTER_UPDATE &&
							this instanceof CMN_TRA_Interfaces.CMN_INT_AfterUpdate
			)
			{
				for(SObject obj : triggerNew)
				{
					if(!idToNumberOfTimesSeenAfterUpdate.containsKey(obj.Id))
					{
						idToNumberOfTimesSeenAfterUpdate.put(obj.Id, 1);
					}
					else
					{
						idToNumberOfTimesSeenAfterUpdate.put(obj.Id, idToNumberOfTimesSeenAfterUpdate.get(obj.Id) + 1);
					}
				}
				((CMN_TRA_Interfaces.CMN_INT_AfterUpdate)this).afterUpdate(triggerNew, triggerOld);
			}
			else if(
					this.context == System.TriggerOperation.BEFORE_DELETE &&
							this instanceof CMN_TRA_Interfaces.CMN_INT_BeforeDelete
			)
			{
				((CMN_TRA_Interfaces.CMN_INT_BeforeDelete)this).beforeDelete(triggerOld);
			}
			else if(
					this.context == System.TriggerOperation.AFTER_DELETE &&
							this instanceof CMN_TRA_Interfaces.CMN_INT_AfterDelete
			)
			{
				((CMN_TRA_Interfaces.CMN_INT_AfterDelete)this).afterDelete(triggerOld);
			}
			else if(
					this.context == System.TriggerOperation.AFTER_UNDELETE &&
							this instanceof CMN_TRA_Interfaces.CMN_INT_AfterUndelete
			)
			{
				((CMN_TRA_Interfaces.CMN_INT_AfterUndelete)this).afterUndelete(triggerNew);
			}
		}
		catch(Exception error)
		{
			String objectName = String.isNotBlank(sObjectName) ? sObjectName : CMN_UTIL_String.EMPTY;
			String triggerOperation = (context != null) ? context.name() : CMN_UTIL_String.EMPTY;

			CMN_UTIL_Logger.error(error, String.format(CLASS_METHOD_FORMAT, new List<String> {objectName, triggerOperation}));
			throw error;
		}
	}

	public static void bypass(String sObjectName)
	{
		CMN_TRA_BaseObject.bypassedObjects.add(sObjectName);
	}

	public static void clearBypass(String sObjectName)
	{
		CMN_TRA_BaseObject.bypassedObjects.remove(sObjectName);
	}

	public static Boolean isBypassed(String sObjectName)
	{
		return CMN_TRA_BaseObject.bypassedObjects.contains(sObjectName);
	}

	public static void clearAllBypasses()
	{
		CMN_TRA_BaseObject.bypassedObjects.clear();
	}

	private Boolean validateRun()
	{
		if(!Trigger.isExecuting && this.context == null)
		{
			throw new TriggerBaseException(HANDLER_OUTSIDE_TRIGGER_MESSAGE);
		}
		if(CMN_TRA_BaseObject.bypassedObjects.contains(this.sObjectName))
		{
			return false;
		}
		return true;
	}

	@TestVisible
	protected String sObjectName
	{
		get
		{
			if(sObjectName == null)
			{
				if(this.triggerNew != null)
				{
					sObjectName = this.triggerNew.iterator().next()
							.getSObjectType()
							.getDescribe()
							.getName();
				}
				else if(this.triggerOld != null)
				{
					sObjectName = this.triggerOld.iterator().next()
							.getSObjectType()
							.getDescribe()
							.getName();
				}
			}
			return sObjectName;
		}
		private set;
	}

	@TestVisible
	private System.TriggerOperation context
	{
		get
		{
			if(context == null)
			{
				context = Trigger.operationType;
			}
			return context;
		}
		set;
	}

	@TestVisible
	protected List<SObject> triggerNew
	{
		get
		{
			if(triggerNew == null)
			{
				triggerNew = Trigger.new;
			}
			return triggerNew;
		}
		private set;
	}

	@TestVisible
	protected List<SObject> triggerOld
	{
		get
		{
			if(triggerOld == null)
			{
				triggerOld = Trigger.old;
			}
			return triggerOld;
		}
		private set;
	}

	public class TriggerBaseException extends Exception
	{
	}
}