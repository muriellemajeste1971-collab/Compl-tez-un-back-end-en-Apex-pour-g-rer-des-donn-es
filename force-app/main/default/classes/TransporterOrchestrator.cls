public with sharing class TransporterOrchestrator {

    @AuraEnabled(cacheable=true)
    public static List<Tarification__c> getAllTransporters() {

        // 1️⃣ On récupère le moins cher
        Tarification__c cheapest = CheapestTransporter.getCheapest();

        // 2️⃣ On récupère le plus rapide
        Tarification__c fastest = FastestTransporter.getFastest();

        // 3️⃣ On récupère les autres en excluant les deux Id
        List<Tarification__c> others =
            OtherTransporters.getOthers(cheapest.Id, fastest.Id);

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
