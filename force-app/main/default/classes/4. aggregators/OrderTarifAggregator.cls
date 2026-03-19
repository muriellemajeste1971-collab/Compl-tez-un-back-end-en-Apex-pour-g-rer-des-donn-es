public with sharing class OrderTarifAggregator {

    public static Map<Id, List<Tarification__c>> getOrderTarifsByOrderIds(Set<Id> orderIds) {
        
        // 1. Récupérer la liste global des Tarifs
        List<Tarification__c> tarifs = [
            SELECT  
                Id,
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
        ];

        Decimal minDays = 999999999;
        Tarification__c fastest = null;
        Id fastestId = null;
            for (Tarification__c t : tarifs) {
                if (t.D_lai_de_Livraison_jours__c != null && t.D_lai_de_Livraison_jours__c < minDays) {
                    minDays = t.D_lai_de_Livraison_jours__c;
                    fastest = t;
                    fastestId = t.Id;
                }
            }

        Decimal minPrice = 999999999;
        Tarification__c cheapest = null;
        Id cheapestId = null;
            for (Tarification__c t : tarifs) {
                if (t.Tarif_de_Livraison__c != null && t.Tarif_de_Livraison__c < minPrice) {
                    minPrice = t.Tarif_de_Livraison__c;
                    cheapest = t;
                    cheapestId = t.Id;
                }
            }

        List<Tarification__c> result = new List<Tarification__c>();

            if (fastest != null) result.add(fastest);
            if (cheapest != null) result.add(cheapest);

        List<Tarification__c> others = new List<Tarification__c>();

            for (Tarification__c t : tarifs) {
                if ((cheapestId != null && t.Id == cheapestId) || (fastestId != null && t.Id == fastestId)) continue;
                others.add(t);
            }
        
            result.addAll(others);

        return result;
    }
}