/**
 * @description The purpose of the apex class is to enable users in a community to create a lead in Salesforce.
 */
public without sharing class AW_FLOW_NewLead
{

	/**
	 * @description Method to create a lead and set the owner to community user account owner
	 *
	 * @param dtoLeads List of DTO_Lead wrapper class
	 */
	@InvocableMethod(Label='Create a Lead' Description='Method to create a lead and set the owner to community user account owner')
	public static void newItems(List<DTO_Lead> dtoLeads)
	{
		List<Lead> newLeads = new List<Lead>();
		Lead newLead;

		for(DTO_Lead dtoLead : dtoLeads)
		{
			newLead = new Lead();

			newLead.FirstName = dtoLead.firstName;
			newLead.LastName = dtoLead.lastName;
			newLead.MobilePhone = dtoLead.phone;
			newLead.Email = dtoLead.email;
			User adviser;

			if(String.isNotBlank(dtoLead.loggedInUserName))
			{
				adviser = AW_DAL_User.findCommunityUserOwner(dtoLead.loggedInUserName);
			}
			else
			{
				User currentUser = AW_DAL_User.getCurrentUser();
				if(currentUser.AccountId != null)
				{
					adviser = AW_DAL_User.findAdviserByAccountId(currentUser.AccountId);
				}
			}

			if(adviser != null)
			{
				newLead.OwnerId = adviser.Id;
			}

			newLeads.add(newLead);
		}

		CMN_DAL_SObjectDomain.insertDBObjects(newLeads);
	}

	/**
	 * @description Public class to delcare the invocable variable of Leads
	 */
	public class DTO_Lead
	{
		@InvocableVariable(Required=false Label = 'First Name')
		public String firstName;

		@InvocableVariable(Required=true Label = 'Last Name')
		public String lastName;

		@InvocableVariable(Required=false Label = 'Email')
		public String email;

		@InvocableVariable(Required=true Label = 'Mobile Phone')
		public String phone;

		@InvocableVariable(Required=false Label='Logged In User\'s username')
		public String loggedInUserName;
	}
}