/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 * <p/>
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 * <p/>
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 * <p/>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p/>
 * @group Core
 * Class defining a method return value.
 */
public with sharing class CMN_MOCK_MethodReturnValue
{
	private StandardAnswer basicAnswer = new StandardAnswer();

	/**
	 * @description Instance of the implementation of the Answer interface that implements the answer,
	 * if an answer isn't explicitly set the standard answer will be used, which just returns the stubbed return value.
	 */
	public CMN_MOCK_Answer answer { get; set; }

	/**
	 * @description Setup a stubbed return value.
	 *
	 * @param value The value to return from the stubbed method call.
	 *
	 * @return The CMN_MOCK_MethodReturnValue instance to allow you to chain the methods.
	 */
	public CMN_MOCK_MethodReturnValue thenReturn(Object value)
	{
		thenAnswer(this.basicAnswer.setValue(value));
		return this;
	}

	/**
	 * @description Setup a stubbed exception.
	 *
	 * @param e The exception to throw from the stubbed method call.
	 *
	 * @return The CMN_MOCK_MethodReturnValue instance to allow you to chain the methods.
	 */
	public CMN_MOCK_MethodReturnValue thenThrow(Exception e)
	{
		thenAnswer(this.basicAnswer.setValue(e));
		return this;
	}

	/**
	 * @description Setup a stubbed answer.
	 *
	 * @param answer The answer to run from the stubbed method call.
	 */
	public void thenAnswer(CMN_MOCK_Answer answer)
	{
		this.answer = answer;
	}

	/**
	 * @description Setup a list of stubbed return values.
	 *
	 * @param values The values to return from the stubbed method call in consecutive calls.
	 *
	 * @return The CMN_MOCK_MethodReturnValue instance to allow you to chain the methods.
	 */
	public CMN_MOCK_MethodReturnValue thenReturnMulti(List<Object> values)
	{
		thenAnswer(this.basicAnswer.setValues(values));
		return this;
	}

	/**
	 * @description Setup a list stubbed exceptions.
	 *
	 * @param es The exceptions to throw from the stubbed method call in consecutive calls.
	 *
	 * @return The CMN_MOCK_MethodReturnValue instance to allow you to chain the methods.
	 */
	public CMN_MOCK_MethodReturnValue thenThrowMulti(List<Exception> es)
	{
		thenAnswer(this.basicAnswer.setValues(es));
		return this;
	}

	/**
	 * @description @group Core
	 * Inner class to handle all the stubs that do not use the thenAnswer method directly.
	 * For internal use only.
	 */
	public class StandardAnswer implements CMN_MOCK_Answer
	{
		private Integer whichStubReturnIndex = 0;

		/**
		 * @description it stores the return values for the method stubbed.
		 * The values would be stored and then returned as part of the standard answer invocation.
		 */
		private List<Object> returnValues = new List<Object>();

		/**
		 * @description Setter of a single return value.
		 *
		 * @param value The value to be set as return value for the StandardAnswer object.
		 *
		 * @return The StandardAnswer instance.
		 */
		public StandardAnswer setValue(Object value)
		{
			returnValues.add(value);
			return this;
		}

		/**
		 * @description Setter of the list of return values.
		 *
		 * @param values as input
		 *
		 * @return the StandardAnswer instance.
		 */
		public StandardAnswer setValues(List<Object> values)
		{
			if(values == null || values.size() == 0)
			{
				throw new CMN_MOCK_ApexMocks.ApexMocksException(
						'The stubbing is not correct, no return values have been set.');
			}

			returnValues.addAll(values);
			return this;
		}

		/**
		 * @description Standard basic implementation for the CMN_MOCK_Answer answer method, to be used as default answering.
		 *
		 * @param invocation The invocation to answer for.
		 *
		 * @return The ReturnValue for the method stubbed.
		 */
		public Object answer(CMN_MOCK_InvocationOnMock invocation)
		{
			if(returnValues == null || returnValues.size() == 0)
			{
				throw new CMN_MOCK_ApexMocks.ApexMocksException(
						'The stubbing is not correct, no return values have been set.');
			}

			Integer returnValuesSize = returnValues.size() - 1;

			if(whichStubReturnIndex < returnValuesSize)
			{
				return returnValues[whichStubReturnIndex++];
			}
			else
			{
				return returnValues[returnValuesSize];
			}
		}
	}
}