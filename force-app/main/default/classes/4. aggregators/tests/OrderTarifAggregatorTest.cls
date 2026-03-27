
@isTest
private class OrderTarifAggregatorTest {

    @isTest
    static void test1_singleAction() {

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
    static void test2_bulkActions() {
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
    static void test3_positiveBehaviour() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        orders[0].ShippingCountry ='FR';
        update orders;

       List<Tarification__c> tarifs = TestDataFactory.createTarifs();

       Tarification__c fastest = tarifs[0];
       Tarification__c cheapest = tarifs[1];
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
    static void test4_negativeBehaviour() {

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
    static void test5_restrictedUser() {

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
static void tes6_france() {

    // GIVEN
    List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

    List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

    // Correction essentielle : renseigner le pays de la commande
    orders[0].ShippingCountry = 'FR';
    update orders;

    TestDataFactory.createTarifs();

    // WHEN
    Test.startTest();
    Map<Id, List<Tarification__c>> result =
        OrderTarifAggregator.getOrderTarifsByOrderIds(
            new Set<Id>{ orders[0].Id }
        );
    Test.stopTest();

    List<Tarification__c> listResult = result.get(orders[0].Id);

    // THEN
    System.assertEquals(4, listResult.size());
    System.assertEquals(1, listResult[0].D_lai_de_Livraison_jours__c);
    System.assertEquals(14, listResult[1].Tarif_de_Livraison__c);
}


    @isTest
    static void test07_belgique() {

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'Belgique');

        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        orders[0].Status = 'Activated';
        update orders;

        TestDataFactory.createTarifs();

        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifAggregator.getOrderTarifsByOrderIds(
                new Set<Id>{ orders[0].Id }
            );
        Test.stopTest();

        List<Tarification__c> listResult = result.get(orders[0].Id);

        System.assertEquals(3, listResult.size());
    }

    @isTest
    static void test8_noTarif() {

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'Espagne');

        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        orders[0].Status = 'Activated';
        update orders;

        TestDataFactory.createTarifs();

        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifAggregator.getOrderTarifsByOrderIds(
                new Set<Id>{ orders[0].Id }
            );
        Test.stopTest();

        System.assertEquals(0, result.get(orders[0].Id).size());
    }
    


@isTest
static void test10_noTarif_shouldReturnEmpty() {

    List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

    List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
    orders[0].Status = 'Activated';
    update orders;

    TestDataFactory.createTarifs();

    Test.startTest();
    Map<Id, List<Tarification__c>> result =
        OrderTarifAggregator.getOrderTarifsByOrderIds(
            new Set<Id>{ orders[0].Id }
        );
    Test.stopTest();

    System.assertEquals(0, result.get(orders[0].Id).size());
}



@isTest
static void test_full_fastest_and_cheapest() {

    // GIVEN
    List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
    List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
    orders[0].Status = 'Activated';
    update orders;
   

    // Tarifs France + Belgique
    List<Tarification__c> tarifs = TestDataFactory.createTarifs();

    // On récupère les tarifs France dans l’ordre de ta factory
    Tarification__c t1 = tarifs[0]; // 20€ / 1 jour
    Tarification__c t2 = tarifs[1]; // 23€ / 2 jours
    Tarification__c t3 = tarifs[2]; // 18€ / 2 jours
    Tarification__c t4 = tarifs[3]; // 14€ / 3 jours

    // WHEN
    Test.startTest();
    Map<Id, List<Tarification__c>> mapResult =
        OrderTarifAggregator.getOrderTarifsByOrderIds(new Set<Id>{ orders[0].Id });
    Test.stopTest();

    List<Tarification__c> result = mapResult.get(orders[0].Id);

    System.debug('RESULT = ' + result);

    // fastest = t1 (1 jour)
    Tarification__c fastest = result[0];

    // cheapest = t4 (14€)
    Tarification__c cheapest = result[1];

    // THEN
    System.assert(result.size() > 2, 'La liste doit contenir fastest + cheapest + autres');
    System.assertEquals(t1.Id, fastest.Id, 'Fastest incorrect');
    System.assertEquals(t4.Id, cheapest.Id, 'Cheapest incorrect');
}


    @isTest
    static void test12_getOrderTarifsByOrderIds_grouping() {

        // GIVEN
        // 1. Create an account in France (zone = France)
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        // 2. Create 1 order for this account
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
       

        // 3. Create tarifs (France + Belgique)
        //    → OrderTarifFactory crée déjà plusieurs tarifs France + Belgique
        List<Tarification__c> tarifs = TestDataFactory.createTarifs();

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifAggregator.getOrderTarifsByOrderIds(new Set<Id>{ orders[0].Id });
        Test.stopTest();

        // THEN
        System.assert(result.containsKey(orders[0].Id), 'Order should have tarif list');

        List<Tarification__c> returnedTarifs = result.get(orders[0].Id);

        // On doit avoir au moins 1 tarif (fastest + cheapest)
        System.assert(returnedTarifs.size() > 0, 'Tarifs should not be empty');

        // Vérifier que les tarifs retournés correspondent bien à la zone France
        for (Tarification__c t : returnedTarifs) {
            System.assertEquals('France', t.Zone_de_Livraison__c, 'Tarif zone must match order country');
        }
}

}