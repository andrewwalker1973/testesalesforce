/**
 * @description Public class to query Region Mapping custom metadata
 *
 * @see SC_RegionMapping__mdt
 *
 * @author mthobisi.ndlovu@accenture.com
 *
 * @date August 2022
 */
public inherited sharing class SC_DAL_RegionMapping
{
	/**
	 * @description Method returns a map containing region mapping custom metadata records
	 * 				with the map keys being the developerNames of the records.
	 *
	 * @return A map of region mapping records
	 */
	public static Map<String, SC_RegionMapping__mdt> getAll()
	{
		return SC_RegionMapping__mdt.getAll();
	}
}