public with sharing class FastestTransporter {

    @AuraEnabled(cacheable=true)
    public static Tarification__c getFastest(String pays, String typeClient) {

     
        // On récupère le transporteur le plus rapide
        return [
            SELECT  Id,
                    Name,
                    Tarif_de_Livraison__c, 
                    D_lai_de_Livraison_jours__c,    
                    Zone_de_Livraison__c,   
                    Transporteur__r.Customer_Type__c  

            FROM Tarification__c
            WHERE Zone_de_Livraison__c = :pays

            AND (
                Transporteur__r.Customer_Type__c = :typeClient
                OR Transporteur__r.Customer_Type__c = 'Particulier, Professionnel'
            )
            ORDER BY D_lai_de_Livraison_jours__c ASC, Tarif_de_Livraison__c ASC
            LIMIT 1
        ];
    }
}
