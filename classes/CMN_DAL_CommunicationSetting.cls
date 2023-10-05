/**
 * @description Data Access Layer SOQL related to the CustomMetadata Setting for the Communication Setting,
 * this is common class to be used across applications
 *
 * @author Accenture - nihal.desai@accenture.com
 *
 * @date September 2021
 */
public inherited sharing class CMN_DAL_CommunicationSetting
{
	private static final String DEFAULT_DEVELOPER_NAME = 'CMN_LibertyGroupLimited';

	/**
	 * @description This method is use to get the custom setting metadata for the communication setting.
	 *
	 * @return relevant communication setting data
	 */
	public static CMN_CommunicationSetting__mdt getInstance()
	{
		return CMN_CommunicationSetting__mdt.getInstance(DEFAULT_DEVELOPER_NAME);
	}
}