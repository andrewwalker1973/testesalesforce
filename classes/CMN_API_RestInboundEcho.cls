/**
 * @description This is An example Inbound API call that will echo exactly what was sent
 *
 * @see CMN_API_RestInboundEcho_TEST
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2019, July 2023
 */
public inherited sharing class CMN_API_RestInboundEcho extends CMN_API_RestBaseInbound
{
	/**
	 * @description sets response to the requestBody
	 */
	protected override void updateCallResult()
	{
		super.updateCallResult();

		// ensure we echo back exactly what was sent
		callResult.responseBody = requestBody;
	}

	/**
	 * @description Ensures that response Content-Type mimics that of the request Content-Type
	 */
	protected override void writeResponse()
	{
		super.writeResponse();

		/* ensure we echo back the content type sent */
		RestContext.response.headers.put(CMN_API_HttpBase.HTTP_CONTENT_TYPE, RestContext.request.headers.get(CMN_API_HttpBase.HTTP_CONTENT_TYPE));
	}
}