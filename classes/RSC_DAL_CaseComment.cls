/**
 * @description Public class to return the records of CaseComment
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date 2021
 */
public inherited sharing class RSC_DAL_CaseComment
{
	private static final String OBJECT_NAME = CaseComment.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				CaseComment.CommentBody.getDescribe().getLocalName(),
				CaseComment.Id.getDescribe().getLocalName(),
				CaseComment.ParentId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will return all Cases created by unit tests
	 *
	 * @return A list of Case Comments
	 */
	@TestVisible
	private static List<CaseComment> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}