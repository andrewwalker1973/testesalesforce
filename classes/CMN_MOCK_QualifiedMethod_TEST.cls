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
 **/
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_MOCK_QualifiedMethod_TEST
{
	@IsTest
	private static void equalsReturnsExpectedResults()
	{
		//Given
		CMN_MOCK_QualifiedMethod qm1 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class});
		CMN_MOCK_QualifiedMethod qm2 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class});
		CMN_MOCK_QualifiedMethod qm3 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {String.class});
		CMN_MOCK_QualifiedMethod qm4 = new CMN_MOCK_QualifiedMethod('Type2', 'Method2', new List<Type> {Integer.class, String.class, CMN_MOCK_QualifiedMethod_TEST.class});
		CMN_MOCK_QualifiedMethod qm5 = new CMN_MOCK_QualifiedMethod('', '', new List<Type> {});
		CMN_MOCK_QualifiedMethod qm6 = new CMN_MOCK_QualifiedMethod(null, null, null);

		//When/then
		System.assertEquals(qm1, qm1);
		System.assertEquals(qm1, qm2);
		System.assertNotEquals(qm1, qm3);
		System.assertNotEquals(qm1, qm4);
		System.assertNotEquals(qm1, qm5);
		System.assertNotEquals(qm1, qm6);

		System.assertEquals(qm2, qm2);
		System.assertNotEquals(qm2, qm3);
		System.assertNotEquals(qm2, qm4);
		System.assertNotEquals(qm2, qm5);
		System.assertNotEquals(qm2, qm6);

		System.assertEquals(qm3, qm3);
		System.assertNotEquals(qm3, qm4);
		System.assertNotEquals(qm3, qm5);
		System.assertNotEquals(qm3, qm6);

		System.assertEquals(qm4, qm4);
		System.assertNotEquals(qm4, qm5);
		System.assertNotEquals(qm4, qm6);

		System.assertEquals(qm5, qm5);
		System.assertNotEquals(qm5, qm6);

		System.assertEquals(qm6, qm6);
	}

	@IsTest
	private static void hashCodeReturnsExpectedResults()
	{
		//Given
		CMN_MOCK_QualifiedMethod qm1 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class});
		CMN_MOCK_QualifiedMethod qm2 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class});
		CMN_MOCK_QualifiedMethod qm3 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {String.class});
		CMN_MOCK_QualifiedMethod qm4 = new CMN_MOCK_QualifiedMethod('Type2', 'Method2', new List<Type> {Integer.class, String.class, CMN_MOCK_QualifiedMethod_TEST.class});
		CMN_MOCK_QualifiedMethod qm5 = new CMN_MOCK_QualifiedMethod('', '', new List<Type> {});
		CMN_MOCK_QualifiedMethod qm6 = new CMN_MOCK_QualifiedMethod(null, null, null);

		//When/then
		System.assertEquals(qm1.hashCode(), qm1.hashCode());
		System.assertEquals(qm1.hashCode(), qm2.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm4.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm6.hashCode());

		System.assertEquals(qm2.hashCode(), qm2.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm4.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm6.hashCode());

		System.assertEquals(qm3.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm3.hashCode(), qm4.hashCode());
		System.assertNotEquals(qm3.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm3.hashCode(), qm6.hashCode());

		System.assertEquals(qm4.hashCode(), qm4.hashCode());
		System.assertNotEquals(qm4.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm4.hashCode(), qm6.hashCode());

		System.assertEquals(qm5.hashCode(), qm5.hashCode());
		System.assertNotEquals(qm5.hashCode(), qm6.hashCode());

		System.assertEquals(qm6.hashCode(), qm6.hashCode());
	}

	@IsTest
	public static void toStringReturnsExpectedResult()
	{
		System.assertEquals('MyClass.MyMethod(Integer)', new CMN_MOCK_QualifiedMethod('MyClass', 'MyMethod', new List<Type> {Integer.class}).toString());
	}

	@IsTest
	private static void equalsReturnsExpectedResultsForHasDependentMocks()
	{
		//Given
		String instance = 'My object instance';
		String instance2 = 'My other object instance';
		CMN_MOCK_QualifiedMethod qm1 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class});
		CMN_MOCK_QualifiedMethod qm2 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class}, instance);
		CMN_MOCK_QualifiedMethod qm3 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class}, instance);
		CMN_MOCK_QualifiedMethod qm4 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class}, instance2);

		//When/then
		CMN_MOCK_ApexMocksConfig.hasIndependentMocks = false;

		System.assertEquals(qm1, qm2);
		System.assertEquals(qm1, qm3);
		System.assertEquals(qm1, qm4);

		CMN_MOCK_ApexMocksConfig.hasIndependentMocks = true;

		System.assertNotEquals(qm1, qm2);
		System.assertNotEquals(qm1, qm3);
		System.assertNotEquals(qm1, qm4);

		System.assertEquals(qm2, qm3);
		System.assertNotEquals(qm2, qm4);

		System.assertNotEquals(qm3, qm4);
	}

	@IsTest
	private static void hashCodeReturnsExpectedResultsForHasDependentMocks()
	{
		//Given
		String instance = 'My object instance';
		String instance2 = 'My other object instance';
		CMN_MOCK_QualifiedMethod qm1 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class});
		CMN_MOCK_QualifiedMethod qm2 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class}, instance);
		CMN_MOCK_QualifiedMethod qm3 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class}, instance);
		CMN_MOCK_QualifiedMethod qm4 = new CMN_MOCK_QualifiedMethod('Type1', 'Method1', new List<Type> {Integer.class}, instance2);

		//When/then
		CMN_MOCK_ApexMocksConfig.hasIndependentMocks = false;

		System.assertEquals(qm1.hashCode(), qm2.hashCode());
		System.assertEquals(qm1.hashCode(), qm3.hashCode());
		System.assertEquals(qm1.hashCode(), qm4.hashCode());

		CMN_MOCK_ApexMocksConfig.hasIndependentMocks = true;

		System.assertNotEquals(qm1.hashCode(), qm2.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm1.hashCode(), qm4.hashCode());

		System.assertEquals(qm2.hashCode(), qm3.hashCode());
		System.assertNotEquals(qm2.hashCode(), qm4.hashCode());

		System.assertNotEquals(qm3.hashCode(), qm4.hashCode());
	}
}