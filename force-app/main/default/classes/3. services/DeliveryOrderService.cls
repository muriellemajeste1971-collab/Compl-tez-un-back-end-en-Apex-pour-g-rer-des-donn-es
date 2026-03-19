public with sharing class DeliveryOrderService {
    // ---------------------------------------------------------
    // 1. CREER une Livraison pour un Order
    // ---------------------------------------------------------
    @AuraEnabled
    public static Map<Id, Id> createDeliveryOrdersByOrderIds(List<Id> orderIds, Map<Id, Id> selectedTarifIds) {

        // 1. Déclaration explicite de la liste d'Orders
        List<Order> orders = new List<Order>();
        orders = OrderSelector.getOrdersByIds(orderIds);

        // 2. Déclaration explicite de la liste de Livraisons à insérer
        List<Livraison__c> newDeliverOrders = new List<Livraison__c>();

        // 3. Construction explicite des objets Livraison pour chaque Order 
        for (Order o : orders) {

            Id tarifId = selectedTarifIds.get(o.Id);

            Livraison__c newDeliveryOrder = new Livraison__c(
                Name = o.Livraison_Name__c,
                Order__c = o.Id,
                Account__c = o.AccountId,
                Tarification__c = tarifId,
                Statut__c = 'En cours'
            );

            newDeliverOrders.add(newDeliveryOrder);
        }

        // 4. Insert bulk explicite
        insert newDeliverOrders;

        // 5. Retour explicite : Map<OrderId, LivraisonId>
        Map<Id, Id> result = new Map<Id, Id>();

        for (Livraison__c newDO : newDeliverOrders) {
            result.put(newDO.Order__c, newDO.Id);
            }

        return result;
    }


    // ---------------------------------------------------------
    // 2. RECUPERER la Livraison liée à un Order
    // ---------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Map<Id, List<Livraison__c>> getDeliveryOrderByOrderIds(Set<Id> orderIds) {
       
        //1. Récupérer les Delivery Orders par les Orders Ids
         List<Livraison__c> deliveryOrders = new List<Livraison__c>();
        deliveryOrders = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(orderIds);

        // 2. Construction explicite de la Map<OrderId, List<Livraison>>
        Map<Id, List<Livraison__c>> result = new Map<Id, List<Livraison__c>>();
    
            for (Livraison__c deliveryOrder : deliveryOrders) {
                if (!result.containsKey(deliveryOrder.Order__c)) {
                    result.put(deliveryO.Order__c, new List<Livraison__c>());
                }
                    result.get(deliverryO.Order__c).add(deliveryOrder);
            }

            return result;
        }

    // 3. Mettre à jour le Delivery Order lié à un Order
    @AuraEnabled
    public static Set<Id> updateDeliveryOrders(Set<Id> deliveryOrderIds, Map<Id, Id> newTarifIds) {

        // 1. Récupérer les livraisons à mettre à jour
        List<Livraison__c> deliveryOrders = DeliveryOrderSelector.getDeliveryOrdersByIds(deliveryOrderIds);

        // 2. Créer une liste pour collecter les livraisons à mettre à jour
        List<Livraison__c> deliveryOrdersToUpdate = new List<Livraison__c>();

            for (Livraison__c deliveryOrder : deliveryOrders) {
                if (newTarifIds.containsKey(deliveryOrder.Id)) {
                    deliveryOrder.Tarification__c = newTarifIds.get(deliveryOrder.Id);
                    deliveryOrdersToUpdate.add(deliveryOrder);
                }
            }

        // 3. Bulk DML - Update Outside of the loop 
        update deliveryOrdersToUpdate;

        // 4. Retourner les Id mis à jour
        return deliveryOrderIds;
    }

    // ---------------------------------------------------------
    // 4. SUPPRIMER la Livraison liée à un Order (bouton UI)
    // ---------------------------------------------------------
    @AuraEnabled
    public static void deleteDeliveryOrders(Set<Id> orderIds) {

        //1. Récupérer les Delivery Orders par les Orders Ids
        List<Livraison__c> deliveryOrdersToBeDeleted = new List<Livraison__c>();
            deliveryOrdersToBeDeleted = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(orderIds);

        // 2. Bulk DML - Delete : Supprimer les Delivery Orders de la liste deliveryOrdersToBeDeleted 
        delete deliveryOrdersToBeDeleted;
    }

}