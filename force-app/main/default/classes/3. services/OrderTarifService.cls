public with sharing class OrderTarifService {

    /*
     * ============================================================
     *  MÉTHODE SINGLE (pour le LWC)
     * ============================================================
     */
    @AuraEnabled(cacheable=true)
    public static List<Tarification__c> getOrderTarifs(Id orderId) {

        //validate parameter
        if (orderId == null) {
            throw new OrderTarifServiceException('Order Id not specified.');
        }

        Map<Id, List<Tarification__c>> resultMap =
            getOrderTarifsByOrderIds(new Set<Id>{ orderId });

        return resultMap.get(orderId);
    }

    /*
     * ============================================================
     *  MÉTHODE BULK (pour tests et logique interne)
     * ============================================================
     */
    public static Map<Id, List<Tarification__c>> getOrderTarifsByOrderIds(Set<Id> orderIds) {

        return OrderTarifAggregator.getOrderTarifsByOrderIds(orderIds);
    }
}
