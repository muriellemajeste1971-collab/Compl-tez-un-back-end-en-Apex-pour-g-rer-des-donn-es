public with sharing class DeliveryOrderService {
    // ---------------------------------------------------------
    // 1. CREER une Livraison pour un Order
    // ---------------------------------------------------------
    @AuraEnabled
    public static Map<Id, Id> createDeliveryOrdersByOrderIds(List<Id> orderIds, Map<Id, Id> selectedTarifIds) {

        // 1. Déclaration explicite de la liste d'Orders

        List<Order> orders = new List<Order>();
        orders = OrderSelector.getOrdersByOrderIds(orderIds);

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
    public static Map<Id, List<Livraison__c>> getDeliveryOrderByOrderIds(List<Id> orderIds) {
       
        //1. Récupérer les Delivery Orders par les Orders Ids
         List<Livraison__c> deliveryOrders = new List<Livraison__c>();
        deliveryOrders = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(orderIds);

        // 2. Construction explicite de la Map<OrderId, List<Livraison>>
        Map<Id, List<Livraison__c>> result = new Map<Id, List<Livraison__c>>();
    
            for (Livraison__c deliveryOrder : deliveryOrders) {
                if (!result.containsKey(deliveryOrder.Order__c)) {
                    result.put(deliveryOrder.Order__c, new List<Livraison__c>());
                }
                    result.get(deliveryOrder.Order__c).add(deliveryOrder);
            }

            return result;
        }

    // 3. Mettre à jour le Delivery Order lié à un Order
    @AuraEnabled
    public static List<Id> updateDeliveryOrders(List<Id> deliveryOrderIds, Map<Id, Id> newTarifIds) {

        // 1. récupérer les livraisons existantes
        List<Livraison__c> oldDeliveryOrders = DeliveryOrderSelector.getDeliveryOrdersByIds(deliveryOrderIds);

        // 2. préparer suppression + création
        List<Livraison__c> toDelete = new List<Livraison__c>();
        List<Livraison__c> toInsert = new List<Livraison__c>();

            for (Livraison__c oldDO : oldDeliveryOrders) {

                if (newTarifIds.containsKey(oldDO.Id)) {

                    // ✔️ suppression
                    toDelete.add(oldDO);

                    // ✔️ recréation avec nouvelle tarification
                    Livraison__c newDO = new Livraison__c(
                        Name = oldDO.Name,
                        Order__c = oldDO.Order__c,
                        Account__c = oldDO.Account__c,
                        Tarification__c = newTarifIds.get(oldDO.Id),
                        Statut__c = oldDO.Statut__c
                    );

                    toInsert.add(newDO);
                }
            }

            // 3. DML bulk
            delete toDelete;
            insert toInsert;

        // 4. retour des nouveaux Ids
        List<Id> newIds = new List<Id>();
            for (Livraison__c l : toInsert) {
                newIds.add(l.Id);
            }

            return newIds;
    }
    


}