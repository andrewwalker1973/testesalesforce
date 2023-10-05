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
 * @see TriggerActionFlowAddErrorTest
 */
public inherited sharing class CMN_FLOW_AddObjectError
{
	@TestVisible
	private static final String CLASS_NAME = CMN_FLOW_AddObjectError.class.getName();
	@TestVisible
	private static final String INVALID_REQUEST = String.format(
			CMN_TRA_RunFlow.INVALID_BYPASS_REQUEST,
			new List<String> {CLASS_NAME}
	);

	@InvocableMethod(
			Category='Trigger Action Flow'
			Label='Add Error'
			Description='Adds an error to an SObject'
	)
	public static void addError(List<Request> requests)
	{
		if(requests.size() != 1)
		{
			throw new TriggerActionFlowAddErrorException(INVALID_REQUEST);
		}
		if(String.isNotBlank(requests[0].fieldName))
		{
			requests[0]
					.record.addError(requests[0].fieldName, requests[0].errorMessage);
		}
		else
		{
			requests[0].record.addError(requests[0].errorMessage);
		}
	}

	public class Request
	{
		@InvocableVariable(
				Label='Record'
				Description='Record to add the error to'
				Required=true
		)
		public SObject record;
		@InvocableVariable(
				Label='Field Name'
				Description='API name of corresponding field'
		)
		public String fieldName;
		@InvocableVariable(
				Label='Error Message'
				Description='Error Message'
				Required=true
		)
		public String errorMessage;
	}

	public class TriggerActionFlowAddErrorException extends Exception
	{
	}
}