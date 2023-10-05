/**
 * @description Provides Queries related to NamedCredential object
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_NamedCredential
{

	/**
	 * @description This method is use to return the list of NamedCredential
	 *
	 * @param credentialName as input
	 *
	 * @return soql
	 */
	public static NamedCredential findByName(String credentialName)
	{
		List<NamedCredential> credentials =
		[
				SELECT
						Endpoint,
						Id
				FROM NamedCredential
				WHERE DeveloperName = :credentialName

		];

		return credentials.isEmpty() ? null : credentials.iterator().next();
	}
}