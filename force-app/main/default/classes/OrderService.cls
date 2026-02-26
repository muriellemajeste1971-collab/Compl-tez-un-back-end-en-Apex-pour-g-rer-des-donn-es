public with sharing class OrderService {

    
    @AuraEnabled
    public static Id createLivraison(Id orderId, Id selectedTarificationId) {

    Order ord = [
        SELECT Id, AccountId, Livraison_Name__c
        FROM Order
        WHERE Id = :orderId
        LIMIT 1
    ];

    Livraison__c liv = new Livraison__c(Name = ord.Livraison_Name__c);

    liv.Name = ord.Livraison_Name__c;
    liv.Order__c = ord.Id;
    liv.Account__c = ord.AccountId;
    liv.Tarification__c = selectedTarificationId;
    liv.Statut__c = 'En cours';

    insert liv;

    return liv.Id;
}

    //TODO : Completer la classe avec toute autre méthode nécessaire pour gérer la logique métier liée aux commandes

}