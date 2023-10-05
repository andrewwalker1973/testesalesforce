/**
 * @description Base API class for Communications related API calls
 *
 * @see CMN_FLOW_SendCommunication_TEST @story ST-146934
 *
 * @author aakriti.a.goyal@accenture.com darrion.james.singh@accenture.com
 *
 * @date April 2022
 */
public inherited sharing virtual class CMN_API_GuidedInteraction extends CMN_API_RestBaseOutboundMule
{
	/**
	 * @description Required parameter to be passed to the handler else call will be aborted
	 */
	public static final String PARAMETER_REQUEST_BODY = 'requestBody';

	/**
	 * @description Returns the list of required parameters need to execute the request
	 *
	 * @return A list of required service parameters
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected virtual override Set<String> getRequiredParameters()
	{
		Set<String> parameters = super.getRequiredParameters();

		parameters.add(PARAMETER_REQUEST_BODY);

		return parameters;
	}

	/**
	 * @description Will return the body the HTTP request
	 *
	 * @return HTTP Body
	 */
	protected virtual override String getBody()
	{
		return requestParameters.getFirst(PARAMETER_REQUEST_BODY);
	}
}