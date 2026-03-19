public with sharing class OrderSelector {

    public static List<Order> getOrdersByAccountIds(List<Id> accountIds) {
        return [
            SELECT Id, Account_Type__c, AccountId, ContractId, Livraison_Name__c, Pays__c, Product_Number__c, ShippingCountry, Status
            FROM Order
            WHERE AccountId IN :accountIds
        ];
    }
}