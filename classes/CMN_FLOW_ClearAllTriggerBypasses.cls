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
 * @see TriggerActionFlowClearAllBypassesTest
 */
public inherited sharing class CMN_FLOW_ClearAllTriggerBypasses
{
	@TestVisible
	private static final String CLASS_NAME = CMN_FLOW_ClearAllTriggerBypasses.class.getName();
	@TestVisible
	private static final String INVALID_REQUEST = String.format(
			CMN_TRA_RunFlow.INVALID_BYPASS_REQUEST,
			new List<String> {CLASS_NAME}
	);

	@InvocableMethod(
			Category='Trigger Action Flow'
			Label='Clear All Bypasses'
			Description='Sets the static bypass to false for all objects, apex actions, or flow actions.'
	)
	public static void clearAllBypasses(List<String> requests)
	{
		if(requests.size() != 1)
		{
			throw new TriggerActionFlowClearAllBypassesObjectException(
					INVALID_REQUEST
			);
		}
		if(!CMN_TRA_RunFlow.REQUEST_TYPES.contains(requests[0]))
		{
			throw new TriggerActionFlowClearAllBypassesObjectException(
					CMN_TRA_RunFlow.INVALID_TYPE
			);
		}
		if(requests[0] == CMN_TRA_RunFlow.OBJECT_STRING)
		{
			CMN_TRA_BaseObject.clearAllBypasses();
		}
		if(requests[0] == CMN_TRA_RunFlow.APEX_STRING)
		{
			CMN_FACTORY_TriggerAction.clearAllBypasses();
		}
		if(requests[0] == CMN_TRA_RunFlow.FLOW_STRING)
		{
			CMN_TRA_RunFlow.clearAllBypasses();
		}
	}

	public class TriggerActionFlowClearAllBypassesObjectException extends Exception
	{
	}
}