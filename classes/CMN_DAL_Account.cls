/**
 * @description Provides Query methods related to Account object
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date Mar 2021, June 2022
 */
public inherited sharing class CMN_DAL_Account
{
	private static final String RT_BUSINESS_ACCOUNT = 'IndustriesBusiness';
	/**
	 * @description Api Name of the Object
	 */
	public static final String OBJECT_NAME = Account.SObjectType.getDescribe().getLocalName();

	/**
	 * @description The default fields to query from the Account Object
	 *
	 * @return A list of Account fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				Account.AccountNumber.getDescribe().getLocalName(),
				Account.AccountSource.getDescribe().getLocalName(),
				Account.AnnualRevenue.getDescribe().getLocalName(),
				Account.BillingCity.getDescribe().getLocalName(),
				Account.BillingCountry.getDescribe().getLocalName(),
				Account.BillingGeocodeAccuracy.getDescribe().getLocalName(),
				Account.BillingLatitude.getDescribe().getLocalName(),
				Account.BillingLongitude.getDescribe().getLocalName(),
				Account.BillingPostalCode.getDescribe().getLocalName(),
				Account.BillingState.getDescribe().getLocalName(),
				Account.BillingStreet.getDescribe().getLocalName(),
				Account.Description.getDescribe().getLocalName(),
				Account.Industry.getDescribe().getLocalName(),
				Account.IsDeleted.getDescribe().getLocalName(),
				Account.Name.getDescribe().getLocalName(),
				Account.NumberOfEmployees.getDescribe().getLocalName(),
				Account.OwnerId.getDescribe().getLocalName(),
				Account.Phone.getDescribe().getLocalName(),
				Account.ShippingCity.getDescribe().getLocalName(),
				Account.ShippingCountry.getDescribe().getLocalName(),
				Account.ShippingGeocodeAccuracy.getDescribe().getLocalName(),
				Account.ShippingLatitude.getDescribe().getLocalName(),
				Account.ShippingLongitude.getDescribe().getLocalName(),
				Account.ShippingPostalCode.getDescribe().getLocalName(),
				Account.ShippingState.getDescribe().getLocalName(),
				Account.ShippingStreet.getDescribe().getLocalName(),
				Account.Sic.getDescribe().getLocalName(),
				Account.SicDesc.getDescribe().getLocalName(),
				Account.Site.getDescribe().getLocalName(),
				Account.SystemModstamp.getDescribe().getLocalName(),
				Account.TickerSymbol.getDescribe().getLocalName(),
				Account.Type.getDescribe().getLocalName(),
				Account.Website.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method is return the Account Id
	 *
	 * @param accountId The id of the account to retrieve
	 *
	 * @return either Null or  account found
	 */
	public static Account findById(Id accountId)
	{
		return (Account)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountId, getDefaultFields());
	}

	/**
	 * @description Will query accounts by Ids
	 *
	 * @param accountIds The ids of the accounts to retrieve
	 *
	 * @return A list containing the found items
	 */
	public static List<Account> findById(Set<Id> accountIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountIds, getDefaultFields());
	}

	/**
	 * @description Method is return list of Account with cooridantes
	 *
	 * @return List of items found
	 */
	public static List<Account> findBusinessAccountsWithCoordinates()
	{
		return
		[
				SELECT
						Id,
						ShippingLatitude,
						ShippingLongitude
				FROM Account
				WHERE IsPersonAccount = FALSE
				AND ShippingLatitude != NULL
				LIMIT :CMN_DAL_Search.LIMIT_NUMBER_OF_RECORDS
		];
	}

	/**
	 * @description Method is return list of Account based on GEO location
	 *
	 * @param latitude The latitude of the account
	 * @param longitude The longitude of the account
	 *
	 * @return The account found
	 */
	public static Account getNearestAccountByShippingAddress(Decimal latitude, Decimal longitude)
	{
		List<Account> accounts =
		[
				SELECT
						Id,
						ShippingLatitude,
						ShippingLongitude,
						ShippingAddress
				FROM Account
				ORDER BY DISTANCE(ShippingAddress, GEOLOCATION(:latitude, :longitude), 'mi')
				LIMIT 1 //Only return the first item; which should be the closest
		];

		return accounts.isEmpty() ? null : accounts[0];
	}

	/**
	 * @description Finds all account who do not have account team members
	 *
	 * @return List of accounts found
	 */
	@SuppressWarnings('PMD.ApexCRUDViolation')
	@TestVisible
	private static List<Account> findAllWithoutTeamMembers()
	{
		return
		[
				SELECT
						Id,
						OwnerId
				FROM Account
				WHERE Id NOT IN
				(
						SELECT AccountId
						FROM AccountTeamMember
				)
				LIMIT :CMN_DAL_Search.LIMIT_NUMBER_OF_RECORDS
		];
	}

	/**
	 * @description Will return all Accounts created by unit tests
	 *
	 * @return A list of accounts
	 */
	@TestVisible
	private static List<Account> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description Method is use return the new Account with record type
	 *
	 * @return newAccount
	 */
	@TestVisible
	private static Account newItem()
	{
		Account newAccount = new Account();

		newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newAccount.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, RT_BUSINESS_ACCOUNT);

		return newAccount;
	}
}