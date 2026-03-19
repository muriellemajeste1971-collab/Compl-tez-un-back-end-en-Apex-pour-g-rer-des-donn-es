public with sharing class TransporterOrchestrator {

   
    @AuraEnabled(cacheable=true)
    public static List<Tarification__c> getAllTransporters(Id orderId) {

        // Récupération des infos de la commande
        Order ord = [
            SELECT  Id,
                    Pays__c,
                    Account_Type__c
            FROM Order
            WHERE Id = :orderId
        ];

        String pays = ord.Pays__c;
        String typeClient = ord.Account_Type__c;

        System.debug('>>> ORCHESTRATOR - pays = "' + pays + '"');
        System.debug('>>> ORCHESTRATOR - typeClient = "' + typeClient + '"');

        // Le selector renvoie déjà la liste : fastest, cheapest, others
        List<Tarification__c> result =
            OrderTarifSelector.tarifs(orderId, pays, typeClient);

        return result;
    }

    }
