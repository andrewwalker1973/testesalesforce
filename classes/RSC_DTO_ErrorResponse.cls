/**
 * @description Common class used to handle Error response to show the actual errors
 *
 * @author rajpal.singh@accenture.com
 *
 * @date August 2022
 */
public inherited sharing class RSC_DTO_ErrorResponse extends CMN_DTO_JsonBase
{
	private static final String ERROR_UNEXPECTED = 'An unexpected error occurred.';

	/**
	 * @description Used to parse an error response
	 */
	private class DTO_ErrorResponse
	{
		private DTO_Error error;
	}

	/**
	 * @description Detail of error received
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	private class DTO_Error
	{
		private Integer errorCode;
		private String errorMessage;
	}

	/**
	 * @description If API encounters an error, this method will provide a user friendly error message
	 *
	 * @param callResult The callResult have the result of response from api class
	 *
	 * @return String actual error message
	 */
	public static String errorMessage(CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult)
	{
		String message;

		if(callResult.failed)
		{
			DTO_ErrorResponse dtoErrorResponse = (DTO_ErrorResponse)JSON.deserialize(callResult.responseBody, DTO_ErrorResponse.class);
			message = String.isNotBlank(dtoErrorResponse.error?.errorMessage) ? dtoErrorResponse.error.errorMessage : ERROR_UNEXPECTED;
		}

		return message;
	}
}