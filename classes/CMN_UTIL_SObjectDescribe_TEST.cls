/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 * <p/>
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 * <p/>
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *   may be used to endorse or promote products derived from this software without
 *   specific prior written permission.
 * <p/>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p/>
 *  This class adapted from https://github.com/capeterson/Apex-Util
 * Used under a BSD license: https://github.com/capeterson/Apex-Util/blob/master/LICENSE
 *
 * @see CMN_UTIL_SObjectDescribe
 *
 * @author FinancialForce, jason.van.beukering@accenture.com
 *
 * @date November 2021, August 2023
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs,PMD.ApexAssertionsShouldIncludeMessage')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_UTIL_SObjectDescribe_TEST
{

	/**
	 * @description Verify that the different ways of getting your hands on an CMN_UTIL_SObjectDescribe instance all handle null inputs
	 * 				(and blank/empty strings, why not?) by returning null - since there's no possible way to resolve it.
	 */
	@IsTest
	private static void getDescribeBadInput()
	{
		String nullStr = null; //having it as a String var makes for unambiguous selection of overloads
		SObjectType nullType = null;
		DescribeSObjectResult nullDescribe = null;
		SObject nullSObject = null;
		Assert.isNull(CMN_UTIL_SObjectDescribe.getDescribe(nullStr));
		Assert.isNull(CMN_UTIL_SObjectDescribe.getDescribe(''));
		Assert.isNull(CMN_UTIL_SObjectDescribe.getDescribe(' '));
		Assert.isNull(CMN_UTIL_SObjectDescribe.getDescribe(nullType));
		Assert.isNull(CMN_UTIL_SObjectDescribe.getDescribe(nullDescribe));
		Assert.isNull(CMN_UTIL_SObjectDescribe.getDescribe(nullSObject));
	}

	@IsTest
	private static void namespaceAttributeMap()
	{
		CMN_UTIL_SObjectDescribe.GlobalDescribeMap gdm = CMN_UTIL_SObjectDescribe.getGlobalDescribe();

		Map<String, SObjectType> testGDM = Schema.getGlobalDescribe();

		Assert.areEqual(testGDM.size(), gdm.size());

		SObjectType accountObjType = gdm.get('AccOunT');
		Assert.areEqual(accountObjType, Account.SObjectType);
		Assert.areEqual(Schema.getGlobalDescribe().size(), gdm.size());

		CMN_UTIL_SObjectDescribe accountDescribe = CMN_UTIL_SObjectDescribe.getDescribe(accountObjType);
		CMN_UTIL_SObjectDescribe.FieldsMap fields = accountDescribe.getFields();
		Assert.isTrue(fields.keySet().containsAll(accountDescribe.getFieldsMap().keySet()));

		Assert.areEqual(fields.get('name'), Account.SObjectType.fields.Name); //behavior of FieldsMap is tested in another method
		Assert.areEqual(SObjectType.Account.fields.getMap().size(), fields.size());

		Assert.isNull(fields.get(null), 'Null input should result in null output.');
		Assert.isNull(fields.get(''), 'Invalid field name input should result in null output.');
	}

	@IsTest
	private static void fieldMap()
	{
		String fakeNamespace = 'ns_test';
		Map<String, SObjectField> fakeFieldData = new Map<String, SObjectField>
		{
				'name__c' => Contact.SObjectType.fields.Name, //re-use standard field types since we can't mock them
				fakeNamespace + '__name__c' => Account.SObjectType.fields.Name,
				fakeNamespace + '__otherField__c' => Account.SObjectType.fields.Name,
				'createdDate' => Contact.SObjectType.fields.CreatedDate
		};
		CMN_UTIL_SObjectDescribe.FieldsMap fields = new CMN_UTIL_SObjectDescribe.FieldsMap(fakeFieldData);
		fields.currentNamespace = fakeNamespace;
		Assert.isTrue(fields.containsKey('name__c'));
		Assert.isTrue(fields.containsKey(fakeNamespace.toUpperCase() + '__nAMe__c'));
		Assert.isTrue(fields.get('NAme__c') === fields.get(fakeNamespace + '__namE__c'));

		Assert.isTrue(!fields.keySet(false).contains('otherField__c'));
		Assert.isTrue(fields.keySet(false).contains(fakeNamespace + '__otherField__c'));

		Assert.isTrue(fields.keySet(true).contains('otherField__c'));
		Assert.isTrue(!fields.keySet(true).contains(fakeNamespace + '__otherField__c'));

		fields.currentNamespace = 'someOtherNamespace';
		Assert.areNotEqual(fields.get('name__C'), fields.get(fakeNamespace.capitalize() + '__nAme__c'));
	}

	@IsTest
	private static void globalDescribeMap()
	{
		String fakeNamespace = 'ns_test';
		Map<String, SObjectType> fakeFieldData = new Map<String, SObjectType>
		{
				'name__c' => Contact.SObjectType, //re-use standard object types since we can't mock them
				fakeNamespace + '__name__c' => Account.SObjectType,
				'createdDate' => Lead.SObjectType
		};
		CMN_UTIL_SObjectDescribe.GlobalDescribeMap gdm = new CMN_UTIL_SObjectDescribe.GlobalDescribeMap(fakeFieldData);
		gdm.currentNamespace = fakeNamespace;
		Assert.isTrue(gdm.containsKey('name__c'));
		Assert.isTrue(gdm.containsKey(fakeNamespace + '__name__c'));
		Assert.isTrue(gdm.get('name__c') === gdm.get(fakeNamespace + '__name__c'));

		gdm.currentNamespace = 'someOtherNamespace';
		Assert.areNotEqual(gdm.get('name__c'), gdm.get(fakeNamespace + '__name__c'));
	}

	//Tests all forms of the getDescribe static
	@IsTest
	private static void accountDescribes()
	{
		CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe('Account');
		CMN_UTIL_SObjectDescribe d2 = CMN_UTIL_SObjectDescribe.getDescribe(Account.SObjectType);
		CMN_UTIL_SObjectDescribe d3 = CMN_UTIL_SObjectDescribe.getDescribe(SObjectType.Account);
		Assert.areEqual('Account', d.getDescribe().getName());
		Assert.isTrue((d === d2 && d2 === d3), 'All three getDescribe calls should return the same cached instance.');
	}

	@IsTest
	private static void fieldDescribe()
	{
		CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe(Account.SObjectType);
		Map<String, SObjectField> fields;
		for(Integer i = 0; i < 10; i++)
		{
			fields = d.getFieldsMap();
		}

		Assert.isFalse(fields.isEmpty());
		Assert.areEqual(Account.SObjectType, d.getSObjectType());
	}

	@IsTest
	private static void fieldSetDescribe()
	{
		CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe(CMN_Foobar__c.SObjectType);
		Map<String, FieldSet> fields;
		for(Integer i = 0; i < 10; i++)
		{
			fields = d.getFieldSetsMap();
		}

		Assert.isFalse(fields.isEmpty(), 'No fields were described');
	}

	@IsTest
	private static void simpleAccountGetNameField()
	{
		CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe(Account.SObjectType);
		SObjectField nameField = d.getNameField();
		Assert.areEqual('Name', nameField.getDescribe().getName());
	}

	@IsTest
	private static void flushCache()
	{
		CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe('Account');
		CMN_UTIL_SObjectDescribe.flushCache();
		CMN_UTIL_SObjectDescribe d2 = CMN_UTIL_SObjectDescribe.getDescribe('Account');
		Assert.areNotEqual(d, d2, 'Second object should be a fresh instance after a cache flush.');
	}

	@IsTest
	private static void isPersonAccountEnabled()
	{
		Boolean isPersonAccountEnabled = Schema.SObjectType.Account.fields.getMap().containsKey(CMN_UTIL_SObjectDescribe.FIELD_IS_PERSON_ACCOUNT);
		Boolean isPersonAccountEnabledUsingMethod = CMN_UTIL_SObjectDescribe.isPersonAccountEnabled();
		Assert.areEqual(isPersonAccountEnabled, isPersonAccountEnabledUsingMethod, 'Incorrect value received');
	}

	@IsTest
	private static void rawGlobalDescribeCheck()
	{
		Map<String, SObjectType> systemGd = Schema.getGlobalDescribe();
		CMN_UTIL_SObjectDescribe.flushCache();
		Map<String, SObjectType> cachedGd = CMN_UTIL_SObjectDescribe.getRawGlobalDescribe();
		Assert.areEqual(systemGd.size(), cachedGd.size());
	}

	//Checks to see that the method returns the values in the global describe;
	@IsTest
	private static void valuesCheck()
	{
		Map<String, SObjectType> systemGd = Schema.getGlobalDescribe();
		CMN_UTIL_SObjectDescribe.flushCache();
		CMN_UTIL_SObjectDescribe.GlobalDescribeMap cachedGd = CMN_UTIL_SObjectDescribe.getGlobalDescribe();
		Assert.areEqual(systemGd.values().size(), cachedGd.values().size(), 'Value Lists do not match');
	}
}