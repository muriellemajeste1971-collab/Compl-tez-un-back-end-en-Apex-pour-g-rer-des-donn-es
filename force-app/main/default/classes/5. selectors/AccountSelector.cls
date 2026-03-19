public with sharing class AccountSelector {

    public static List<Account> getAccountsByIds(List<Id> accountIds) {
        return [
                SELECT Id, Name, Type, Customer_Type__c, ShippingCountry
                FROM Account
                WHERE Id IN :accountIds
        ];
    }
}