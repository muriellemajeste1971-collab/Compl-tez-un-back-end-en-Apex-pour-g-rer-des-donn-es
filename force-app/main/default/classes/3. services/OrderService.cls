public with sharing class OrderService {

    public static void validateBeforeUpdate(Map<Id, Order> oldMap, Map<Id, Order> newMap) {
        
            // Validate parameters

            if (oldMap == null || oldMap.isEmpty()) {
                throw new OrderServiceException('Old Order not specified.');
            }

            if (newMap == null || newMap.isEmpty()) {
                throw new OrderServiceException('New Order not specified.');
            }

        // Convert the values (which return a List<Order>) explicitly to List<Order> for clarity
        List<Order> updatedOrders = new List<Order>(newMap.values());
            validateUpdate(updatedOrders);
    }

    public static void validateBeforeDelete(List<Order> oldList) {
        
        if (oldList == null || oldList.isEmpty()) {
            return;
        }

        validateDelete(oldList);
    }
    
    private static void validateUpdate(List<Order> orders) {

        // 1. collecter les Ids des commandes qui ont déclencher le trigger et les Ids du compte auxquel elles sont rattachés
        Set<Id> orderIds = new Set<Id>();
        List<Id> accountIds = new List<Id>();
        
        for (Order o : orders) {
                orderIds.add(o.Id);
                if (o.AccountId != null) {
                    accountIds.add(o.AccountId);
                }  
        }

       // 2. récupérer les données sur les comptes associés aux Ids des commandes qui ont déclencher le trigger
        List<Account> accounts = new List<Account>();
        accounts = AccountSelector.selectByIds(accountIds);
        Map<Id, Account> accountsById = new Map<Id, Account>(accounts);

        // 3. récupérer les données sur le nombre total de produits pour les commandes qui ont déclencher le trigger
        Map<Id, Decimal> qtyByOrder = new Map<Id, Decimal>();   
        qtyByOrder = OrderItemAggregator.TotalQuantityByOrder(orderIds);
   
        // 4. pour chaque commande qui a déclenché le trigger récupérer sur le compte le type de compte et le nombre total de produits
        // et appliquer les règles métiers minimum 3 produits pour un compte particulier et minimum 5 produits pour un compte professionnel
        
            for (Order o : orders) {

                Account account = accountsById.get(o.AccountId);
                Decimal totalOrderProducts = qtyByOrder.get(o.Id);

                Boolean isParticulier = false;
                Boolean isProfessionnel = false;

                if (account != null) {
                if (account.Customer_Type__c == 'Particulier') { isParticulier = true;}
                if (account.Customer_Type__c == 'Professionnel') {isProfessionnel = true;}
                }
        
                if (totalOrderProducts == null) { 
                    totalOrderProducts = 0;
                }

                if (totalOrderProducts < 3 && isParticulier && o.Status == 'Activated') {
                    o.addError('La commande doit contenir au moins 3 produits pour un compte particulier');
                    continue;
                }

                if (totalOrderProducts < 5 && isProfessionnel && o.Status == 'Activated') {
                    o.addError('La commande doit contenir au moins 5 produits pour un compte professionnel');
                }
            }
    }

    public static void validateDelete(List<Order> orders) {

        if (orders == null || orders.isEmpty()) {
            return;
        }

        // 1. collecter les Ids des commandes qui ont déclenché le trigger
        List<Id> orderIds = new List<Id>();
        List<Id> deliveryOrderOrderIds = new List<Id>();

            for (Order o : orders) {
                orderIds.add(o.Id);
            }

        // 2. récupérer la liste des delivery orders liées à tous les orders avant suppression
        List<Livraison__c> deliveryOrdersToBeDeleted = new List<Livraison__c>();
        deliveryOrdersToBeDeleted = DeliveryOrderSelector.selectByOrderIds(orderIds);
        
        // 3. stocker les Order__c des livraisons trouvées
            for (Livraison__c deliveryOrder : deliveryOrdersToBeDeleted) {
                if (deliveryOrder.Order__c != null) {
                        deliveryOrderOrderIds.add(deliveryOrder.Order__c);
                }
            }

        // 4. bloquer uniquement les orders qui ont une livraison liée
            for (Order o : orders) {
                if (deliveryOrderOrderIds.contains(o.Id)) {
                     o.addError('Impossible de supprimer une commande avec une livraison associée');
                }
        }
    }
}        
    
   