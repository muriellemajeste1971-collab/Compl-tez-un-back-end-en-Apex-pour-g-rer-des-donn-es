public with sharing class OrderItemFactory {

    public static List<OrderItem> assemble(List<Order> orders, Integer numberOfProducts, List<PricebookEntry> entries, List<Product2> products) {
            
        List<OrderItem> items = new List<OrderItem>();

            for (Order o : orders) {

                    for (Integer i = 0; i < numberOfProducts; i++) {

                        OrderItem oi = new OrderItem(
                            OrderId = o.Id,
                            PricebookEntryId = entries[i].Id,
                            Product2Id = products[i].Id,
                            Quantity = 1,
                            UnitPrice = entries[i].UnitPrice
                        );

                    items.add(oi);
                }
            }

        return items;
    }
}