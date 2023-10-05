/**
 * @description Public class to return the records of Benefit Code And Category Mapping metadata
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class AW_DAL_BenefitCodeAndCategoryMapping
{
	public static final String FIELD_TYPE_CODE = AW_BenefitCodeAndCategoryMapping__mdt.AW_TypeCode__c.getDescribe().getLocalName();
	public static final String FIELD_BENEFIT_NAME = AW_BenefitCodeAndCategoryMapping__mdt.AW_BenefitName__c.getDescribe().getLocalName();
	public static final String OBJECT_NAME = AW_BenefitCodeAndCategoryMapping__mdt.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_BenefitCodeAndCategoryMapping__mdt.AW_CoverSubCategory__c.getDescribe().getLocalName(),
				AW_BenefitCodeAndCategoryMapping__mdt.AW_CoverCategory__c.getDescribe().getLocalName(),
				AW_BenefitCodeAndCategoryMapping__mdt.MasterLabel.getDescribe().getLocalName(),
				FIELD_BENEFIT_NAME,
				FIELD_TYPE_CODE
		};
	}

	/**
	 * @description This method is use to get the list of all Benefit Code And CategoryMapping
	 *
	 * @return List of BenefitCodeAndCategoryMapping
	 */
	public static List<AW_BenefitCodeAndCategoryMapping__mdt> getAll()
	{
		return AW_BenefitCodeAndCategoryMapping__mdt.getAll().values();
	}

	/**
	 * @description This method is use to get the the Benefit Code And CategoryMapping
	 *
	 * @param benefitName Benefit Name in AW_BenefitCodeAndCategoryMapping__mdt
	 *
	 * @return A single record of BenefitCodeAndCategoryMapping
	 */
	@TestVisible
	private static AW_BenefitCodeAndCategoryMapping__mdt getBenefitCodeMapping(String benefitName)
	{
		return (AW_BenefitCodeAndCategoryMapping__mdt)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_BENEFIT_NAME, benefitName, getDefaultFields(), false);
	}
}