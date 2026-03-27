public with sharing class OrderTarifFactory {
    public static List<Tarification__c> assemble(List<Transporteur__c> transporters) {

        List<Tarification__c> tarifs = new List<Tarification__c>();

        // Map des transporteurs par nom
        Map<String, Transporteur__c> tMap = new Map<String, Transporteur__c>();
            for (Transporteur__c t : transporters) {
                tMap.put(t.Name, t);
            }

            tarifs.add(new Tarification__c(Zone_de_livraison__c = 'France', Tarif_de_livraison__c = 20, D_lai_de_Livraison_jours__c = 1, Transporteur__c = tMap.get('Chronopost').Id));
            tarifs.add(new Tarification__c(Zone_de_livraison__c = 'France', Tarif_de_livraison__c = 23, D_lai_de_Livraison_jours__c = 2, Transporteur__c = tMap.get('UPS').Id));
            tarifs.add(new Tarification__c(Zone_de_livraison__c = 'France', Tarif_de_livraison__c = 18, D_lai_de_Livraison_jours__c = 2, Transporteur__c = tMap.get('Geodis').Id));
            tarifs.add(new Tarification__c(Zone_de_livraison__c = 'France', Tarif_de_livraison__c = 14, D_lai_de_Livraison_jours__c = 3, Transporteur__c = tMap.get('GLS').Id));
            tarifs.add(new Tarification__c(Zone_de_livraison__c = 'Belgique', Tarif_de_livraison__c = 25, D_lai_de_Livraison_jours__c = 2, Transporteur__c = tMap.get('DHL Express').Id));
            tarifs.add(new Tarification__c(Zone_de_livraison__c = 'Belgique', Tarif_de_livraison__c = 18, D_lai_de_Livraison_jours__c = 3, Transporteur__c = tMap.get('Chronopost').Id));
            tarifs.add(new Tarification__c(Zone_de_livraison__c = 'Belgique', Tarif_de_livraison__c = 20, D_lai_de_Livraison_jours__c = 3, Transporteur__c = tMap.get('UPS').Id)); 
        
        return tarifs;
    }
}