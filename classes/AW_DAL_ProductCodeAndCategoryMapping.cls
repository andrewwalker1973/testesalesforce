/**
 * @description Public class to return the records of Product Code And Category Mapping metadata
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2021, December 2022
 */
public inherited sharing class AW_DAL_ProductCodeAndCategoryMapping
{
	private static final String FIELD_SALESFORCE_OBJECT = AW_ProductCodeAndCategoryMapping__mdt.AW_SalesforceObject__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME = AW_ProductCodeAndCategoryMapping__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description Api name of the Product Code field
	 */
	public static final String FIELD_PRODUCT_CODE = AW_ProductCodeAndCategoryMapping__mdt.AW_ProductCode__c.getDescribe().getLocalName();
	/**
	 * @description Api name of the Prototype field
	 */
	public static final String FIELD_PROTO_TYPE = AW_ProductCodeAndCategoryMapping__mdt.AW_Prototype__c.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_ProductCodeAndCategoryMapping__mdt.AW_ProductCategory__c.getDescribe().getLocalName(),
				AW_ProductCodeAndCategoryMapping__mdt.AW_ProductSubCategory__c.getDescribe().getLocalName(),
				AW_ProductCodeAndCategoryMapping__mdt.DeveloperName.getDescribe().getLocalName(),
				FIELD_PRODUCT_CODE,
				FIELD_PROTO_TYPE,
				FIELD_SALESFORCE_OBJECT
		};
	}

	/**
	 * @description This method is use to get the list of all ProductCode And CategoryMapping
	 *
	 * @return List of ProductCodeAndCategoryMapping
	 */
	public static List<AW_ProductCodeAndCategoryMapping__mdt> getAll()
	{
		return AW_ProductCodeAndCategoryMapping__mdt.getAll().values();
	}

	/**
	 * @description Will find a random item by object name
	 *
	 * @param objectName The API name of an object with which to filter the mappings
	 *
	 * @return Found random item
	 */
	public static AW_ProductCodeAndCategoryMapping__mdt findRandomByObjectName(String objectName)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.searchConditions.equalsX(FIELD_SALESFORCE_OBJECT, objectName);
		return (AW_ProductCodeAndCategoryMapping__mdt)CMN_DAL_Search.getRandomItem(searchParameters);
	}
}