/**
 * @description Class representing the JSON structure of user sync Inbound & Outbound APIs
 *
 * @author Futureform
 *
 * @date December 2022
 */
public inherited sharing class SLC_DTO_User
{
	/**
	 * @description stores User's first name
	 */
	public String givenName;
	/**
	 * @description stores User's last name
	 */
	public String familyName;
	/**
	 * @description stores the User's id/passport number on user create/update
	 */
	public String identityNumber;
	/**
	 * @description stores the User's email address
	 */
	public String email;
	/**
	 * @description stores the User's phone number
	 */
	public String phoneNumber;
   
}