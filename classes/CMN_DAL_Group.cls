/**
 * @description CMN_DAL_Group class provides base methods and example of how to use
 * the CMN_DAL_Group methods.
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_Group
{
	private static final String GROUP_TYPE_QUEUE = 'Queue';

	/**
	 * @description This method is use to get the lst of group by developer name
	 *
	 * @param developerName
	 *
	 * @return List
	 */
	public static List<Group> findQueueByDeveloperName(Set<String> developerName)
	{
		return
		[
				SELECT Id
				FROM Group
				WHERE Type = :GROUP_TYPE_QUEUE
				AND DeveloperName IN :developerName
		];
	}

	/**
	 * @description This method is use to get the list of groups
	 *
	 * @param developerName
	 *
	 * @return List
	 */
	public static Group findQueueByDeveloperName(String developerName)
	{
		List<Group> groups = findQueueByDeveloperName(new Set<String> {developerName});

		return groups.isEmpty() ? null : groups.iterator().next();
	}
}