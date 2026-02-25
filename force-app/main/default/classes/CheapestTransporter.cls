public with sharing class CheapestTransporter {

    @AuraEnabled(cacheable=true)
    public static Tarification__c getCheapest() {

        // On récupère le transporteur le moins cher
        return [
            SELECT Id, Name, Tarif_de_Livraison__c, D_lai_de_Livraison_jours__c
            FROM Tarification__c
            WHERE Zone_de_Livraison__c = 'France'
            AND (
                Transporteur__r.Customer_Type__c = 'Particulier'
                OR Transporteur__r.Customer_Type__c = 'Particulier, Professionnel'
            )
            ORDER BY Tarif_de_Livraison__c ASC
            LIMIT 1
        ];
    }
}
