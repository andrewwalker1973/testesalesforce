/**
 * @description s the behaviour of JSONParse
 * <p/>
 * <p/>
 * MIT License
 * <p/>
 * Copyright (c) 2018 open-force https://github.com/open-force/jsonparse
 * <p/>
 * <p/>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p/>
 * <p/>
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * <p/>
 * <p/>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * @see CMN_UTIL_JsonPath
 *
 * @author open-force, jason.van.beukering@accenture.com
 *
 * @date 2018, August 2022
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_UTIL_JsonPath_TEST
{
	@IsTest
	private static void rawString()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('"HelloWorld"');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals('HelloWorld', parser.getStringValue());
	}

	@IsTest
	private static void rawBooleanFalse()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('false');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(false, parser.getBooleanValue());
	}

	@IsTest
	private static void rawBooleanTrue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('true');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(true, parser.getBooleanValue());
	}

	@IsTest
	private static void rawNull()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('null');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(null, parser.getValue());
	}

	@IsTest
	private static void rawInteger()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('42');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(42, parser.getIntegerValue());
	}

	@IsTest
	private static void rawDecimal()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('17.22');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(17.22, parser.getDecimalValue());
	}

	@IsTest
	private static void rawNumberWithENotation()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('1.2483e+2');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(124.83, parser.getDecimalValue());
	}

	@IsTest
	private static void simpleGet()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE1);
		System.assertEquals(true, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals('File', parser.get('menu.value').getStringValue());
		System.assertEquals('File', parser.get('menu.value').getValue());
	}

	@IsTest
	private static void arrayGet()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE1);
		System.assertEquals(true, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals('OpenDoc()', parser.get('menu.popup.menuitem.[1].onclick').getValue());
	}

	@IsTest
	private static void numberGet()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE2);
		System.assertEquals(true, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(100, parser.get('widget.text.vOffset').getIntegerValue());
	}

	@IsTest
	private static void compoundGet()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE1);
		System.assertEquals(true, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals('Close', parser.get('menu').get('popup.menuitem').get('[2].value').getStringValue());
	}

	@IsTest
	private static void asMap()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE1);
		System.assertEquals(true, parser.isObject());
		System.assertEquals(false, parser.isArray());
		Map<String, CMN_UTIL_JsonPath> theMap = parser.get('menu').asMap();
		System.assertEquals(3, theMap.size());
		System.assertEquals(false, theMap.get('id').isObject());
		System.assertEquals(false, theMap.get('id').isArray());
		System.assertEquals('file', theMap.get('id').getValue());
		System.assertEquals(true, theMap.get('popup').isObject());
		System.assertEquals(false, theMap.get('popup').isArray());
	}

	@IsTest
	private static void asList()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE3);
		System.assertEquals(false, parser.isObject());
		System.assertEquals(true, parser.isArray());
		List<CMN_UTIL_JsonPath> items = parser.asList();
		System.assertEquals(5, items.size());
		System.assertEquals('ksm@pobox.com', items[0].get('init-param.configGlossary:adminEmail').getValue());
		System.assertEquals(true, items[1].get('init-param').isObject());
		System.assertEquals('cofaxEmail', items[1].get('servlet-name').getStringValue());
	}

	@IsTest
	private static void outOfBoundsException()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE3);

		try
		{
			parser.get('[7]');
			System.assert(false, 'We used an index outside the bounds of our array, should have seen an exception about that.');
		}
		catch(ListException e)
		{
			System.assertEquals('List index out of bounds: 7', e.getMessage());
		}
	}

	@IsTest
	private static void missingKeyException()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE2);

		try
		{
			parser.get('badKey');
			System.assert(false, 'Our key was invalid, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.MissingKeyException e)
		{
			System.assertEquals('No match found for <badKey>: {widget}', e.getMessage());
		}
	}

	@IsTest
	private static void rootNotAnObjectException()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE3);

		try
		{
			parser.asMap();
			System.assert(false, 'Root node is not an object, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.NotAnObjectException e)
		{
			System.assert(e.getMessage().startsWith('The wrapped value is not a JSON object:'));
		}
	}

	@IsTest
	private static void getNotAnObjectException()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE1);

		try
		{
			parser.get('menu.popup.menuitem.first');
			System.assert(false, 'Node is not an object, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.NotAnObjectException e)
		{
			System.assert(e.getMessage().startsWith('The wrapped value is not a JSON object:'));
		}
	}

	@IsTest
	private static void rootNotAnArrayException()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE2);

		try
		{
			parser.asList();
			System.assert(false, 'Root node is not an array, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.NotAnArrayException e)
		{
			System.assert(e.getMessage().startsWith('The wrapped value is not a JSON array:'));
		}
	}

	@IsTest
	private static void getNotAnArrayException()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE1);

		try
		{
			parser.get('menu.popup.[0]');
			System.assert(false, 'Node is not an array, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.NotAnArrayException e)
		{
			System.assert(e.getMessage().startsWith('The wrapped value is not a JSON array:'));
		}
	}

	@IsTest
	private static void existsGoodKey()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE1);

		System.assertEquals(true, parser.exists('menu.popup.menuitem.[1].onclick'));
	}

	@IsTest
	private static void existsNoIntermediaryKey()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE1);

		System.assertEquals(false, parser.exists('menu.popup.menuitems.[1].onclick'));
	}

	@IsTest
	private static void existsNoKey()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE1);

		System.assertEquals(false, parser.exists('menu.popup.menuitem.[1].onexplosion'));
	}

	@IsTest
	private static void existsGoodIndex()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE3);

		System.assertEquals(true, parser.exists('[1]'));
	}

	@IsTest
	private static void existsBadIndex()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath(SAMPLE3);

		System.assertEquals(false, parser.exists('[7]'));
	}

	@IsTest
	private static void existsButNull()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('{"myCount": null}');

		System.assertEquals(false, parser.exists('myCount', true));
	}

	@IsTest
	private static void getBlobValue()
	{

		Blob helloWorld = Blob.valueOf('HelloWorld');
		String encoded = EncodingUtil.base64Encode(helloWorld);

		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('"' + encoded + '"');
		System.assertEquals(encoded, parser.getStringValue());
		System.assertEquals(helloWorld, parser.getBlobValue());

		try
		{
			parser = new CMN_UTIL_JsonPath('42');
			parser.getBlobValue();
			System.assert(false, 'Node is not a valid Blob, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('Only String values can be converted to a Blob: 42', e.getMessage());
		}
	}

	@IsTest
	private static void getBooleanValue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('false');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(false, parser.getBooleanValue());

		parser = new CMN_UTIL_JsonPath('"false"');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(false, parser.getBooleanValue());

		parser = new CMN_UTIL_JsonPath('"FALSE"');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(false, parser.getBooleanValue());

		parser = new CMN_UTIL_JsonPath('true');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(true, parser.getBooleanValue());

		parser = new CMN_UTIL_JsonPath('"true"');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(true, parser.getBooleanValue());

		parser = new CMN_UTIL_JsonPath('"TRUE"');
		System.assertEquals(false, parser.isObject());
		System.assertEquals(false, parser.isArray());
		System.assertEquals(true, parser.getBooleanValue());
	}

	@IsTest
	private static void getDatetimeValue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('"2011-03-22T13:01:23"');
		System.assertEquals(Datetime.newInstanceGmt(2011, 3, 22, 13, 1, 23), parser.getDatetimeValue());

		parser = new CMN_UTIL_JsonPath('1538783039073');
		System.assertEquals(Datetime.newInstanceGmt(2018, 10, 05, 23, 43, 59), parser.getDatetimeValue());

		try
		{
			parser = new CMN_UTIL_JsonPath('[1,2,3]');
			parser.getDatetimeValue();
			System.assert(false, 'Node is not a valid Datetime, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('Only Long and String values can be converted to a Datetime: [ 1, 2, 3 ]', e.getMessage());
		}
	}

	@IsTest
	private static void getDateValue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('"2011-03-22"');
		System.assertEquals(Date.newInstance(2011, 3, 22), parser.getDateValue());

		parser = new CMN_UTIL_JsonPath('1538783039073');
		System.assertEquals(Date.newInstance(2018, 10, 05), parser.getDateValue());

		try
		{
			parser = new CMN_UTIL_JsonPath('[1,2,3]');
			parser.getDateValue();
			System.assert(false, 'Node is not a valid Date, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('Only Long and String values can be converted to a Date: [ 1, 2, 3 ]', e.getMessage());
		}
	}

	@IsTest
	private static void getDecimalValue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('12');
		System.assertEquals(12.0, parser.getDecimalValue());

		parser = new CMN_UTIL_JsonPath('12.5');
		System.assertEquals(12.5, parser.getDecimalValue());

		parser = new CMN_UTIL_JsonPath('"12.5"');
		System.assertEquals(12.5, parser.getDecimalValue());

		parser = new CMN_UTIL_JsonPath('1538783039073');
		System.assertEquals(1538783039073.0, parser.getDecimalValue());

		try
		{
			parser = new CMN_UTIL_JsonPath('[1,2,3]');
			parser.getDecimalValue();
			System.assert(false, 'Node is not a valid Decimal, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('This value cannot be converted to a Decimal: [ 1, 2, 3 ]', e.getMessage());
		}
	}

	@IsTest
	private static void getDoubleValue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('12');
		System.assertEquals(12.0, parser.getDoubleValue());

		parser = new CMN_UTIL_JsonPath('12.5');
		System.assertEquals(12.5, parser.getDoubleValue());

		parser = new CMN_UTIL_JsonPath('"12.5"');
		System.assertEquals(12.5, parser.getDoubleValue());

		parser = new CMN_UTIL_JsonPath('1538783039073');
		System.assertEquals(1538783039073.0, parser.getDoubleValue());

		try
		{
			parser = new CMN_UTIL_JsonPath('[1,2,3]');
			parser.getDoubleValue();
			System.assert(false, 'Node is not a valid Double, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('This value cannot be converted to a Double: [ 1, 2, 3 ]', e.getMessage());
		}
	}

	@IsTest
	private static void getIdValue()
	{

		Account a = new Account(Name = 'Acme');
		insert a;

		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('"' + String.valueOf(a.Id) + '"');
		System.assertEquals(a.Id, parser.getIdValue());

		try
		{
			parser = new CMN_UTIL_JsonPath('[1,2,3]');
			parser.getIdValue();
			System.assert(false, 'Node is not a valid Id, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('This value cannot be converted to an Id: [ 1, 2, 3 ]', e.getMessage());
		}
	}

	@IsTest
	private static void getIntegerValue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('12');
		System.assertEquals(12, parser.getIntegerValue());

		parser = new CMN_UTIL_JsonPath('"12"');
		System.assertEquals(12, parser.getIntegerValue());

		parser = new CMN_UTIL_JsonPath('12.5');
		System.assertEquals(12, parser.getIntegerValue());

		parser = new CMN_UTIL_JsonPath('1538783039073');
		System.assertEquals(1184747105, parser.getIntegerValue()); // integer gets truncated

		try
		{
			parser = new CMN_UTIL_JsonPath('[1,2,3]');
			parser.getIntegerValue();
			System.assert(false, 'Node is not a valid Integer, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('This value cannot be converted to an Integer: [ 1, 2, 3 ]', e.getMessage());
		}
	}

	@IsTest
	private static void getLongValue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('12');
		System.assertEquals(12, parser.getLongValue());

		parser = new CMN_UTIL_JsonPath('"12"');
		System.assertEquals(12, parser.getLongValue());

		parser = new CMN_UTIL_JsonPath('12.5');
		System.assertEquals(12, parser.getLongValue());

		parser = new CMN_UTIL_JsonPath('1538783039073');
		System.assertEquals(1538783039073L, parser.getLongValue());

		try
		{
			parser = new CMN_UTIL_JsonPath('[1,2,3]');
			parser.getLongValue();
			System.assert(false, 'Node is not a valid Long, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('This value cannot be converted to a Long: [ 1, 2, 3 ]', e.getMessage());
		}
	}

	@IsTest
	private static void getStringValue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('"HelloWorld"');
		System.assertEquals('HelloWorld', parser.getStringValue());

		parser = new CMN_UTIL_JsonPath('true');
		System.assertEquals('true', parser.getStringValue());

		parser = new CMN_UTIL_JsonPath('null');
		System.assertEquals(null, parser.getStringValue());

		parser = new CMN_UTIL_JsonPath('12.5');
		System.assertEquals('12.5', parser.getStringValue());

		try
		{
			parser = new CMN_UTIL_JsonPath('{}');
			parser.getStringValue();
			System.assert(false, 'Node is not a valid String, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('Objects and arrays are not Strings: { }', e.getMessage());
		}

		try
		{
			parser = new CMN_UTIL_JsonPath('[]');
			parser.getStringValue();
			System.assert(false, 'Node is not a valid String, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('Objects and arrays are not Strings: [ ]', e.getMessage());
		}
	}

	@IsTest
	private static void getTimeValue()
	{
		CMN_UTIL_JsonPath parser = new CMN_UTIL_JsonPath('"2011-03-22T13:01:23"');
		System.assertEquals(Time.newInstance(13, 1, 23, 0), parser.getTimeValue());

		parser = new CMN_UTIL_JsonPath('1538783039073');
		System.assertEquals(Time.newInstance(23, 43, 59, 73), parser.getTimeValue());

		try
		{
			parser = new CMN_UTIL_JsonPath('[1,2,3]');
			parser.getTimeValue();
			System.assert(false, 'Node is not a valid Time, should have seen an exception about that.');
		}
		catch(CMN_UTIL_JsonPath.InvalidConversionException e)
		{
			System.assertEquals('Only Long and String values can be converted to a Time: [ 1, 2, 3 ]', e.getMessage());
		}
	}

	// Some JSON samples from https://json.org/example.html
	private static final String SAMPLE1 = '{"menu":{"id":"file","value":"File","popup":{"menuitem":[{"value":"New","onclick":"CreateNewDoc()"},{"value":"Open",' +
			'"onclick":"OpenDoc()"},{"value":"Close","onclick":"CloseDoc()"}]}}}';
	private static final String SAMPLE2 = '{"widget":{"debug":"on","window":{"title":"SampleKonfabulatorWidget","name":"main_window","width":500,"height":500},' +
			'"image":{"src":"Images/Sun.png","name":"sun1","hOffset":250,"vOffset":250,"alignment":"center"},"text":{"data":"ClickHere","size":36,"style":"bold",' +
			'"name":"text1","hOffset":250,"vOffset":100,"alignment":"center","onMouseUp":"sun1.opacity=(sun1.opacity/100)*90;"}}}';
	private static final String SAMPLE3 = '[{"servlet-name":"cofaxCDS","servlet-class":"org.cofax.cds.CDSServlet","init-param":{"configGlossary:installationAt":' +
			'"Philadelphia,PA","configGlossary:adminEmail":"ksm@pobox.com","configGlossary:poweredBy":"Cofax","configGlossary:poweredByIcon":"/images/cofax.gif",' +
			'"configGlossary:staticPath":"/content/static","templateProcessorClass":"org.cofax.WysiwygTemplate","templateLoaderClass":' +
			'"org.cofax.FilesTemplateLoader","templatePath":"templates","templateOverridePath":"","defaultListTemplate":"listTemplate.htm","defaultFileTemplate":' +
			'"articleTemplate.htm","useJSP":false,"jspListTemplate":"listTemplate.jsp","jspFileTemplate":"articleTemplate.jsp","cachePackageTagsTrack":200,' +
			'"cachePackageTagsStore":200,"cachePackageTagsRefresh":60,"cacheTemplarack":100,"cacheTemplatesStore":50,"cacheTemplatesRefresh":15,' +
			'"cachePagesTrack":200,"cachePagesStore":100,"cachePagesRefresh":10,"cachePagesDirtyRead":10,"searchEngineListTemplate":"forSearchEnginesList.htm",' +
			'"searchEngineFileTemplate":"forSearchEngines.htm","searchEngineRobotsDb":"WEB-INF/robots.db","useDataStore":true,"dataStoreClass":' +
			'"org.cofax.SqlDataStore","redirectionClass":"org.cofax.SqlRedirection","dataStoreName":"cofax","dataStoreDriver":"com.microsoft.jdbc.sqlserver.' +
			'SQLServerDriver","dataStoreUrl":"jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon","dataStoreUser":"sa","dataStorePassword":' +
			'"dataStoreTestQuery","dataStoreTestQuery":"SETNOCOUNTON;selecttest=\'test\';","dataStoreLogFile":"/usr/local/tomcat/logs/datastore.log",' +
			'"dataStoreInitConns":10,"dataStoreMaxConns":100,"dataStoreConnUsageLimit":100,"dataStoreLogLevel":"debug","maxUrlLength":500}},{"servlet-name":' +
			'"cofaxEmail","servlet-class":"org.cofax.cds.EmailServlet","init-param":{"mailHost":"mail1","mailHostOverride":"mail2"}},{"servlet-name":"cofaxAdmin"' +
			',"servlet-class":"org.cofax.cds.AdminServlet"},{"servlet-name":"fileServlet","servlet-class":"org.cofax.cds.FileServlet"},{"servlet-name":' +
			'"cofaxTools","servlet-class":"org.cofax.cms.CofaxToolsServlet","init-param":{"templatePath":"toolstemplates/","log":1,"logLocation":"' +
			'/usr/local/tomcat/logs/CofaxTools.log","logMaxSize":"","dataLog":1,"dataLogLocation":"/usr/local/tomcat/logs/dataLog.log","dataLogMaxSize":"",' +
			'"removePageCache":"/content/admin/remove?cache=pages&id=","removeTemplateCache":"/content/admin/remove?cache=templates&id=","fileTransferFolder":' +
			'"/usr/local/tomcat/webapps/content/fileTransferFolder","lookInContext":1,"adminGroupID":4,"betaServer":true}}]';
}