public with sharing class OrderService {

    // ---------------------------------------------------------
    // 1. CREER une Livraison pour un Order
    // ---------------------------------------------------------
    @AuraEnabled
    public static Id createLivraison(Id orderId, Id selectedTarificationId) {

        Order ord = [
            SELECT Id, AccountId, Livraison_Name__c
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        Livraison__c liv = new Livraison__c(
            Name = ord.Livraison_Name__c,
            Order__c = ord.Id,
            Account__c = ord.AccountId,
            Tarification__c = selectedTarificationId,
            Statut__c = 'En cours'
        );

        insert liv;
        return liv.Id;
    }

    // ---------------------------------------------------------
    // 2. RECUPERER la Livraison liée à un Order
    // ---------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static Livraison__c getLivraisonByOrder(Id orderId) {
        List<Livraison__c> livs = [
            SELECT Id, Tarification__c, Statut__c
            FROM Livraison__c
            WHERE Order__c = :orderId
            LIMIT 1
        ];
        return livs.isEmpty() ? null : livs[0];
    }

    // ---------------------------------------------------------
    // 3. METTRE A JOUR la Livraison liée à un Order
    // (Supprime l'ancienne et en crée une nouvelle avec la nouvelle tarification)
    // ---------------------------------------------------------
    @AuraEnabled
    public static Id updateLivraison(Id livraisonId, Id newTarificationId) {
        Livraison__c liv = [
            SELECT Id, Order__c, Name, Account__c, Statut__c
            FROM Livraison__c
            WHERE Id = :livraisonId
            LIMIT 1
        ];

        // Supprimer l'ancienne livraison
        delete liv;

        // Créer une nouvelle livraison avec la nouvelle tarification
        Livraison__c newLiv = new Livraison__c(
            Name = liv.Name,
            Order__c = liv.Order__c,
            Account__c = liv.Account__c,
            Tarification__c = newTarificationId,
            Statut__c = liv.Statut__c
        );

        insert newLiv;
        return newLiv.Id;
    }


    // ---------------------------------------------------------
    // 4. SUPPRIMER la Livraison liée à un Order (bouton UI)
    // ---------------------------------------------------------
    @AuraEnabled
    public static void deleteLivraison(Id orderId) {

        List<Livraison__c> livs = [
            SELECT Id
            FROM Livraison__c
            WHERE Order__c = :orderId
        ];

        delete livs;
    }

    // ---------------------------------------------------------
    // 5. SUPPRIMER automatiquement la Livraison si l’Order est supprimé
    //    (appelé par le trigger Order BEFORE DELETE)
    // ---------------------------------------------------------
    public static void deleteLivraisonsByOrders(Set<Id> orderIds) {

        if (orderIds.isEmpty()) return;

        // Appel au Selector (pas de SOQL ici)
        List<Livraison__c> livs = LivraisonSelector.getByOrders(orderIds);

        if (!livs.isEmpty()) {
            delete livs;
        }
    }
}
