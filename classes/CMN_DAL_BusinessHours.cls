/**
 * @description Class containing queries related to business hours
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date October 2021
 */
public inherited sharing class CMN_DAL_BusinessHours
{
	/**
	 * @description Will return the business hours record that is default for the current org
	 *
	 * @return default business hours
	 */
	public static BusinessHours getDefaultBusinessHours()
	{
		List<BusinessHours> foundBusinessHours =
		[
				SELECT
						Id,
						Name
				FROM BusinessHours
				WHERE IsDefault = TRUE
		];

		return foundBusinessHours.isEmpty() ? null : foundBusinessHours.iterator().next();
	}
}