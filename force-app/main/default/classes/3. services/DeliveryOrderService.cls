public with sharing class DeliveryOrderService {

    // 1. Créer un DeliveryOrder (Livraison) pour un Order ()
    @AuraEnabled
    public static Map<Id, Id> createByOrderIds(List<Id> orderIds, Map<Id, Id> selectedTarifIds) {

        // Validate parameters
        if (orderIds == null || orderIds.isEmpty()) {
            throw new DeliveryOrderServiceException('Delivery Order not specified.');
        }
        if (selectedTarifIds == null || selectedTarifIds.isEmpty()) {
            throw new DeliveryOrderServiceException('Selected Tarif not specified.');
        }

        // 1. Déclaration explicite de la liste d'Orders
        List<Order> orders = new List<Order>();
        orders = OrderSelector.selectByIds(orderIds);

        // 2. Déclaration explicite de la liste de Livraisons à insérer
        List<Livraison__c> newDeliveryOrders = DeliveryOrderFactory.assemble(orders, selectedTarifIds);
        
        // 4. Insert bulk explicit outside the loop
        insert newDeliveryOrders;

        // 5. Retour explicite : Map<OrderId, LivraisonId>
        Map<Id, Id> result = new Map<Id, Id>();

        for (Livraison__c newDO : newDeliveryOrders) {
            result.put(newDO.Order__c, newDO.Id);
            }

        return result;
    }


    
    // 2. RECUPERER la Livraison liée à un Order
    @AuraEnabled(cacheable=true)
    public static Map<Id, List<Livraison__c>> getByOrderIds(List<Id> orderIds) {
       
        //1. Récupérer les Delivery Orders par les Orders Ids
         List<Livraison__c> deliveryOrders = new List<Livraison__c>();
        deliveryOrders = DeliveryOrderSelector.selectByOrderIds(orderIds);

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
    public static List<Id> updateByIds(List<Id> deliveryOrderIds, Map<Id, Id> newTarifIds) {

        // 1. récupérer les livraisons existantes
        List<Livraison__c> oldDeliveryOrders = DeliveryOrderSelector.selectByIds(deliveryOrderIds);

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