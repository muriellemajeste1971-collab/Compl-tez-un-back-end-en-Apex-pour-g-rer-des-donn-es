public with sharing class OtherTransporters {

    @AuraEnabled(cacheable=true)
    public static List<Tarification__c> getOthers(Id cheapestId, Id fastestId, String pays, String typeClient) {
       
        
        // On récupère tous les transporteurs SAUF les deux Id fournis
        return [
            SELECT Id,
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
            AND Id != :cheapestId
            AND Id != :fastestId
            ORDER BY D_lai_de_Livraison_jours__c ASC, Tarif_de_Livraison__c ASC
        ];
    }
}
