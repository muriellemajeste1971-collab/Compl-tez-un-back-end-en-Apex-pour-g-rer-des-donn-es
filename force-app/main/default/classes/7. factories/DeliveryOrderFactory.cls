public with sharing class DeliveryOrderFactory {

    public static List<Livraison__c> assemble(List<Order> orders, Map<Id, Id> selectedTarifIds) {
        
        List<Livraison__c> newDeliveryOrders = new List<Livraison__c>();

        for (Order o : orders) {

            Id tarifId = selectedTarifIds.get(o.Id);

            Livraison__c newDeliveryOrder = new Livraison__c(
                Name = o.Livraison_Name__c,
                Order__c = o.Id,
                Account__c = o.AccountId,
                Tarification__c = tarifId,
                Statut__c = 'En cours'
            );

            newDeliveryOrders.add(newDeliveryOrder);
        }

        return newDeliveryOrders;
    }
}
