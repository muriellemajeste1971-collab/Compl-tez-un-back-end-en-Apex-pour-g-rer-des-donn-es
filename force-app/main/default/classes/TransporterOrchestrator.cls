public with sharing class TransporterOrchestrator {

    @AuraEnabled(cacheable=true)
    public static List<Tarification__c> getAllTransporters(Id orderId) {

        // Déclaration d'une variable de type Order pour récupérer les informations de la commande
        Order   ord;
        ord = [
            SELECT  Id, 
                    Pays__c, 
                    Account.Name, 
                    Account.Customer_Type__c, 
                    Product_Number__c  
            FROM Order 
            WHERE Id = :orderId
             ];

        // On récupère le pays de livraison et le type de client à partir de la commande
        String pays;
        pays = ord.Pays__c;

        String typeClient;
        typeClient = ord.Account.Customer_Type__c;


        // 🔍 DEBUG : vérifier ce que l’orchestrateur reçoit réellement
        System.debug('>>> ORCHESTRATOR - pays = "' + pays + '"');
        System.debug('>>> ORCHESTRATOR - typeClient = "' + typeClient + '"');


        // 1️⃣ On récupère le moins cher
        Tarification__c cheapest = CheapestTransporter.getCheapest(pays, typeClient);

        // 2️⃣ On récupère le plus rapide
        Tarification__c fastest = FastestTransporter.getFastest(pays, typeClient);

        // 3️⃣ On récupère les autres en excluant les deux Id
        List<Tarification__c> others =
            OtherTransporters.getOthers(cheapest.Id, fastest.Id, pays, typeClient);

        // 4️⃣ On assemble tout dans l’ordre voulu
        List<Tarification__c> result = new List<Tarification__c>();

        // ⚠️ Si fastest et cheapest sont le même transporteur
        if (fastest.Id == cheapest.Id) {
            result.add(fastest);
        } else {
            result.add(fastest);
            result.add(cheapest);
        }

        result.addAll(others);

        return result;
    }
}
