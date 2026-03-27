public class DeliveryOrderSelector {

    public static List<Livraison__c> selectByOrderIds(List<Id> orderIds) {
        return [
            SELECT Id, Account__c, Account_Type__c, Name, Order__c, Product_Number__c, Statut__c, Tarification__c
            FROM Livraison__c
            WHERE Order__c IN :orderIds
        ];
    }

    public static List<Livraison__c> selectByIds(List<Id> deliveryOrderIds) {
        return [
            SELECT Id, Account__c, Account_Type__c, Name, Order__c, Product_Number__c, Statut__c, Tarification__c
            FROM Livraison__c
            WHERE Id IN :deliveryOrderIds
        ];
    }   
}