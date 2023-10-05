/**
 * @description Public class to return the records of Communication Template Map metadata
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_DAL_CommunicationTemplateMap
{
	/**
	 * @description stores the template name for Outstanding Requirements
	 */
	public static final String TEMPLATE_OUTSTANDING_REQUIREMENTS = 'RSC_OutstandingRequirements';

	/**
	 * @description This method is use to get the communication template for the provided developer name
	 *
	 * @param developerName Developer name of the metadata record
	 *
	 * @return relevant communication template record
	 */
	public static CMN_CommunicationTemplateMap__mdt findByName(String developerName)
	{
		return CMN_CommunicationTemplateMap__mdt.getInstance(developerName);
	}
}