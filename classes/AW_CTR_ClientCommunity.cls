/**
 * @description Shared Controller Class - Used by Customer Community Lightning Components
 *
 * @see AW_TEST_CTR_ClientCommunity @story ST-1875,ST-1899,ST-1879,ST-2330
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_CTR_ClientCommunity
{
	/**
	 * @description Used to retrieve a list of FinServ__FinancialGoal__c records where the community user is the Primary Owner
	 *
	 * @return Returns a list of FinServ__FinancialGoal__c records linked to the community user
	 */
	@AuraEnabled(Cacheable=true)
	public static List<FinServ__FinancialGoal__c> getGoalList()
	{
		User currentUser = AW_DAL_User.getCurrentUser();
		return AW_DAL_FinancialGoal.findByPrimaryOwner(currentUser.AccountId);
	}

	/**
	 * @description Used to get the community user from Account
	 *
	 * @return Returns the current user from Account to login in community.
	 */
	@AuraEnabled
	public static Id fetchOutcome()
	{
		User currentUser = AW_DAL_User.getCurrentUser();
		return currentUser.AccountId;
	}

	/**
	 * @description Fetch the adviser related to the current community user
	 *
	 * @return the user account of the adviser; in the event this call is made by internal user then it returns currently logged in user
	 */
	@AuraEnabled
	public static User getCommunityUserInfo()
	{
		User currentUser = AW_DAL_User.getCurrentUser();

		if(currentUser.AccountId != null)
		{
			User adviser = AW_DAL_User.findAdviserByAccountId(currentUser.AccountId);

			if(adviser != null)
			{
				currentUser = adviser;
			}
		}

		return currentUser;
	}

	/**
	 * @description This method used to get the Account info to display in community
	 *
	 * @return
	 */
	@AuraEnabled
	public static Account getUserAccountInfo()
	{
		return new NoSharingProxy().getUserAccountInfo();
	}

	/**
	 * @description Used to retreive the community users account details
	 *
	 * @return Returns the community user's Account record
	 */
	@AuraEnabled(Cacheable=true)
	public static Account getClientAccountInfo()
	{
		User currentUser = AW_DAL_User.getCurrentUser();
		return AW_DAL_Account.findById(currentUser.AccountId);
	}

	/**
	 * @description Used to retreive a list of PersonLifeEvent records where the community user is the Primary Person
	 *
	 * @return Returns a list of PersonLifeEvent records linked to the community user
	 */
	@AuraEnabled(Cacheable=true)
	public static List<PersonLifeEvent> getPersonLifeEventList()
	{
		User currentUser = AW_DAL_User.getCurrentUser();
		return AW_DAL_PersonLifeEvent.findByPrimaryPerson(currentUser.ContactId);
	}

	/**
	 * @description Used to update a PersonLifeEvent from a LWC component
	 *
	 * @param request PersonLifeEvent information which need to be udpated
	 *
	 * @return Returns the Id of the updated PersonLifeEvent
	 */
	@AuraEnabled
	public static Id savePersonLifeEvent(String request)
	{
		DTO_PersonLifeEvent dtoPersonLifeEvent = (DTO_PersonLifeEvent)JSON.deserialize(request, DTO_PersonLifeEvent.class);

		PersonLifeEvent newPersonLifeEvent = new PersonLifeEvent();

		newPersonLifeEvent.Id = dtoPersonLifeEvent.personLifeEventId;
		newPersonLifeEvent.Name = dtoPersonLifeEvent.personLifeEventName;
		newPersonLifeEvent.EventDescription = dtoPersonLifeEvent.personLifeEventDescription;
		newPersonLifeEvent.EventDate = dtoPersonLifeEvent.personLifeEventDate;
		newPersonLifeEvent.AW_Impact__c = dtoPersonLifeEvent.personLifeEventImpact;
		newPersonLifeEvent.AW_ImpactOnOutcomeGoals__c = dtoPersonLifeEvent.personLifeEventImpactDes;
		newPersonLifeEvent.AW_PriorityLevel__c = dtoPersonLifeEvent.personLifeEventPriority;

		update newPersonLifeEvent;

		return newPersonLifeEvent.Id;
	}

	/**
	 * @description Used to delete an item which potentially the community user doesn't have permissions to delete as it's owned by adviser
	 * Method will bypass sharing and delete the object (if and only  if) the object is owner by community user or it was created by community user
	 *
	 * @param itemId The object to be deleted
	 */
	@AuraEnabled
	public static void deleteGoal(Id itemId)
	{
		new NoSharingProxy().deleteItem(AW_DAL_FinancialGoal.OBJECT_NAME, itemId);
	}

	/**
	 * @description Use this to store an image against an object in Salesforce files, this can then be used to render to client when necessary
	 *
	 * @param objectId The Id of the object against which to store the image
	 * @param fileName The name of the image file
	 * @param imageData The Image blob data
	 */
	@AuraEnabled
	public static void saveObjectImage(Id objectId, String fileName, String imageData)
	{
		User currentUser = AW_DAL_User.getCurrentUser();

		imageData = EncodingUtil.urlDecode(imageData, CMN_API_HttpBase.UTF8_ENCODING_SCHEME);

		Id networkId;

		if(currentUser.ContactId != null)
		{
			Network community = CMN_DAL_Community.findByName(AW_DAL_Community.CLIENT_PORTAL_NAME);
			networkId = community.Id;
		}

		CMN_DAL_ContentVersion.insertNewObjectImageVersion(objectId, fileName, '/' + fileName, EncodingUtil.base64Decode(imageData), networkId);
	}

	/**
	 * @description Will return the ContentId of the image stored against the objectId provided
	 *
	 * @param objectId The Id of the object against which the image is stored
	 *
	 * @return The contentId of the image which can then be used to compose an URL to retrieve the image
	 */
	@AuraEnabled(Cacheable=true)
	public static ContentVersion getObjectImage(Id objectId)
	{
		return CMN_DAL_ContentVersion.findLatestImageVersionByTitle(objectId);
	}

	/**
	 * @description Use this class when you want to run controller methods and bypass sharing
	 */
	private without sharing class NoSharingProxy
	{

		/**
		 * @description Method to check delete items from Object
		 *
		 * @param objectName
		 * @param itemId
		 */
		public void deleteItem(String objectName, Id itemId)
		{
			//Now check to see if we can delete the object
			SObject item = CMN_DAL_SObjectSelector.findById(objectName, itemId, new Set<String> {CMN_DAL_SObjectDomain.FIELD_OWNER_ID, CMN_DAL_SObjectDomain.FIELD_CREATED_BY_ID});

			Id currentUserId = UserInfo.getUserId();

			Id OwnerId = (Id)item.get(CMN_DAL_SObjectDomain.FIELD_OWNER_ID);
			Id createdById = (Id)item.get(CMN_DAL_SObjectDomain.FIELD_CREATED_BY_ID);

			if(new Set<Id> {OwnerId, createdById}.contains(currentUserId))
			{
				CMN_DAL_SObjectDomain.deleteDBObject(item);
			}
			else
			{
				throw new CMN_UTIL_System.AssertionException('Current user does not have permission to delete the object');
			}
		}

		/**
		 * @description Method use to get the Account asociated with user
		 *
		 * @return Return the Account details in community page
		 */

		public Account getUserAccountInfo()
		{
			Account communityAccount = new Account();

			User currentUser = AW_DAL_User.getCurrentUser();

			if(currentUser.AccountId != null)
			{
				communityAccount = AW_DAL_Account.findById(currentUser.AccountId);

				if(communityAccount != null)
				{
					AccountTeamMember teamMember = AW_DAL_AccountTeamMember.findByAdviserRoleAndUserId(communityAccount.OwnerId);

					if(teamMember != null)
					{
						communityAccount = AW_DAL_Account.findById(teamMember.AccountId);
					}
				}
			}

			return communityAccount;
		}
	}

	/**
	 * @description Method use to return the current user
	 *
	 * @return
	 */
	@AuraEnabled
	public static User getCurrentUser()
	{
		return AW_DAL_User.getCurrentUser();
	}

	/**
	 * @description Wrapper class is use to store the person Life Event values from communities
	 */
	public class DTO_PersonLifeEvent
	{
		public String personLifeEventId;
		public String personLifeEventName;
		public String personLifeEventDescription;
		public String personLifeEventImpact;
		public String personLifeEventImpactDes;
		public String personLifeEventPriority;
		public Datetime personLifeEventDate;
	}
}