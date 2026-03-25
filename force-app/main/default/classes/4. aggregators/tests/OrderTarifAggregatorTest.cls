
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
        List<Account> accounts =
            TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Order> orders = TestDataFactory.createOrders(5, 3, new List<Id>{ accounts[0].Id });

        // ⚠️ tarifs corrects (IMPORTANT)
        Tarification__c t = new Tarification__c(
            Name = 'T1',
            Zone_de_Livraison__c = 'France',
            D_lai_de_Livraison_jours__c = 2,
            Tarif_de_Livraison__c = 10
        );
        insert t;

        Set<Id> orderIds = new Set<Id>();
        for (Order o : orders) orderIds.add(o.Id);

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result = OrderTarifAggregator.getOrderTarifsByOrderIds(orderIds);
        Test.stopTest();

        // THEN
        System.assertEquals(5, result.size());
    }

    @isTest
    static void positiveBehaviour() {

        // GIVEN
        List<Account> accounts =
            TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Order> orders =
            TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        Tarification__c t = new Tarification__c(
            Name = 'T1',
            Zone_de_Livraison__c = 'France',
            D_lai_de_Livraison_jours__c = 3,
            Tarif_de_Livraison__c = 15
        );
        insert t;

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
    static void allDelaysNull_shouldHandleFastestNull() {

        // GIVEN
        Tarification__c t1 = new Tarification__c(
            Name = 'T1',
            Zone_de_Livraison__c = 'France',
            Tarif_de_Livraison__c = 10
        );

        Tarification__c t2 = new Tarification__c(
            Name = 'T2',
            Zone_de_Livraison__c = 'France',
            Tarif_de_Livraison__c = 20
        );

        insert new List<Tarification__c>{ t1, t2 };

        List<Account> accounts =
            TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Order> orders =
            TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

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

    @isTest
static void allPricesNull_shouldHandleCheapestNull() {

    // GIVEN
    Tarification__c t1 = new Tarification__c(
        Name = 'T1',
        Zone_de_Livraison__c = 'France',
        D_lai_de_Livraison_jours__c = 2
    );

    Tarification__c t2 = new Tarification__c(
        Name = 'T2',
        Zone_de_Livraison__c = 'France',
        D_lai_de_Livraison_jours__c = 5
    );

    insert new List<Tarification__c>{ t1, t2 };

    List<Account> accounts =
        TestDataFactory.createAccounts(1, 'Particulier', 'France');

    List<Order> orders =
        TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

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

@isTest
static void noOrders_shouldReturnEmptyMap() {

    // WHEN
    Test.startTest();
    Map<Id, List<Tarification__c>> result =
        OrderTarifAggregator.getOrderTarifsByOrderIds(new Set<Id>());
    Test.stopTest();

    // THEN
    System.assertEquals(0, result.size());
}


@isTest
static void testFastestAndCheapest_FACTORY_BASED() {

    // GIVEN
    List<Account> accounts =
        TestDataFactory.createAccounts(1, 'Particulier', 'France');

    List<Order> orders =
        TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

    // 1. Transporteurs
    List<Transporteur__c> transporters =
        TransporterFactory.assemble();
    insert transporters;

    // 2. Tarifs via ta factory
    List<Tarification__c> tarifs =
        OrderTarifFactory.assemble(transporters);

    //  IMPORTANT : compléter Account_Type__c
    //for (Tarification__c t : tarifs) {
   //     t.Account_Type__c = 'Particulier';
   // }

    insert tarifs;

    // WHEN
    Test.startTest();
    Map<Id, List<Tarification__c>> result =
        OrderTarifAggregator.getOrderTarifsByOrderIds(
            new Set<Id>{ orders[0].Id }
        );
    Test.stopTest();

    List<Tarification__c> finalList = result.get(orders[0].Id);

    // THEN

    // on a bien des résultats
    System.assert(finalList.size() > 0);

    // fastest = délai le plus court (1 jour → Chronopost)
    System.assertEquals(1, finalList[0].D_lai_de_Livraison_jours__c);

    // cheapest = prix le plus bas (14 → GLS)
    System.assertEquals(14, finalList[1].Tarif_de_Livraison__c);
}

@isTest
static void noTarif_shouldReturnEmpty() {

    List<Account> accounts =
        TestDataFactory.createAccounts(1, 'Particulier', 'France');

    List<Order> orders =
        TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

    Test.startTest();
    Map<Id, List<Tarification__c>> result =
        OrderTarifAggregator.getOrderTarifsByOrderIds(
            new Set<Id>{ orders[0].Id }
        );
    Test.stopTest();

    System.assertEquals(0, result.get(orders[0].Id).size());
}

@isTest
static void nullValues_shouldNotCrash() {

    Tarification__c t = new Tarification__c(
        Name = 'Null',
        Zone_de_Livraison__c = 'France'
      //  Account_Type__c = 'Particulier'
    );
    insert t;

    List<Account> accounts =
        TestDataFactory.createAccounts(1, 'Particulier', 'France');

    List<Order> orders =
        TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

    Test.startTest();
    Map<Id, List<Tarification__c>> result =
        OrderTarifAggregator.getOrderTarifsByOrderIds(
            new Set<Id>{ orders[0].Id }
        );
    Test.stopTest();

    System.assertNotEquals(null, result.get(orders[0].Id));
}

}