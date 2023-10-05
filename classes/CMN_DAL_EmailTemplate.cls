/**
 * @description Provides Query methods related to EmailTemplate object
 *
 * @author darrion.james.singh@accenture.com uttpal.chandra@accenture.com
 *
 * @date March 2021, June 2022
 */
public inherited sharing class CMN_DAL_EmailTemplate
{
	/**
	 * @description SObject Name
	 */
	private static final String OBJECT_NAME = EmailTemplate.SObjectType.getDescribe().getLocalName();
	/**
	 * @description Unique Name for Email template
	 */
	public static final String FIELD_DEVELOPER_NAME = EmailTemplate.DeveloperName.getDescribe().getLocalName();

	@TestVisible
	public static final String TEST_EMAIL_TEMPLATE = 'CMN_ExampleForTesting';

	/**
	 * @description Returns the default fields to return when querying the EmailTemplate Object
	 *
	 * @return A list of field names
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
	{
				EmailTemplate.Id.getDescribe().getLocalName(),
				EmailTemplate.Name.getDescribe().getLocalName(),
				EmailTemplate.Subject.getDescribe().getLocalName(),
				FIELD_DEVELOPER_NAME
		};
	}

	/**
	 * @description Will retrieve on or more EmailTemplates
	 *
	 * @param uniqueNames A list of DeveloperNames for Template
	 *
	 * @return A list of EmailTemplates
	 */
	public static List<EmailTemplate> findByName(Set<String> uniqueNames)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_DEVELOPER_NAME, uniqueNames, getDefaultFields());
	}

	/**
	 * @description Will retrieve on or more EmailTemplates
	 *
	 * @param uniqueName DeveloperName for Template
	 *
	 * @return null or item
	 */
	public static EmailTemplate findByName(String uniqueName)
	{
		return (EmailTemplate)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_DEVELOPER_NAME, uniqueName, getDefaultFields(), true);
	}
}