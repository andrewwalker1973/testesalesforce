/**
 * @description Base class for outbound messages going to Mule ESB
 *
 * @author Accenture
 *
 * @date 2019
 */
public virtual class CMN_API_RestBaseOutboundMule extends CMN_API_RestBaseOutbound
{

	private static final String HTTP_HEADER_CLIENT_ID = 'client_id';
	private static final String HTTP_HEADER_CLIENT_SECRET = 'client_secret';
	private static final String HTTP_HEADER_TRANSACTION_ID = 'transaction_id';
	private static final String HTTP_HEADER_ORG_CLIENT_ID = 'org_client_id';

	protected String getTransactionID()
	{
		return settings != null ? settings.CMN_CompanyID__c : CMN_UTIL_String.EMPTY;
	}

	protected String getOrgClientId()
	{
		return settings != null ? settings.CMN_ApiKey__c : CMN_UTIL_String.EMPTY;
	}

	protected virtual override void setHeaders()
	{
		super.setHeaders();

		request.setHeader(HTTP_HEADER_CLIENT_ID, getClientId());
		request.setHeader(HTTP_HEADER_CLIENT_SECRET, getClientSecret());
		request.setHeader(HTTP_HEADER_TRANSACTION_ID, getTransactionID());
		request.setHeader(HTTP_HEADER_ORG_CLIENT_ID, getOrgClientId());
	}
}