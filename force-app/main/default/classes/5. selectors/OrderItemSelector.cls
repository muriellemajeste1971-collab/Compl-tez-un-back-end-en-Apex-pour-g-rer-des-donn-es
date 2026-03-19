public with sharing class OrderItemSelector {
   
   public static List<OrderItem> getOrderItemByOrdersIds(List<Id> orderIds) {
        return [
            SELECT Id, OrderId, Quantity
            FROM OrderItem
            WHERE OrderId IN :orderIds
        ];
    }
}