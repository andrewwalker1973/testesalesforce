/**
 * @description Public class to return the record of Occupation
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_Occupation
{
	public static final Integer OCCUPATION_CODE_LENGTH = 6;
	public static final String OBJECT_NAME = AW_Occupation__c.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_OCCUPATION_CODE = AW_Occupation__c.AW_OccupationCode__c.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				AW_Occupation__c.AW_OccupationCode__c.getDescribe().getLocalName(),
				AW_Occupation__c.Name.getDescribe().getLocalName(),
				AW_Occupation__c.Id.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method is to return record of occupation by Occupation Id
	 *
	 * @param occupationId Id of the record
	 *
	 * @return Either null of item
	 */
	public static AW_Occupation__c findById(Id occupationId)
	{
		return (AW_Occupation__c)CMN_DAL_SObjectSelector.findById(AW_Occupation__c.SObjectType, occupationId, getDefaultFields());
	}
	/**
	 * @description Method is to return record of occupation by Occupation code
	 *
	 * @param occupationCode code of the occupation
	 *
	 * @return object or null
	 */
	public static AW_Occupation__c findByOccupationCode(String occupationCode)
	{
		return (AW_Occupation__c)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_OCCUPATION_CODE, occupationCode, getDefaultFields(), false);
	}
}