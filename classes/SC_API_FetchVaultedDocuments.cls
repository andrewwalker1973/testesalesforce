/**
 * @description Service class to make the API call to retrieve list of vaulted documents
 *
 * @see SC_API_FetchVaultedDocuments_TEST @story ST-118605,ST-178029,ST-284351
 *
 * @author nihal.desai@accenture.com, jayanth.kumar.s@accenture.com darrion.james.singh@accenture.com
 *
 * @date May 2021, April 2022
 */
public inherited sharing class SC_API_FetchVaultedDocuments extends CMN_API_FetchVaultedDocuments
{
	/**
	 * @description Service name to be used when looking up custom settings
	 */
	public static final String SERVICE_NAME = SC_API_FetchVaultedDocuments.class.getName();

	/**
	 * @description Override to get Service name to be used when looking up custom settings for the service
	 *
	 * @return String Returns service name as string
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}
}