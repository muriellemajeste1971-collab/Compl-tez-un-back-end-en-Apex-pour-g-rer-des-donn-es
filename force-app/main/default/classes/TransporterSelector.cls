public with sharing class TransporterSelector {

    @AuraEnabled(cacheable=true)
    public static List<Tarification__c> getTarifications() {

        // 1️⃣ LA MOINS CHÈRE
        Tarification__c cheapest = [
            SELECT Id, Name, Tarif_de_livraison__c, D_lai_de_Livraison_jours__c
            FROM Tarification__c
            WHERE Zone_de_livraison__c = 'France'
            AND (
                Transporteur__r.Customer_Type__c = 'Particulier'
                OR Transporteur__r.Customer_Type__c = 'Particulier, Professionnel'
            )
            ORDER BY Tarif_de_livraison__c ASC
            LIMIT 1
        ];

        // 2️⃣ LA PLUS RAPIDE
        Tarification__c fastest = [
            SELECT Id, Name, Tarif_de_livraison__c, D_lai_de_Livraison_jours__c
            FROM Tarification__c
            WHERE Zone_de_livraison__c = 'France'
            AND (
                Transporteur__r.Customer_Type__c = 'Particulier'
                OR Transporteur__r.Customer_Type__c = 'Particulier, Professionnel'
            )
            ORDER BY D_lai_de_Livraison_jours__c ASC
            LIMIT 1
        ];

        // 3️⃣ LES AUTRES
        List<Tarification__c> others = [
            SELECT Id, Name, Tarif_de_livraison__c, D_lai_de_Livraison_jours__c
            FROM Tarification__c
            WHERE Zone_de_livraison__c = 'France'
            AND (
                Transporteur__r.Customer_Type__c = 'Particulier'
                OR Transporteur__r.Customer_Type__c = 'Particulier, Professionnel'
            )
            AND Id NOT IN :new List<Id>{cheapest.Id, fastest.Id}
            ORDER BY Name
        ];

        // On construit une seule liste pour le LWC
        List<Tarification__c> result = new List<Tarification__c>();

        result.add(cheapest);
        result.add(fastest);
        result.addAll(others);

        return result;
    }
}