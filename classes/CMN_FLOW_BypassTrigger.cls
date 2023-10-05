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
 * @see TriggerActionFlowBypassTest
 */
public inherited sharing class CMN_FLOW_BypassTrigger
{
	@TestVisible
	private static final String CLASS_NAME = CMN_FLOW_BypassTrigger.class.getName();
	@TestVisible
	private static final String INVALID_REQUEST = String.format(
			CMN_TRA_RunFlow.INVALID_BYPASS_REQUEST,
			new List<String> {CLASS_NAME}
	);

	@InvocableMethod(
			Category='Trigger Action Flow'
			Label='Bypass'
			Description='Sets the static bypass to true for this object, apex action, or flow action.'
	)
	public static void bypass(List<Request> requests)
	{
		if(requests.size() != 1)
		{
			throw new TriggerActionFlowBypassObjectException(INVALID_REQUEST);
		}
		if(!CMN_TRA_RunFlow.REQUEST_TYPES.contains(requests[0].bypassType))
		{
			throw new TriggerActionFlowBypassObjectException(
					CMN_TRA_RunFlow.INVALID_TYPE
			);
		}
		if(requests[0].bypassType == CMN_TRA_RunFlow.OBJECT_STRING)
		{
			CMN_TRA_BaseObject.bypass(requests[0].name);
		}
		if(requests[0].bypassType == CMN_TRA_RunFlow.APEX_STRING)
		{
			CMN_FACTORY_TriggerAction.bypass(requests[0].name);
		}
		if(requests[0].bypassType == CMN_TRA_RunFlow.FLOW_STRING)
		{
			CMN_TRA_RunFlow.bypass(requests[0].name);
		}
	}

	public class Request
	{
		@InvocableVariable(
				Label='Name'
				Description='API Name of the trigger action flow, class, or sObject'
				Required=true
		)
		public String name;
		@InvocableVariable(
				Label='Bypass Type'
				Description='Apex, Flow, or Object'
				Required=true
		)
		public String bypassType;
	}

	public class TriggerActionFlowBypassObjectException extends Exception
	{
	}
}