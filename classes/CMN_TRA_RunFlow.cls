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
 * @see CMN_TRH_RunFlow_TEST https://github.com/mitchspano/apex-trigger-actions-framework/blob/master/README.md#metadata-driven-trigger-actions
 */
public inherited sharing class CMN_TRA_RunFlow implements CMN_TRA_Interfaces.CMN_INT_BeforeInsert, CMN_TRA_Interfaces.CMN_INT_AfterInsert, CMN_TRA_Interfaces.CMN_INT_BeforeUpdate, CMN_TRA_Interfaces.CMN_INT_AfterUpdate, CMN_TRA_Interfaces.CMN_INT_AfterUndelete
{
	public String flowName;
	public Boolean allowRecursion;
	@TestVisible
	private static final String INVALID_FLOW_NAME = 'You must provide the name of a flow to execute';
	@TestVisible
	private static final String NEW_LIST_AFTER_FLOW = 'newListAfterFlow';
	@TestVisible
	private static final String NEW_LIST = 'newList';
	@TestVisible
	private static final String OLD_LIST = 'oldList';
	@TestVisible
	private static final String OLD_RECORD_NOT_FOUND = 'An old version of the record cannot be identified in the oldList';
	@TestVisible
	private static final String INVALID_REQUEST = 'You can only pass one getOldRecordRequest into CMN_TRH_RunFlow.getOldRecord()';
	@TestVisible
	private static final String NEW_LIST_AFTER_FLOW_NOT_POPULATED_CORRECTLY = 'You must pass ALL records back to the newListAfterFlow in order to apply values to record before insert/update';
	public static final String OBJECT_STRING = 'Object';
	public static final String APEX_STRING = 'Apex';
	public static final String FLOW_STRING = 'Flow';
	public static final String INVALID_BYPASS_REQUEST = 'You can only pass one request into {0}';
	public static final String INVALID_TYPE = 'The bypassType must equal Object, Apex, or Flow';
	public static final Set<String> REQUEST_TYPES = new Set<String>
	{
			OBJECT_STRING,
			APEX_STRING,
			FLOW_STRING
	};
	@TestVisible
	private static Set<String> bypassedFlows;

	static
	{
		bypassedFlows = new Set<String>();
	}

	public void beforeInsert(List<SObject> newList)
	{
		if(!thisFlowIsBypassed())
		{
			Flow.Interview myFlow = Flow.Interview.createInterview(
					flowName,
					getFlowInput(newList, null)
			);
			myFlow.start();
			applyFlowValues(
					newList,
					(List<SObject>)myFlow.getVariableValue(NEW_LIST_AFTER_FLOW)
			);
		}
	}

	public void afterInsert(List<SObject> newList)
	{
		if(!thisFlowIsBypassed())
		{
			Flow.Interview myFlow = Flow.Interview.createInterview(
					flowName,
					getFlowInput(newList, null)
			);
			myFlow.start();
		}
	}

	public void beforeUpdate(List<SObject> newList, List<SObject> oldList)
	{
		if(!thisFlowIsBypassed())
		{
			List<SObject> recordsNotYetProcessed = new List<SObject>();
			for(SObject record : newList)
			{
				if(
						CMN_TRA_BaseObject.idToNumberOfTimesSeenBeforeUpdate.get(record.Id) == 1 ||
								(allowRecursion == true)
						)
				{
					recordsNotYetProcessed.add(record);
				}
			}
			Flow.Interview myFlow = Flow.Interview.createInterview(
					flowName,
					getFlowInput(recordsNotYetProcessed, oldList)
			);
			myFlow.start();
			applyFlowValues(
					newList,
					(List<SObject>)myFlow.getVariableValue(NEW_LIST_AFTER_FLOW)
			);
		}
	}

	public void afterUpdate(List<SObject> newList, List<SObject> oldList)
	{
		if(!thisFlowIsBypassed())
		{
			List<SObject> recordsNotYetProcessed = new List<SObject>();
			for(SObject record : newList)
			{
				if(
						CMN_TRA_BaseObject.idToNumberOfTimesSeenAfterUpdate.get(record.Id) == 1 ||
								(allowRecursion == true)
						)
				{
					recordsNotYetProcessed.add(record);
				}
			}
			Flow.Interview myFlow = Flow.Interview.createInterview(
					flowName,
					getFlowInput(recordsNotYetProcessed, oldList)
			);
			myFlow.start();
		}
	}

	public void beforeDelete(List<SObject> oldList)
	{
		if(!thisFlowIsBypassed())
		{
			Flow.Interview myFlow = Flow.Interview.createInterview(
					flowName,
					getFlowInput(null, oldList)
			);
			myFlow.start();
		}
	}

	public void afterDelete(List<SObject> oldList)
	{
		if(!thisFlowIsBypassed())
		{
			Flow.Interview myFlow = Flow.Interview.createInterview(
					flowName,
					getFlowInput(null, oldList)
			);
			myFlow.start();
		}
	}

	public void afterUndelete(List<SObject> newList)
	{
		if(!thisFlowIsBypassed())
		{
			Flow.Interview myFlow = Flow.Interview.createInterview(
					flowName,
					getFlowInput(newList, null)
			);
			myFlow.start();
		}
	}

	public static void bypass(String flowName)
	{
		CMN_TRA_RunFlow.bypassedFlows.add(flowName);
	}

	public static void clearBypass(String flowName)
	{
		CMN_TRA_RunFlow.bypassedFlows.remove(flowName);
	}

	public static Boolean isBypassed(String flowName)
	{
		return CMN_TRA_RunFlow.bypassedFlows.contains(flowName);
	}

	public static void clearAllBypasses()
	{
		CMN_TRA_RunFlow.bypassedFlows.clear();
	}

	private Boolean thisFlowIsBypassed()
	{
		if(String.isBlank(flowName))
		{
			throw new TriggerActionFlowException(INVALID_FLOW_NAME);
		}
		return CMN_TRA_RunFlow.isBypassed(flowName);
	}

	private Map<String, Object> getFlowInput(
			List<SObject> newList,
			List<SObject> oldList
	)
	{
		Map<String, Object> result = new Map<String, Object>();
		if(newList != null)
		{
			result.put(NEW_LIST, newList);
		}
		if(oldList != null)
		{
			result.put(OLD_LIST, oldList);
		}
		return result;
	}

	private void applyFlowValues(
			List<SObject> newList,
			List<SObject> newListAfterFlow
	)
	{
		if(
				newList != null &&
						!newList.isEmpty() &&
						newListAfterFlow != null &&
						!newListAfterFlow.isEmpty()
				)
		{
			if(newList.size() != newListAfterFlow.size())
			{
				throw new TriggerActionFlowException(
						NEW_LIST_AFTER_FLOW_NOT_POPULATED_CORRECTLY
				);
			}
			List<String> editableFields = new List<String>();
			for(
					Schema.SObjectField fieldRef : newList[0]
					.getSObjectType()
					.getDescribe()
					.fields.getMap()
					.values()
			)
			{
				Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
				if(fieldResult.isUpdateable())
				{
					editableFields.add(fieldResult.getName());
				}
			}
			for(Integer i = 0; i < newList.size(); i++)
			{
				for(String fieldName : editableFields)
				{
					if(newList[i].get(fieldName) != newListAfterFlow[i].get(fieldName))
					{
						newList[i].put(fieldName, newListAfterFlow[i].get(fieldName));
					}
				}
			}
		}
	}

	public class OldRecordRequest
	{
		@InvocableVariable(
				Label='Current Record'
				Description='The current record'
				Required=true
		)
		public SObject currentRecord;
		@InvocableVariable(
				Label='Old List'
				Description='A list of all the records with the old field values'
				Required=true
		)
		public List<SObject> oldList;
	}

	class TriggerActionFlowException extends Exception
	{
	}
}