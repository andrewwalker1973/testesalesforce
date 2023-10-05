/**
 * @description Provides Query methods related to Case object
 *
 * @author Accenture
 *
 * @date Apr 2021
 */
public inherited sharing class CMN_DAL_Case
{
	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Case fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				Case.AccountId.getDescribe().getLocalName(),
				Case.CaseNumber.getDescribe().getLocalName(),
				Case.Comments.getDescribe().getLocalName(),
				Case.ContactEmail.getDescribe().getLocalName(),
				Case.ContactId.getDescribe().getLocalName(),
				Case.CreatedDate.getDescribe().getLocalName(),
				Case.Description.getDescribe().getLocalName(),
				Case.Id.getDescribe().getLocalName(),
				Case.IsEscalated.getDescribe().getLocalName(),
				Case.Origin.getDescribe().getLocalName(),
				Case.OwnerId.getDescribe().getLocalName(),
				Case.Priority.getDescribe().getLocalName(),
				Case.Reason.getDescribe().getLocalName(),
				Case.Status.getDescribe().getLocalName(),
				Case.Subject.getDescribe().getLocalName(),
				Case.SuppliedCompany.getDescribe().getLocalName(),
				Case.SuppliedEmail.getDescribe().getLocalName(),
				Case.SuppliedName.getDescribe().getLocalName(),
				Case.SuppliedPhone.getDescribe().getLocalName(),
				Case.Type.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will return all the Cases in the system
	 *
	 * @return A list of Cases
	 */
	@TestVisible
	private static List<Case> getAll()
	{
		return CMN_DAL_Search.getAll(Case.SObjectType, getDefaultFields());
	}
}