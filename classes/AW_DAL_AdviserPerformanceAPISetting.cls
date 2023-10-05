/**
 * @description Public class to perform DAP operation for metadata
 *
 * @author Accenture
 *
 * @date 2019
 */
public class AW_DAL_AdviserPerformanceAPISetting
{

	/**
	 * @description This method is use to return the list of metadata
	 *
	 * @param configName
	 *
	 * @return
	 */
	public static List<AW_AdviserPerformanceAPISetting__mdt> getMetadata(String configName)
	{
		return
		[
				SELECT
						Id,
						AW_StartDate__c
				FROM AW_AdviserPerformanceAPISetting__mdt
				WHERE DeveloperName = :configName
		];
	}

}