public with sharing class OrderSelector {

    public static List<Order> getOrdersByOrderIds(List<Id> orderIds) {
        
        return [
            SELECT Id, Account_Type__c, AccountId, ContractId, Livraison_Name__c, Pays__c, Product_Number__c, ShippingCountry, Status
            FROM Order
            WHERE Id IN :orderIds
        ];
    }
}