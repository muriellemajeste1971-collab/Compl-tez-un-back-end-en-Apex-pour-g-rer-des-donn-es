public with sharing class OrderTarifAggregator {

    /*
     * ============================================================
     * MÉTHODE BULK (publique)
     * ============================================================
     */
    public static Map<Id, List<Tarification__c>> getOrderTarifsByOrderIds(Set<Id> orderIds) {

        Map<Id, List<Tarification__c>> result = new Map<Id, List<Tarification__c>>();

        for (Order o : OrderSelector.selectByIds(new List<Id>(orderIds))) {

            // 1. Récupérer les tarifs filtrés et triés
            List<Tarification__c> tarifs = getTarifs(o.Pays__c, o.Account_Type__c);

            // 2. Construire la liste finale (fastest, cheapest, puis les autres)
            List<Tarification__c> finalOrderTarifList = getFinalOrderTarifList(tarifs);

            result.put(o.Id, finalOrderTarifList);
        }

        return result;
    }

    /*
     * ============================================================
     * MÉTHODE 1 — Récupérer + filtrer + trier
     * ============================================================
     */
    private static List<Tarification__c> getTarifs(String pays, String typeClient) {

        return [
            SELECT
                Id,
                Name,
                Tarif_de_Livraison__c,
                D_lai_de_Livraison_jours__c,
                Zone_de_Livraison__c,
                Account_Type__c
            FROM Tarification__c
            WHERE Zone_de_Livraison__c = :pays
            AND ( Account_Type__c = :typeClient OR Account_Type__c = 'Particulier, Professionnel')
            ORDER BY D_lai_de_Livraison_jours__c ASC, Tarif_de_Livraison__c ASC
        ];
    }

    /*
     * ============================================================
     * MÉTHODE 2 — Fastest
     * ============================================================
     */
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

    /*
     * ============================================================
     * MÉTHODE 3 — Cheapest
     * ============================================================
     */
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

    /*
     * ============================================================
     * MÉTHODE 4 — Construire la liste finale
     * ============================================================
     */
    private static List<Tarification__c> getFinalOrderTarifList(List<Tarification__c> tarifs) {

        List<Tarification__c> result = new List<Tarification__c>();

        Tarification__c fastest = getFastest(tarifs);
        Tarification__c cheapest = getCheapest(tarifs);

        Id fastestId = fastest != null ? fastest.Id : null;
        Id cheapestId = cheapest != null ? cheapest.Id : null;

            // 1. Ajouter fastest
            if (fastest != null) result.add(fastest);

            // 2. Ajouter cheapest (si différent)
            if (cheapest != null) result.add(cheapest);

            // 3. Ajouter les autres
            for (Tarification__c t : tarifs) {
                if (t.Id == fastestId || t.Id == cheapestId) continue;
                result.add(t);
            }
        return result;
    }
}
