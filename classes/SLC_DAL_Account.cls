/**
 * @description Public class to return the records of Accounts
 *
 * @author Futureform
 *
 * @date January 2023
 */
public with sharing class SLC_DAL_Account {

    public static final String FIELD_PHONE_NUMBER = Account.Phone.getDescribe().getLocalName();
    public static final String OBJECT_NAME = Account.SObjectType.getDescribe().getLocalName();
    public static final String RT_BUSINESS_ACCOUNT = 'IndustriesBusiness';

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
                Account.Id.getDescribe().getLocalName(),
                Account.Industry.getDescribe().getLocalName(),
                Account.IsDeleted.getDescribe().getLocalName(),
                Account.IsPersonAccount.getDescribe().getLocalName(),
                Account.Name.getDescribe().getLocalName(),
                Account.NumberOfEmployees.getDescribe().getLocalName(),
                Account.OwnerId.getDescribe().getLocalName(),
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
                Account.Website.getDescribe().getLocalName(),
                Account.SLC_IDNumber__c.getDescribe().getLocalName(),
                FIELD_PHONE_NUMBER
        };
    }

    public static final String ACCOUNT_ID = FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c.getDescribe().getLocalName();

    public static List<FinServ__FinancialAccount__c> findChildFinancialAccounts(Id accountId, Boolean isExternal) {
        if (isExternal) {
            return [
                    SELECT Id, Name, FinServ__PrimaryOwner__c, FinServ__FinancialAccountNumber__c
                    FROM FinServ__FinancialAccount__c
                    WHERE FinServ__PrimaryOwner__c IN (
                            SELECT AccountId
                            FROM AccountContactRelation
                            WHERE Contact.AccountId = :accountId
                            OR AccountId = :accountId
                    )
            ];
        } else {
            return [
                    SELECT
                            Id, Name, FinServ__PrimaryOwner__c, FinServ__FinancialAccountNumber__c
                    FROM FinServ__FinancialAccount__c
                    WHERE FinServ__PrimaryOwner__c = :accountId
            ];
        }
    }

    public static Account findById(Id accountId){
        return (Account)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountId, getDefaultFields());
    }
    
    public static List<Account> findACRAccounts(Id accountId){
        List<AccountContactRelation> acrAccounts = [SELECT Id, AccountId, Account.Name FROM AccountContactRelation WHERE Contact.AccountId =: accountId]; 
        
        Set<Id> accIds = new Set<Id>();
        for(AccountContactRelation acr : acrAccounts){
            accIds.add(acr.AccountId);
        }
        
        List<Account> relatedAccounts = [SELECT Id, Name, AccountNumber, IsPersonAccount, SLC_IDNumber__c FROM Account WHERE Id IN : accIds];

        return relatedAccounts;
    }
}