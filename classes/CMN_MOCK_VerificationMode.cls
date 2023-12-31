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
 * This class implements the verification modes with Mockito syntax style.
 * It can be used in the classic verify and in the ordered verify.
 * <p/>
 * @group Core
 */
public with sharing class CMN_MOCK_VerificationMode
{
	public Integer verifyMin { get; set; }
	public Integer verifyMax { get; set; }
	public String customAssertMessage { get; set; }

	public enum ModeName
	{
		TIMES, AT_LEAST, AT_MOST, BETWEEN, AT_LEAST_ONCE, CALLS
	}

	public ModeName method;

	public CMN_MOCK_VerificationMode()
	{
		verifyMin = 1;
		verifyMax = null;
		customAssertMessage = null;
		method = null;
	}

	/**
	 * @description Sets how many times the method is expected to be called.
	 * For InOrder verification we copy Mockito behavior which is as follows;
	 * <ul>
	 * <li>Consume the specified number of matching invocations, ignoring non-matching invocations in between</li>
	 * <li>Fail an assert if the very next invocation matches, but additional matches can still exist so long as at least one non-matching invocation exists before them</li>
	 * </ul>
	 * For example if you had a(); a(); b(); a();
	 * then inOrder.verify(myMock, 2)).a(); or inOrder.verify(myMock, 3)).a(); would pass but not inOrder.verify(myMock, 1)).a();
	 *
	 * @param times The number of times you expect the method to have been called.
	 *
	 * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
	 */
	public CMN_MOCK_VerificationMode times(Integer times)
	{
		this.method = ModeName.TIMES;
		this.verifyMin = this.verifyMax = times;
		return this;
	}

	/**
	 * @description Sets a custom assert message for the verify.
	 *
	 * @param customAssertMessage The custom message for the assert in case the assert is false. The custom message is queued to the default message.
	 *
	 * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
	 */
	public CMN_MOCK_VerificationMode description(String customAssertMessage)
	{
		this.customAssertMessage = customAssertMessage;
		return this;
	}

	/**
	 * @description Sets the minimum number of times the method is expected to be called.
	 * With the InOrder verification it performs a greedy verification, which means it would consume all the instances of the method verified.
	 *
	 * @param atLeastTimes The minimum number of times you expect the method to have been called.
	 *
	 * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
	 */
	public CMN_MOCK_VerificationMode atLeast(Integer atLeastTimes)
	{
		this.method = ModeName.AT_LEAST;
		this.verifyMin = atLeastTimes;

		return this;
	}

	/**
	 * @description Sets the maximum number of times the method is expected to be called. Not available in the InOrder verification.
	 *
	 * @param atMostTimes The maximum number of times the method is expected to be called.
	 *
	 * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
	 */
	public CMN_MOCK_VerificationMode atMost(Integer atMostTimes)
	{
		this.method = ModeName.AT_MOST;
		this.verifyMax = atMostTimes;

		return this;
	}

	/**
	 * @description Sets that the method is called at least once.
	 * With the InOrder verification it performs a greedy verification, which means it would consume all the instances of the method verified.
	 *
	 * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
	 */
	public CMN_MOCK_VerificationMode atLeastOnce()
	{
		this.method = ModeName.AT_LEAST_ONCE;
		this.verifyMin = 1;

		return this;
	}

	/**
	 * @description Sets the range of how many times the method is expected to be called. Not available in the InOrder verification.
	 *
	 * @param atLeastTimes The minimum number of times you expect the method to have been called.
	 * @param atMostTimes The maximum number of times the method is expected to be called.
	 *
	 * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
	 */
	public CMN_MOCK_VerificationMode between(Integer atLeastTimes, Integer atMostTimes)
	{
		this.method = ModeName.BETWEEN;
		this.verifyMin = atLeastTimes;
		this.verifyMax = atMostTimes;

		return this;
	}

	/**
	 * @description Sets that the method is not expected to be called.
	 *
	 * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
	 */
	public CMN_MOCK_VerificationMode never()
	{
		this.verifyMin = CMN_MOCK_ApexMocks.NEVER;
		this.verifyMax = CMN_MOCK_ApexMocks.NEVER;

		return this;
	}

	/**
	 * @description Sets how many times the method is expected to be called for an InOrder verifier. Available Only with the InOrder verification.
	 * A verification mode using calls will not fail if the method is called more times than expected.
	 *
	 * @param callingTimes The number of times you expect the method to have been called in the InOrder verifying (no greedy verify).
	 *
	 * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
	 */
	public CMN_MOCK_VerificationMode calls(Integer callingTimes)
	{
		this.method = ModeName.CALLS;
		this.verifyMin = callingTimes;
		this.verifyMax = null;

		return this;
	}
}