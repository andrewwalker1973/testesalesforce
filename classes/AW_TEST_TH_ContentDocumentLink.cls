/**
 * @description Test class to test content document
 *
 * @see AW_TH_ContentVersion
 * @see AW_TH_ContentDocumentLink
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date 2019, June 2022
 */
@IsTest(SeeAllData=false IsParallel=false)
private class AW_TEST_TH_ContentDocumentLink
{
    private static final Integer NUM_ITEMS_TO_CREATE = 10;

    /**
     * @description Method to setup the test data
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
     * @description Method to get the created Accounts using in test method
     *
     * @return Account
     */
    private static Account findCreatedAccount()
    {
        List<Account> newAccounts = AW_DAL_Account.getAll();

        System.assertEquals(1, newAccounts.size(), 'Community  Account not created.');

        return newAccounts.iterator().next();
    }

    /**
     * @description Method to get the Community user
     *
     * @return Community user
     */
    private static User findCommunityUser()
    {
        Account createdAccount = findCreatedAccount();
        return AW_DAL_User.findCommunityUser(createdAccount.Id);
    }

    /**
     * @description Checks that a document uploaded by a community user is linked to the community user's account so that's accessible by internal users
     * @deprecated This method got failed when we have deactivated the Client Portal
    @IsTest
    private static void linkDocumentToClientAccount()
    {
        User communityUser = findCommunityUser();

        System.runAs(communityUser)
        {
            Test.startTest();

            AW_DAL_TestDataFactory.createContentVersions(communityUser.Id, NUM_ITEMS_TO_CREATE);

            communityUser = AW_DAL_User.getCurrentUser();

            Test.stopTest();
        }

        //Now check to see if a link has been created to the community user's account.
        List<ContentDocumentLink> links = CMN_DAL_ContentDocumentLink.findByLinkedEntitiesIds(new Set<Id> {communityUser.AccountId});

        System.assertEquals(NUM_ITEMS_TO_CREATE, links.size(), 'No Links to Community Account');
    }
    */

    /**
     * @description Will check that a document uploaded by an adviser is linked to a community user so that can access it on the portal
     * @deprecated This method got failed when we have deactivated the Client Portal
    @IsTest
    private static void shareDocumentWithClient()
    {
        User communityUser = findCommunityUser();

        User adviser = AW_DAL_User.findById(findCreatedAccount().OwnerId);

        Test.startTest();

        //Insert document against account, as an adviser
        System.runAs(adviser)
        {
            AW_DAL_TestDataFactory.createContentVersions(communityUser.AccountId, NUM_ITEMS_TO_CREATE);
        }

        Test.stopTest();

        //Now check to see if a link has been created to the community user's record.
        List<ContentDocumentLink> links = CMN_DAL_ContentDocumentLink.findByLinkedEntitiesIds(new Set<Id> {communityUser.Id});

        System.assertEquals(NUM_ITEMS_TO_CREATE, links.size(), 'No Links to Community User');
    }
    */
}