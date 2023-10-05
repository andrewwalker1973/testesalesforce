/**
 * @description Public class to return the records of Event To Webservice Queue Field Mapping metadata
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_EventToWebserviceFieldMapping
{
	/**
	 * @description This method is use to get the list of Event To Webservice Queue Field Mapping metadata
	 *
	 * @return List of Event To Webservice Queue Field Mapping metadata
	 */
	public static List<AW_EventToWebserviceQueueFieldMapping__mdt> getAll()
	{
		return AW_EventToWebserviceQueueFieldMapping__mdt.getAll().values();
	}
}