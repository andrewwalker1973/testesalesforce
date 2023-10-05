/**
 * @description This Class to  construct  and  execute SOQL queries for community
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_Community
{

	/**
	 * @description Method to define the fields to retrieve for most queries
	 *
	 * @return A list of fields
	 */
	private static Set<String> getNetworkFields()
	{
		return new Set<String>
		{
				Network.Description.getDescribe().getLocalName(),
				Network.Id.getDescribe().getLocalName(),
				Network.Status.getDescribe().getLocalName(),
				Network.UrlPathPrefix.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method to define the fields to retrieve for most queries
	 *
	 * @return A list of fields
	 */
	private static Set<String> getMemberFields()
	{
		return new Set<String>
		{
				NetworkMember.NetworkId.getDescribe().getLocalName(),
				'Network.Status',
				'Network.UrlPathPrefix',
				'Network.Description'
		};
	}

	/**
	 * @description Get the list of Network by community name
	 *
	 * @param communityName The name of the community
	 *
	 * @return Either null or the item
	 */
	public static Network findByName(String communityName)
	{
		return (Network)CMN_DAL_SObjectSelector.findByName(Network.SObjectType, communityName, getNetworkFields());
	}

	/**
	 * @description Returns the a row if the current user belows to a Community with the given name
	 *
	 * @param communityName The name of the community
	 *
	 * @return Either a network member or null (if user isn't part of the community or community doesn't exist by name)
	 */
	public static NetworkMember findCurrentUserMember(String communityName)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(NetworkMember.SObjectType.getDescribe().getLocalName(), 'Network.Name', new Set<String> {communityName}, getMemberFields());

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(NetworkMember.MemberId.getDescribe().getLocalName(), CMN_SOQL_Query.Operator.EQUALS, UserInfo.getUserId()));
		searchParameters.addSearchCondition(andCondition);

		List<NetworkMember> foundMembers = CMN_DAL_Search.getObjects(searchParameters);

		return foundMembers.isEmpty() ? null : foundMembers.iterator().next();
	}
}