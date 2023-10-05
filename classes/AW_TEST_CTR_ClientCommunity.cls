/**
 * @description Test class for AW_CTR_ClientCommunity
 *
 * @see AW_CTR_ClientCommunity
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_CTR_ClientCommunity
{
    private static final Integer NUMBER_OF_GOALS_TO_CREATE = 5;
    private static final Integer NUMBER_OF_MOMENTS_TO_CREATE = 5;

    /**
     * @description Setup the test data
     */
    @TestSetup
    private static void insertTestData()
    {
        User adviser = AW_DAL_User.findRandomActiveAdviser();

        //Ensure that we create community account and user and community account owned by an adviser
        System.runAs(adviser)
        {
            AW_DAL_TestDataFactory.createCommunityUser();
        }
    }

    /**
     * @description To check the new Account
     *
     * @return List of Account
     */
    private static Account findCreatedAccount()
    {
        List<Account> newAccounts = AW_DAL_Account.getAll();

        System.assertEquals(1, newAccounts.size(), 'Community  Account not created.');

        return newAccounts[0];
    }

    /**
     * @description To check the Community User with Account Id
     *
     * @return Community User
     */
    private static User findCommunityUser()
    {
        Account createdAccount = findCreatedAccount();
        return AW_DAL_User.findCommunityUser(createdAccount.Id);
    }

    /**
     * @description Test method to test the Community user
     * @deprecated This method got failed when we have deactivated the Client Portal 
    @IsTest
    private static void getCommunityUserInfo()
    {
        Account createdAccount = findCreatedAccount();
        User communityUser = AW_DAL_User.findCommunityUser(createdAccount.Id);

        User foundUser;

        System.runAs(communityUser)
        {
            Test.startTest();

            foundUser = AW_CTR_ClientCommunity.getCommunityUserInfo();

            Test.stopTest();
        }

        System.assertNotEquals(createdAccount.Id, foundUser.AccountId);
    }
    */

    /**
     * @description Test method to test the Community user
     */
    @IsTest
    private static void fetchOutcome()
    {
        User communityUser = findCommunityUser();

        Id accountId;

        System.runAs(communityUser)
        {
            Test.startTest();

            accountId = AW_CTR_ClientCommunity.fetchOutcome();

            Test.stopTest();
        }

        System.assertEquals(accountId, communityUser.AccountId);
    }

    /**
     * @description Test method to create a user and test the User Account
     */
    @IsTest
    private static void getUserAccountInfo()
    {
        Account createdAccount = findCreatedAccount();
        User communityUser = AW_DAL_User.findCommunityUser(createdAccount.Id);
        List<User> adviserUsers = AW_DAL_User.findById(new Set<Id> {createdAccount.OwnerId});

        System.runAs(AW_DAL_User.findActiveAdministrator())
        {
            AW_DAL_TestDataFactory.createAccountTeamMembers(createdAccount, adviserUsers, AW_DAL_AccountTeamMember.ROLE_ADVISER);
        }

        Account foundCommunityAccount;

        System.runAs(communityUser)
        {
            Test.startTest();

            foundCommunityAccount = AW_CTR_ClientCommunity.getUserAccountInfo();

            Test.stopTest();
        }

        System.assertEquals(createdAccount.Id, foundCommunityAccount.Id);
    }

    /**
     * @description Test method to setup a person life event data and test the User Account
     */
    @IsTest
    private static void getPersonLifeEventList()
    {
        User communityUser = findCommunityUser();

        List <PersonLifeEvent> personLifeEventList = new List <PersonLifeEvent>();
        personLifeEventList = AW_DAL_TestDataFactory.createPersonLifeEvents(communityUser.ContactId, NUMBER_OF_MOMENTS_TO_CREATE, true);
        List <PersonLifeEvent> personLifeEventCtrList = new List <PersonLifeEvent>();

        System.runAs(communityUser)
        {
            Test.startTest();

            personLifeEventCtrList = AW_CTR_ClientCommunity.getPersonLifeEventList();

            Test.stopTest();
        }

        System.assertEquals(personLifeEventCtrList.size(), personLifeEventList.size(), 'Invalid number of person life events returned.');
    }

    /**
     * @description Test method to setup a goal and test the community User goal
     */
    @IsTest
    private static void getGoals()
    {
        User communityUser = findCommunityUser();

        List <FinServ__FinancialGoal__c> goalList = new List <FinServ__FinancialGoal__c>();

        goalList = AW_DAL_TestDataFactory.createGoals(communityUser.AccountId, NUMBER_OF_GOALS_TO_CREATE);

        List <FinServ__FinancialGoal__c> goalCtrList = new List <FinServ__FinancialGoal__c>();

        System.runAs(communityUser)
        {
            Test.startTest();

            goalCtrList = AW_CTR_ClientCommunity.getGoalList();

            Test.stopTest();
        }

        System.assertEquals(goalCtrList.size(), goalList.size(), 'Invalid number of goals returned.');
    }

    /**
     * @description Test method to test the client
     */
    @IsTest
    private static void getClientAccountInfo()
    {
        User communityUser = findCommunityUser();

        Account clientAccount;

        System.runAs(communityUser)
        {
            Test.startTest();

            clientAccount = AW_CTR_ClientCommunity.getClientAccountInfo();

            Test.stopTest();
        }

        System.assertNotEquals(null, clientAccount, 'No account returned.');
    }

    /**
     * @description Test method to test the person life event
     */
    @IsTest
    private static void savePersonLifeEvent()
    {
        User communityUser = findCommunityUser();

        List <PersonLifeEvent> personLifeEvent = new List <PersonLifeEvent>();

        personLifeEvent = AW_DAL_TestDataFactory.createPersonLifeEvents(communityUser.ContactId, NUMBER_OF_MOMENTS_TO_CREATE, true);

        AW_CTR_ClientCommunity.DTO_PersonLifeEvent dtoPersonLifeEvent = new AW_CTR_ClientCommunity.DTO_PersonLifeEvent();

        dtoPersonLifeEvent.personLifeEventId = personLifeEvent[0].Id;
        dtoPersonLifeEvent.personLifeEventName = CMN_DAL_SObjectDomain.generateRandomName();
        dtoPersonLifeEvent.personLifeEventDate = CMN_DAL_SObjectDomain.generateRandomDate();

        String request = JSON.serialize(dtoPersonLifeEvent);
        Id personLifeEventId = null;

        System.runAs(communityUser)
        {
            Test.startTest();

            personLifeEventId = AW_CTR_ClientCommunity.savePersonLifeEvent(request);

            Test.stopTest();
        }

        System.assertNotEquals(null, personLifeEventId, 'Person Life Event was not updated');

    }

    @IsTest
    private static void checkGoalOwnerIsCorrect()
    {
        Account createdAccount = findCreatedAccount();
        User communityUser = AW_DAL_User.findCommunityUser(createdAccount.Id);

        List<User> adviserUsers = AW_DAL_User.findById(new Set<Id> {createdAccount.OwnerId});

        User adviserUser = adviserUsers[0];

        List <FinServ__FinancialGoal__c> goalList = new List <FinServ__FinancialGoal__c>();

        System.runAs(communityUser)
        {
            goalList = AW_DAL_TestDataFactory.createGoals(createdAccount.Id, NUMBER_OF_GOALS_TO_CREATE);

            Test.startTest();

            goalList = AW_CTR_ClientCommunity.getGoalList();

            Test.stopTest();

            System.assertNotEquals(true, goalList.isEmpty(), 'No Goals returned');

            System.assertEquals(adviserUser.Id, goalList[0].OwnerId);
        }
    }

    @IsTest
    private static void deleteGoal()
    {
        User communityUser = findCommunityUser();

        System.runAs(communityUser)
        {
            Test.startTest();

            List <FinServ__FinancialGoal__c> goalList = new List <FinServ__FinancialGoal__c>();

            goalList = AW_DAL_TestDataFactory.createGoals(communityUser.AccountId, NUMBER_OF_GOALS_TO_CREATE);

            AW_CTR_ClientCommunity.deleteGoal(goalList[0].Id);

            Test.stopTest();

            List <FinServ__FinancialGoal__c> foundGoalList = AW_CTR_ClientCommunity.getGoalList();

            System.assertEquals(goalList.size() - 1, foundGoalList.size(), 'Goal was not deleted.');
        }
    }

    @IsTest
    private static void saveObjectImage()
    {
        User communityUser = findCommunityUser();

        List <FinServ__FinancialGoal__c> goalList = new List <FinServ__FinancialGoal__c>();

        goalList = AW_DAL_TestDataFactory.createGoals(communityUser.AccountId, NUMBER_OF_GOALS_TO_CREATE);

        System.runAs(communityUser)
        {
            Test.startTest();

            String fileName = CMN_DAL_SObjectDomain.generateRandomName();
            String fileData = EncodingUtil.urlEncode(fileName, CMN_API_HttpBase.UTF8_ENCODING_SCHEME);
            try
            {
                AW_CTR_ClientCommunity.saveObjectImage(goalList[0].Id, fileName, fileData);
                ContentVersion savedVersion = AW_CTR_ClientCommunity.getObjectImage(goalList[0].Id);

                System.assertNotEquals(null, savedVersion, 'Object Image was not retrieved');
            }
            catch(Exception error)
            {
                System.assert(false, 'An unexpected error was thrown');
            }

            Test.stopTest();
        }
    }

    @IsTest
    private static void deleteGoalWithoutPermissions()
    {
        User communityUser = findCommunityUser();

        List <FinServ__FinancialGoal__c> goalList = new List <FinServ__FinancialGoal__c>();

        goalList = AW_DAL_TestDataFactory.createGoals(communityUser.AccountId, NUMBER_OF_GOALS_TO_CREATE);

        System.runAs(communityUser)
        {
            Test.startTest();

            try
            {
                AW_CTR_ClientCommunity.deleteGoal(goalList[0].Id);
                System.assert(false, 'Exception was not raised, user does not have permission to delete Goal');
            }
            catch(CMN_UTIL_System.AssertionException error)
            {
                System.assert(true);
            }

            Test.stopTest();
        }
    }

    @IsTest
    private static void getCurrentUser()
    {
        User communityUser = findCommunityUser();

        System.runAs(communityUser)
        {
            Test.startTest();

            User foundUser = AW_CTR_ClientCommunity.getCurrentUser();

            Test.stopTest();

            System.assertEquals(communityUser.Id, foundUser.Id, 'Incorrect user found');
        }
    }

}