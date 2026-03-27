public with sharing class OrderTarifAggregator {

    public static Map<Id, List<Tarification__c>> getOrderTarifsByOrderIds(Set<Id> orderIds) {

        Map<Id, List<Tarification__c>> result = new Map<Id, List<Tarification__c>>();
        List<Order> orders = OrderSelector.selectByIds(new List<Id>(orderIds));

        Set<String> paysSet = new Set<String>();
        for (Order o : orders) {
            paysSet.add(o.Pays__c);
        }

        List<Tarification__c> allTarifs = [
            SELECT
                Id,
                Name,
                Tarif_de_Livraison__c,
                D_lai_de_Livraison_jours__c,
                Zone_de_Livraison__c
            FROM Tarification__c
            WHERE Zone_de_Livraison__c IN :paysSet
        ];

        Map<String, List<Tarification__c>> tarifsByKey = new Map<String, List<Tarification__c>>();

        for (Tarification__c t : allTarifs) {

            String key = t.Zone_de_Livraison__c;

            if (!tarifsByKey.containsKey(key)) {
                tarifsByKey.put(key, new List<Tarification__c>());
            }

            tarifsByKey.get(key).add(t);
        }

        for (Order o : orders) {

            String key = o.Pays__c;

            List<Tarification__c> tarifs;

            if (tarifsByKey.containsKey(key)) {
                tarifs = tarifsByKey.get(key);
            } else {
                tarifs = new List<Tarification__c>();
            }

            result.put(o.Id, getFinalOrderTarifList(tarifs));
        }

        return result;
    }

    private static Tarification__c getFastest(List<Tarification__c> tarifs) {

        Tarification__c fastest = null;
        Decimal minDays = 999999999;

        for (Tarification__c t : tarifs) {
            if (t.D_lai_de_Livraison_jours__c != null &&
                t.D_lai_de_Livraison_jours__c < minDays) {

                minDays = t.D_lai_de_Livraison_jours__c;
                fastest = t;
            }
        }

        return fastest;
    }

    private static Tarification__c getCheapest(List<Tarification__c> tarifs) {

        Tarification__c cheapest = null;
        Decimal minPrice = 999999999;

        for (Tarification__c t : tarifs) {
            if (t.Tarif_de_Livraison__c != null &&
                t.Tarif_de_Livraison__c < minPrice) {

                minPrice = t.Tarif_de_Livraison__c;
                cheapest = t;
            }
        }

        return cheapest;
    }

    private static List<Tarification__c> getFinalOrderTarifList(List<Tarification__c> tarifs) {

        List<Tarification__c> result = new List<Tarification__c>();

        Tarification__c fastest = getFastest(tarifs);
        Tarification__c cheapest = getCheapest(tarifs);

        Id fastestId = fastest != null ? fastest.Id : null;
        Id cheapestId = cheapest != null ? cheapest.Id : null;

        if (fastest != null) result.add(fastest);
        if (cheapest != null) result.add(cheapest);

        for (Tarification__c t : tarifs) {
            if (t.Id == fastestId || t.Id == cheapestId) continue;
            result.add(t);
        }

        return result;
    }

}