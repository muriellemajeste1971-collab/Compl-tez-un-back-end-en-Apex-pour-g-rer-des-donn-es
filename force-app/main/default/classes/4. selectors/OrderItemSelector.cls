public with sharing class OrderItemSelector {

     public static Map<Id, Integer> TotalQuantityByOrder(Set<Id> orderIds) {
        
     Map<Id, Integer> result = new Map<Id, Integer>();

        for (AggregateResult ar : [
                SELECT OrderId, SUM(Quantity) totalQty
                FROM OrderItem
                WHERE OrderId IN :orderIds
                GROUP BY OrderId
            ]) 
            {
            result.put(
                (Id) ar.get('OrderId'),
                (Integer) ar.get('totalQty')
            );
            }

    return result;

    }

}