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
 * @see CMN_FLOW_CheckTriggerIsBypassed
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_FLOW_CheckTriggerIsBypassed_TEST
{
	private static final String MY_STRING = 'MY_STRING';

	@IsTest
	private static void object()
	{
		Test.startTest();
		List<CMN_FLOW_CheckTriggerIsBypassed.Request> requests = new List<CMN_FLOW_CheckTriggerIsBypassed.Request>();
		CMN_FLOW_CheckTriggerIsBypassed.Request request = new CMN_FLOW_CheckTriggerIsBypassed.Request();
		request.name = MY_STRING;
		request.bypassType = CMN_TRA_RunFlow.OBJECT_STRING;
		requests.add(request);
		List<Boolean> isBypassed = CMN_FLOW_CheckTriggerIsBypassed.isBypassed(requests);
		Test.stopTest();
		System.assertEquals(
				1,
				isBypassed.size(),
				'We should only have one result for our request'
		);
		System.assertEquals(
				CMN_TRA_BaseObject.isBypassed(MY_STRING),
				isBypassed[0],
				'The result should contain the same result as the CMN_TRH_TriggerActionBase'
		);
	}

	@IsTest
	private static void apex()
	{
		Exception myException;
		Test.startTest();
		List<CMN_FLOW_CheckTriggerIsBypassed.Request> requests = new List<CMN_FLOW_CheckTriggerIsBypassed.Request>();
		CMN_FLOW_CheckTriggerIsBypassed.Request request = new CMN_FLOW_CheckTriggerIsBypassed.Request();
		request.name = MY_STRING;
		request.bypassType = CMN_TRA_RunFlow.APEX_STRING;
		requests.add(request);
		List<Boolean> isBypassed = CMN_FLOW_CheckTriggerIsBypassed.isBypassed(requests);
		Test.stopTest();
		System.assertEquals(
				1,
				isBypassed.size(),
				'We should only have one result for our request'
		);
		System.assertEquals(
				CMN_FACTORY_TriggerAction.isBypassed(MY_STRING),
				isBypassed[0],
				'The result should contain the same result as the ' + CMN_FACTORY_TriggerAction.class.getName()
		);
	}

	@IsTest
	private static void flow()
	{
		Exception myException;
		Test.startTest();
		List<CMN_FLOW_CheckTriggerIsBypassed.Request> requests = new List<CMN_FLOW_CheckTriggerIsBypassed.Request>();
		CMN_FLOW_CheckTriggerIsBypassed.Request request = new CMN_FLOW_CheckTriggerIsBypassed.Request();
		request.name = MY_STRING;
		request.bypassType = CMN_TRA_RunFlow.FLOW_STRING;
		requests.add(request);
		List<Boolean> isBypassed = CMN_FLOW_CheckTriggerIsBypassed.isBypassed(requests);
		Test.stopTest();
		System.assertEquals(
				1,
				isBypassed.size(),
				'We should only have one result for our request'
		);
		System.assertEquals(
				CMN_TRA_RunFlow.isBypassed(MY_STRING),
				isBypassed[0],
				'The result should contain the same result as the CMN_TRH_RunFlow'
		);
	}

	@IsTest
	private static void invalidRequest()
	{
		Exception myException;
		Test.startTest();
		try
		{
			List<Boolean> isBypassed = CMN_FLOW_CheckTriggerIsBypassed.isBypassed(
					new List<CMN_FLOW_CheckTriggerIsBypassed.Request>()
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
				myException instanceof CMN_FLOW_CheckTriggerIsBypassed.TriggerActionFlowIsBypassedObjectException,
				'The exception should be of the correct type'
		);
		System.assertEquals(
				myException.getMessage(),
				CMN_FLOW_CheckTriggerIsBypassed.INVALID_REQUEST,
				'The exeption should contain the message we are looking for'
		);
	}

	@IsTest
	private static void invalidBypassType()
	{
		Exception myException;
		Test.startTest();
		List<CMN_FLOW_CheckTriggerIsBypassed.Request> requests = new List<CMN_FLOW_CheckTriggerIsBypassed.Request>();
		CMN_FLOW_CheckTriggerIsBypassed.Request request = new CMN_FLOW_CheckTriggerIsBypassed.Request();
		request.name = MY_STRING;
		request.bypassType = MY_STRING;
		requests.add(request);
		try
		{
			List<Boolean> isBypassed = CMN_FLOW_CheckTriggerIsBypassed.isBypassed(
					requests
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
				myException instanceof CMN_FLOW_CheckTriggerIsBypassed.TriggerActionFlowIsBypassedObjectException,
				'The exception should be of the correct type'
		);
		System.assertEquals(
				myException.getMessage(),
				CMN_TRA_RunFlow.INVALID_TYPE,
				'The exeption should contain the message we are looking for'
		);
	}
}