public with sharing class OrderTarifService {

    /*
     * ============================================================
     *  MÉTHODE SINGLE (pour le LWC)
     * ============================================================
     */
    @AuraEnabled(cacheable=true)
    public static List<Tarification__c> getByOrderIds(Id orderId) {

        //validate parameter
        if (orderId == null) {
            throw new OrderTarifServiceException('Order Id not specified.');
        }

        Map<Id, List<Tarification__c>> resultMap =
            OrderTarifAggregator.getOrderTarifsByOrderIds(new Set<Id>{ orderId });

        return resultMap.get(orderId);
    }

    /*
     * ============================================================
     *  MÉTHODE BULK (pour tests et logique interne)
     * ============================================================
     */
    public static Map<Id, List<Tarification__c>> getByOrderIds(Set<Id> orderIds) {

        return OrderTarifAggregator.getOrderTarifsByOrderIds(orderIds);
    }
}
