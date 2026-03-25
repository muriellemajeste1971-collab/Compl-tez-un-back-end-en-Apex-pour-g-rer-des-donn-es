
@isTest
private class OrderTarifAggregatorTest {

    @isTest
    static void singleAction() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        TestDataFactory.createTarifs();

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifAggregator.getOrderTarifsByOrderIds(
                new Set<Id>{ orders[0].Id }
            );
        Test.stopTest();

        // THEN
        System.assert(result.containsKey(orders[0].Id));
    }

    @isTest
    static void bulkActions() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(10, 'Particulier', 'France');

        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        List<Order> orders = TestDataFactory.createOrders(10, 3, accountIds);

        TestDataFactory.createTarifs();

        Set<Id> orderIds = new Set<Id>();
        for (Order o : orders) {
            orderIds.add(o.Id);
        }

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifAggregator.getOrderTarifsByOrderIds(orderIds);
        Test.stopTest();

        // THEN
        System.assertEquals(10, result.size());
    }

    @isTest
    static void positiveBehaviour() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        TestDataFactory.createTarifs();

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifAggregator.getOrderTarifsByOrderIds(
                new Set<Id>{ orders[0].Id }
            );
        Test.stopTest();

        // THEN
        List<Tarification__c> tarifs = result.get(orders[0].Id);
        System.assertNotEquals(null, tarifs);
        System.assert(tarifs.size() > 0);
    }

    @isTest
    static void negativeBehaviour_noTarif() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        // PAS de tarifs

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifAggregator.getOrderTarifsByOrderIds(
                new Set<Id>{ orders[0].Id }
            );
        Test.stopTest();

        // THEN
        System.assertEquals(0, result.get(orders[0].Id).size());
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

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result;

        System.runAs(restrictedUser) {
            result =
                OrderTarifAggregator.getOrderTarifsByOrderIds(
                    new Set<Id>{ orders[0].Id }
                );
        }
        Test.stopTest();

        // THEN
        System.assert(
            result.get(orders[0].Id) == null ||
            result.get(orders[0].Id).isEmpty()
        );
    }

    @isTest
    static void fastestEqualsCheapest_shouldNotDuplicate() {

        // GIVEN
        Tarification__c t = new Tarification__c(
            Name = 'Test',
            Zone_de_Livraison__c = 'France',
            D_lai_de_Livraison_jours__c = 1,
            Tarif_de_Livraison__c = 10
        );
        insert t;

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifAggregator.getOrderTarifsByOrderIds(
                new Set<Id>{ orders[0].Id }
            );
        Test.stopTest();

        // THEN
        System.assertEquals(1, result.get(orders[0].Id).size());
    }

    @isTest
    static void tarifs_withNullValues_shouldBeHandled() {

        // GIVEN
        Tarification__c t1 = new Tarification__c(
            Name = 'NullTest1',
            Zone_de_Livraison__c = 'France'
           
        );

        Tarification__c t2 = new Tarification__c(
            Name = 'Valid',
            Zone_de_Livraison__c = 'France',
            D_lai_de_Livraison_jours__c = 5,
            Tarif_de_Livraison__c = 20
        );

        insert new List<Tarification__c>{ t1, t2 };

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifAggregator.getOrderTarifsByOrderIds(
                new Set<Id>{ orders[0].Id }
            );
        Test.stopTest();

        // THEN
        System.assert(result.get(orders[0].Id).size() > 0);
    }


}