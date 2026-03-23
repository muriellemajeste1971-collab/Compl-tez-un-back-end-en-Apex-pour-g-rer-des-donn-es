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
    public static Map<Id, Id> updateByIds(List<Id> deliveryOrderIds, Map<Id, Id> newTarifIds) {

        // 1. Récupérer les anciennes livraisons
        List<Livraison__c> deliveryOrders = DeliveryOrderSelector.selectByIds(deliveryOrderIds);

        // 2. Construire la Map attendue par createByOrderIds : Map<OrderId, TarifId>
        Map<Id, Id> selectedTarifIds = new Map<Id, Id>();
        List<Id> orderIds = new List<Id>();

        for (Livraison__c oldDO : deliveryOrders) {

            // Le LWC envoie DeliveryOrderId → TarifId
            if (!newTarifIds.containsKey(oldDO.Id)) {
                throw new AuraHandledException(
                    'Aucun tarif sélectionné pour la livraison ' + oldDO.Id
                );
            }

            // Transformation en OrderId → TarifId
            selectedTarifIds.put(oldDO.Order__c, newTarifIds.get(oldDO.Id));

            orderIds.add(oldDO.Order__c);
        }

        // 3. Utiliser la méthode existante pour créer les nouvelles livraisons
        Map<Id, Id> newDeliveryOrderIdsByOrderId =
            DeliveryOrderService.createByOrderIds(orderIds, selectedTarifIds);

        // 4. Supprimer les anciennes livraisons
        delete deliveryOrders;

        // 5. Retourner la Map<OrderId, DeliveryOrderId>
        return newDeliveryOrderIdsByOrderId;
   
    }

}