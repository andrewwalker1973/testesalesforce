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
 * @see CMN_FLOW_AddObjectError
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_FLOW_AddObjectError_TEST
{
	private static final String MY_STRING = 'MY_STRING';
	private static final String NAME = 'Name';

	@IsTest
	private static void error()
	{
		Test.startTest();
		List<CMN_FLOW_AddObjectError.Request> requests = new List<CMN_FLOW_AddObjectError.Request>();
		CMN_FLOW_AddObjectError.Request request = new CMN_FLOW_AddObjectError.Request();
		Account account = new Account();
		request.errorMessage = MY_STRING;
		request.record = account;
		requests.add(request);
		CMN_FLOW_AddObjectError.addError(requests);
		Test.stopTest();
		System.assertEquals(
				true,
				account.hasErrors(),
				'The Account should have an error'
		);
		System.assertEquals(
				1,
				account.getErrors().size(),
				'There should only be one error'
		);
		System.assertEquals(
				MY_STRING,
				account.getErrors()[0].getMessage(),
				'The error should contain the message we are looking for'
		);
	}

	@IsTest
	private static void fieldError()
	{
		Test.startTest();
		List<CMN_FLOW_AddObjectError.Request> requests = new List<CMN_FLOW_AddObjectError.Request>();
		CMN_FLOW_AddObjectError.Request request = new CMN_FLOW_AddObjectError.Request();
		Account account = new Account();
		request.errorMessage = MY_STRING;
		request.fieldName = NAME;
		request.record = account;
		requests.add(request);
		CMN_FLOW_AddObjectError.addError(requests);
		Test.stopTest();
		System.assertEquals(
				true,
				account.hasErrors(),
				'The Account should have an error'
		);
		System.assertEquals(
				1,
				account.getErrors().size(),
				'There should only be one error'
		);
		System.assertEquals(
				MY_STRING,
				account.getErrors()[0].getMessage(),
				'The error should contain the message we are looking for'
		);
	}

	@IsTest
	private static void invalidRequest()
	{
		Exception myException;
		Test.startTest();
		try
		{
			CMN_FLOW_AddObjectError.addError(
					new List<CMN_FLOW_AddObjectError.Request>()
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
				myException instanceof CMN_FLOW_AddObjectError.TriggerActionFlowAddErrorException,
				'The exception should be of the correct type'
		);
		System.assertEquals(
				myException.getMessage(),
				CMN_FLOW_AddObjectError.INVALID_REQUEST,
				'The exeption should contain the message we are looking for'
		);
	}
}