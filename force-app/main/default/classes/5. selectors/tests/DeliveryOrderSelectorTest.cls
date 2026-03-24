@isTest
public class DeliveryOrderSelectorTest {

    @isTest
    static void singleAction() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        List<Order> orders = TestDataFactory.createOrders(1, 4, accountIds);

        List<Id> orderIds = new List<Id>();
        for (Order ord : orders) {
            orderIds.add(ord.Id);
        }

        TestDataFactory.createTarifs();

        List<Livraison__c> deliveries = TestDataFactory.createDeliveryOrders(accounts, orders);

        // WHEN
        Test.startTest();
        List<Livraison__c> result = DeliveryOrderSelector.selectByOrderIds(orderIds);
        Test.stopTest();

        
        // THEN
        // ✔ 1 livraison par Order
        System.assertEquals(orderIds.size(), result.size());

        // ✔ cohérence Order → Livraison
        Map<Id, Livraison__c> deliveriesByOrderId = new Map<Id, Livraison__c>();
            for (Livraison__c l : result) {
                deliveriesByOrderId.put(l.Order__c, l);
            }

            for (Id orderId : orderIds) {
                System.assert(
                    deliveriesByOrderId.containsKey(orderId),
                    'Chaque Order doit avoir une livraison associée'
                );
            }
    }

    @isTest
    static void singleActionIds() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Id> accountIds = new List<Id>();
            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }

        List<Order> orders = TestDataFactory.createOrders(1, 4, accountIds);
        List<Id> orderIds = new List<Id>();
            for (Order ord : orders) {
                orderIds.add(ord.Id);
            }

        TestDataFactory.createTarifs();

        List<Livraison__c> deliveries = TestDataFactory.createDeliveryOrders(accounts, orders);
        List<Id> deliveryIds = new List<Id>();
            for (Livraison__c dlvo : deliveries) {
                deliveryIds.add(dlvo.Id);
            }

        // WHEN
        Test.startTest();
        List<Livraison__c> result = DeliveryOrderSelector.selectByIds(deliveryIds);
        Test.stopTest();
        
        // THEN
        // ✔ 1 livraison par Order
        System.assertEquals(orderIds.size(), result.size());

        // ✔ cohérence Order → Livraison
        Map<Id, Livraison__c> deliveriesByOrderId = new Map<Id, Livraison__c>();
            for (Livraison__c l : result) {
                deliveriesByOrderId.put(l.Order__c, l);
            }

            for (Id orderId : orderIds) {
                System.assert(
                    deliveriesByOrderId.containsKey(orderId),
                    'Chaque Order doit avoir une livraison associée'
                );
            }
    }

    @isTest
    static void bulkActions() {

         // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        List<Order> orders = TestDataFactory.createOrders(200, 4, accountIds);

        List<Id> orderIds = new List<Id>();
        for (Order ord : orders) {
            orderIds.add(ord.Id);
        }

        TestDataFactory.createTarifs();

        List<Livraison__c> deliveries = TestDataFactory.createDeliveryOrders(accounts, orders);

        // WHEN
        Test.startTest();
        List<Livraison__c> result = DeliveryOrderSelector.selectByOrderIds(orderIds);
        Test.stopTest();

        // THEN

        // ✔ 1 livraison par Order
        System.assertEquals(orderIds.size(), result.size());

        // ✔ cohérence Order → Livraison
        Map<Id, Livraison__c> deliveriesByOrderId = new Map<Id, Livraison__c>();
        for (Livraison__c l : result) {
            deliveriesByOrderId.put(l.Order__c, l);
        }

        for (Id orderId : orderIds) {
            System.assert(
                deliveriesByOrderId.containsKey(orderId),
                'Chaque Order doit avoir une livraison associée'
            );
        }
    }

    @isTest
    static void positiveBehavior_selectByOrderIds() {
        
        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(10, 'Particulier', 'France');

        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        List<Order> orders = TestDataFactory.createOrders(10, 4, accountIds);

        List<Id> orderIds = new List<Id>();
        for (Order ord : orders) {
            orderIds.add(ord.Id);
        }

        TestDataFactory.createTarifs();

        List<Livraison__c> deliveries = TestDataFactory.createDeliveryOrders(accounts, orders);

        // WHEN
        Test.startTest();
        List<Livraison__c> result = DeliveryOrderSelector.selectByOrderIds(orderIds);
        Test.stopTest();

        // THEN

        // ✔ 1 livraison par Order
        System.assertEquals(orderIds.size(), result.size());

        // ✔ cohérence Order → Livraison
        Map<Id, Livraison__c> deliveriesByOrderId = new Map<Id, Livraison__c>();
        for (Livraison__c l : result) {
            deliveriesByOrderId.put(l.Order__c, l);
        }

        for (Id orderId : orderIds) {
            System.assert(
                deliveriesByOrderId.containsKey(orderId),
                'Chaque Order doit avoir une livraison associée'
            );
        }
    }

   @isTest
    static void negativeBehaviour() {

        // GIVEN
        List<Id> orderIds = new List<Id>();

        // WHEN
        Test.startTest();
        List<Livraison__c> result =
            DeliveryOrderSelector.selectByOrderIds(orderIds);
        Test.stopTest();

        // THEN
        System.assertEquals(0, result.size());
    }

    @isTest
    static void restrictedUser() {

        // GIVEN
        List<User> users = TestDataFactory.createUsers(
            new List<String>{ 'Chatter Free User' }
        );
        User restrictedUser = users[0];

        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> o = TestDataFactory.createOrders(1, 1, new List<Id>{ a[0].Id });
        TestDataFactory.createTarifs();
        TestDataFactory.createDeliveryOrders(a, o);

        List<Id> orderIds = new List<Id>{ o[0].Id };

        // WHEN
        Test.startTest();
        System.runAs(restrictedUser) {
            List<Livraison__c> result =
                DeliveryOrderSelector.selectByOrderIds(orderIds);

            // THEN
            System.assertNotEquals(null, result);
        }
        Test.stopTest();
    }

}
