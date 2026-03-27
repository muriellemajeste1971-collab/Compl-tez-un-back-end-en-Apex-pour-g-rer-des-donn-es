public with sharing class OrderItemAggregator {

    public static Map<Id, Decimal> TotalQuantityByOrder(Set<Id> orderIds) {
        
        Map<Id, Decimal> result = new Map<Id, Decimal>();

            for (AggregateResult ar : [
                SELECT OrderId, SUM(Quantity) totalQty
                FROM OrderItem
                WHERE OrderId IN :orderIds
                GROUP BY OrderId
            ]) 
            {
            result.put(
                (Id) ar.get('OrderId'),
                (Decimal) ar.get('totalQty')
            );
            }

            return result;
    }
}