public with sharing class OrderTarifService {

    /*
     * ============================================================
     *  MÉTHODE SINGLE (pour le LWC)
     *  Appelle simplement la version bulk avec un seul Id
     * ============================================================
     */
    @AuraEnabled(cacheable=true)
    public static List<Tarification__c> getOrderTarifs(Id orderId) {

        // 1. Déclaration du Set d'Ids
        Set<Id> orderIds = new Set<Id>();

        // 2. Assignation
        orderIds.add(orderId);

        // 3. Appel de la méthode bulk
        Map<Id, List<Tarification__c>> resultMap = tarifs(orderIds);

        // 4. Retour du résultat pour cet OrderId
        return resultMap.get(orderId);
    }



    /*
     * ============================================================
     *  MÉTHODE BULK (la vraie logique métier)
     *  Multi-user, multi-transaction, SOC, réutilisable partout
     * ============================================================
     */
    public static Map<Id, List<Tarification__c>> getOrderTarifs(Set<Id> orderIds) {

        // 1. Déclaration du Map des Orders
        Map<Id, Order> orders = new Map<Id, Order>();

        // 2. Assignation via SOQL bulk
        orders = new Map<Id, Order>(
            [
                SELECT  Id,
                        Pays__c,
                        Account_Type__c
                FROM Order
                WHERE Id IN :orderIds
            ]
        );

        // 3. Déclaration des Maps pour les attributs
        Map<Id, String> mapPays = new Map<Id, String>();
        Map<Id, String> mapTypeClient = new Map<Id, String>();

        // 4. Assignation des valeurs dans les Maps
        for (Order ord : orders.values()) {

            // Pays
            mapPays.put(ord.Id, ord.Pays__c);

            // Type de compte
            mapTypeClient.put(ord.Id, ord.Account_Type__c);
        }

        // 5. Appel du selector en mode bulk
        //    Le selector doit accepter :
        //    - Set<Id> orderIds
        //    - Map<Id, String> mapPays
        //    - Map<Id, String> mapTypeClient
        Map<Id, List<Tarification__c>> resultMap = new Map<Id, List<Tarification__c>>();
        resultMap = OrderTarifAggregator.getOrderTarifs(orderIds, mapPays, mapTypeClient);

        // 6. Retour du Map complet
        return resultMap;
    }
}

