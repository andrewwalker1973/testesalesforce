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
 * @see TriggerActionFlowIsBypassedTest
 */
public inherited sharing class CMN_FLOW_CheckTriggerIsBypassed
{
	@TestVisible
	private static final String CLASS_NAME = CMN_FLOW_CheckTriggerIsBypassed.class.getName();
	@TestVisible
	private static final String INVALID_REQUEST = String.format(
			CMN_TRA_RunFlow.INVALID_BYPASS_REQUEST,
			new List<String> {CLASS_NAME}
	);

	@InvocableMethod(
			Category='Trigger Action Flow'
			Label='Is Bypassed'
			Description='Returns if the bypass for this object, apex action, or flow action is set to true.'
	)
	public static List<Boolean> isBypassed(List<Request> requests)
	{
		if(requests.size() != 1)
		{
			throw new TriggerActionFlowIsBypassedObjectException(INVALID_REQUEST);
		}
		if(!CMN_TRA_RunFlow.REQUEST_TYPES.contains(requests[0].bypassType))
		{
			throw new TriggerActionFlowIsBypassedObjectException(
					CMN_TRA_RunFlow.INVALID_TYPE
			);
		}
		Boolean result = false;
		if(requests[0].bypassType == CMN_TRA_RunFlow.OBJECT_STRING)
		{
			result = CMN_TRA_BaseObject.isBypassed(requests[0].name);
		}
		if(requests[0].bypassType == CMN_TRA_RunFlow.APEX_STRING)
		{
			result = CMN_FACTORY_TriggerAction.isBypassed(requests[0].name);
		}
		if(requests[0].bypassType == CMN_TRA_RunFlow.FLOW_STRING)
		{
			result = CMN_TRA_RunFlow.isBypassed(requests[0].name);
		}
		return new List<Boolean> {result};
	}

	public class Request
	{
		@InvocableVariable
		public String name;
		@InvocableVariable
		public String bypassType;
	}

	public class TriggerActionFlowIsBypassedObjectException extends Exception
	{
	}
}