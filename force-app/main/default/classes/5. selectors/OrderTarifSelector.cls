public with sharing class OrderTarifSelector {

    public static List<Tarification__c> selectByTarif() {
        
        return [
            SELECT  
                Id,
                Name,
                Tarif_de_Livraison__c, 
                D_lai_de_Livraison_jours__c,    
                Zone_de_Livraison__c,   
                Account_Type__c,
                Transporteur__c,
                IsDeleted      
            FROM Tarification__c
        ];
    }
}