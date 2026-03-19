public with sharing class OrderService {

    public static void validateOrderBeforeInsert(List<Order> newList) { 

        if (newList == null || newList.isEmpty()) {
            return;
        }

        validateOrder(newList);
    }

    public static void validateOrderBeforeUpdate(Map<Id, Order> oldMap, Map<Id, Order> newMap) {
        
        if (newMap == null || newMap.isEmpty()) {
            return;
        }

        // Convert the values (which return a List<Order>) explicitly to List<Order> for clarity
        List<Order> updatedOrders = new List<Order>(newMap.values());
        validateOrder(updatedOrders);
    }

    public static void validateOrderBeforeDelete(List<Order> oldList) {
        
        if (oldList == null || oldList.isEmpty()) {
            return;
        }

        validateOrderDelete(oldList);
    }
    
    private static void validateOrder(List<Order> orders) {

        // 1. collecter les Ids des commandes qui ont déclencher le trigger et les Ids du compte auxquel elles sont rattachés
        Set<Id> orderIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for (Order o : orders) {
                orderIds.add(o.Id);
                if (o.AccountId != null) {
                    accountIds.add(o.AccountId);
                }  
        }

       // 2. récupérer les données sur les comptes associés aux Ids des commandes qui ont déclencher le trigger
        List<Account> accounts = new List<Account>();
        accounts = AccountSelector.getAccountsByIds(accountIds);
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

    public static void validateOrderDelete(List<Order> orders) {

        if (orders == null || orders.isEmpty()) {
            return;
        }
    
        // 1. collecter les Ids des commandes qui ont déclencher le trigger et les Ids des livraisons qui leurs sont liées 
        Set<Id> orderIds = new Set<Id>();
        Set<Id> deliveryOrderOrderIds = new Set<Id>();
        
        for (Order o : orders) { 

            orderIds.add(o.Id);
        }


        // 2. récupérer la liste des delivery orders liées à tous les orders avant suppression
        List<Livraison__c> livs = new List<Livraison__c>();
        livs = LivraisonSelector.getByOrders(orderIds);

        for (Livraison__c liv : livs) {

            if (liv.Order__c != null) {
                deliveryOrderOrderIds.add(liv.Order__c);
            }
        }
    
        
        for (Order o : orders) {
            
            if (deliveryOrderOrderIds.contains(o.Id)) {
                o.addError('Impossible de supprimer une commande avec une livraison associée');
            }
        }
    }   
}        
    
   