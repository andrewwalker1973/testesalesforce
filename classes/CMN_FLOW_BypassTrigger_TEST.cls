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
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_FLOW_BypassTrigger_TEST
{
	private static final String MY_STRING = 'MY_STRING';

	@IsTest
	private static void object()
	{
		Test.startTest();
		List<CMN_FLOW_BypassTrigger.Request> requests = new List<CMN_FLOW_BypassTrigger.Request>();
		CMN_FLOW_BypassTrigger.Request request = new CMN_FLOW_BypassTrigger.Request();
		request.name = MY_STRING;
		request.bypassType = CMN_TRA_RunFlow.OBJECT_STRING;
		requests.add(request);
		CMN_FLOW_BypassTrigger.bypass(requests);
		Test.stopTest();
		System.assertEquals(
				true,
				CMN_TRA_BaseObject.isBypassed(MY_STRING),
				'The Object should be bypassed'
		);
	}

	@IsTest
	private static void apex()
	{
		Test.startTest();
		List<CMN_FLOW_BypassTrigger.Request> requests = new List<CMN_FLOW_BypassTrigger.Request>();
		CMN_FLOW_BypassTrigger.Request request = new CMN_FLOW_BypassTrigger.Request();
		request.name = MY_STRING;
		request.bypassType = CMN_TRA_RunFlow.APEX_STRING;
		requests.add(request);
		CMN_FLOW_BypassTrigger.bypass(requests);
		Test.stopTest();
		System.assertEquals(
				true,
				CMN_FACTORY_TriggerAction.isBypassed(MY_STRING),
				'The Apex should be bypassed'
		);
	}

	@IsTest
	private static void flow()
	{
		Test.startTest();
		List<CMN_FLOW_BypassTrigger.Request> requests = new List<CMN_FLOW_BypassTrigger.Request>();
		CMN_FLOW_BypassTrigger.Request request = new CMN_FLOW_BypassTrigger.Request();
		request.name = MY_STRING;
		request.bypassType = CMN_TRA_RunFlow.FLOW_STRING;
		requests.add(request);
		CMN_FLOW_BypassTrigger.bypass(requests);
		Test.stopTest();
		System.assertEquals(
				true,
				CMN_TRA_RunFlow.isBypassed(MY_STRING),
				'The Flow should be bypassed'
		);
	}

	@IsTest
	private static void invalidRequest()
	{
		Exception myException;
		Test.startTest();
		try
		{
			CMN_FLOW_BypassTrigger.bypass(
					new List<CMN_FLOW_BypassTrigger.Request>()
			);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(
				null,
				myException,
				'We should have an exception thrown in this scenario'
		);
		System.assert(
				myException instanceof CMN_FLOW_BypassTrigger.TriggerActionFlowBypassObjectException,
				'The exception should be of the correct type'
		);
		System.assertEquals(
				myException.getMessage(),
				CMN_FLOW_BypassTrigger.INVALID_REQUEST,
				'The exeption should contain the message we are looking for'
		);
	}

	@IsTest
	private static void invalidBypassType()
	{
		Exception myException;
		Test.startTest();
		List<CMN_FLOW_BypassTrigger.Request> requests = new List<CMN_FLOW_BypassTrigger.Request>();
		CMN_FLOW_BypassTrigger.Request request = new CMN_FLOW_BypassTrigger.Request();
		request.name = MY_STRING;
		request.bypassType = MY_STRING;
		requests.add(request);
		try
		{
			CMN_FLOW_BypassTrigger.bypass(requests);
		}
		catch(Exception e)
		{
			myException = e;
		}
		Test.stopTest();
		System.assertNotEquals(
				null,
				myException,
				'We should have an exception thrown in this scenario'
		);
		System.assert(
				myException instanceof CMN_FLOW_BypassTrigger.TriggerActionFlowBypassObjectException,
				'The exception should be of the correct type'
		);
		System.assertEquals(
				myException.getMessage(),
				CMN_TRA_RunFlow.INVALID_TYPE,
				'The exeption should contain the message we are looking for'
		);
	}
}