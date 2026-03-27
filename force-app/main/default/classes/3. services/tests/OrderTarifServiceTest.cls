@isTest
private class OrderTarifServiceTest {

    @isTest
    static void singleAction() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        TestDataFactory.createTarifs();
        TestDataFactory.createDeliveryOrders(accounts, orders);

        // WHEN
        Test.startTest();
        List<Tarification__c> result =
            OrderTarifService.getByOrderIds(orders[0].Id);
        Test.stopTest();

        // THEN
        System.assertNotEquals(null, result);
    }

    @isTest
    static void bulkActions() {

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        Set<Id> accountIds = new Set<Id>();
        for (Account a : accounts) {
            accountIds.add(a.Id);
        }

        List<Order> orders = TestDataFactory.createOrders(200, 3, new List<Id>(accountIds));

        Set<Id> orderIds = new Set<Id>();
        for (Order o : orders) {
            orderIds.add(o.Id);
        }

        List<Tarification__c> tarifs = TestDataFactory.createTarifs();

        TestDataFactory.createDeliveryOrders(accounts, orders);

        Test.startTest();
        Map<Id, List<Tarification__c>> result = OrderTarifService.getByOrderIds(orderIds);
        Test.stopTest();

        System.assertEquals(orders.size(), result.size());

    }

    @isTest
    static void negativeBehaviour() {

        // WHEN
        Test.startTest();
        try {
            OrderTarifService.getByOrderIds((Id) null);
            System.assert(false);
        } catch (OrderTarifServiceException e) {
            System.assertEquals('Order Id not specified.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void getByOrderIds_noTarif_shouldReturnEmptyList() {

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        Test.startTest();
        List<Tarification__c> result =
            OrderTarifService.getByOrderIds(orders[0].Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void restrictedUser() {

        // GIVEN
        List<User> users = TestDataFactory.createUsers(
            new List<String>{ 'Chatter Free User' }
        );
        User restrictedUser = users[0];

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        TestDataFactory.createTarifs();
        TestDataFactory.createDeliveryOrders(accounts, orders);

        // WHEN
        Test.startTest();
        List<Tarification__c> result;

        System.runAs(restrictedUser) {
            result = OrderTarifService.getByOrderIds(orders[0].Id);
        }
        Test.stopTest();

        // THEN
        System.assert(
            result == null || result.isEmpty(),
            'Un utilisateur restreint ne doit voir aucun tarif'
        );
    }
}