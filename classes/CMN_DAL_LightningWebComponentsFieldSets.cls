/**
 * @description Common Controller used to provide query methods related to  CMN_LightningWebComponentsFieldSet__mdt Custom Metadata object
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date January 2022
 */
public inherited sharing class CMN_DAL_LightningWebComponentsFieldSets
{
	private static final String OBJECT_NAME = CMN_LightningWebComponentsFieldSet__mdt.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_DEVELOPER_NAME = CMN_LightningWebComponentsFieldSet__mdt.DeveloperName.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CMN_DAL_SObjectDomain.FIELD_ID,
				CMN_LightningWebComponentsFieldSet__mdt.CMN_LWCActiveSections__c.getDescribe().getLocalName(),
				CMN_LightningWebComponentsFieldSet__mdt.CMN_LWCFieldSets__c.getDescribe().getLocalName(),
				FIELD_DEVELOPER_NAME
		};
	}

	/**
	 * @description This method is used to get the CMN_LightningWebComponentsFieldSet metadata records by its DeveloperName
	 *
	 * @param developerName The set of custom metadata developerName
	 *
	 * @return Null or Item found
	 */
	public static CMN_LightningWebComponentsFieldSet__mdt findByDeveloperName(String developerName)
	{
		return (CMN_LightningWebComponentsFieldSet__mdt)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_DEVELOPER_NAME, developerName, getDefaultFields(), true);
	}

	/**
	 * @description Will return all CMN_LightningWebComponentsFieldSet__mdt for unit tests
	 *
	 * @return A list of CMN_LightningWebComponentsFieldSet__mdt
	 */
	@TestVisible
	private static List<CMN_LightningWebComponentsFieldSet__mdt> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}