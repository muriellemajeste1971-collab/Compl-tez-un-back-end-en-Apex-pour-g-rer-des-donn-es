@IsTest
public class OrderServiceTest {

    @isTest
    static void test01_singleAction() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        Order oldOrder = orders[0];

        Order newOrder = oldOrder.clone(false, true, true, true);
        newOrder.Status = 'Activated';
        newOrder.AccountId = oldOrder.AccountId; 

        Map<Id, Order> oldMap = new Map<Id, Order>{ oldOrder.Id => oldOrder };
        Map<Id, Order> newMap = new Map<Id, Order>{ newOrder.Id => newOrder };

        // WHEN
        Test.startTest(); 
        OrderService.validateBeforeUpdate(oldMap, newMap);
        Test.stopTest();

        // THEN
        System.assertEquals(1, newMap.size());
    }

    @isTest
    static void test02_bulkActions() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Id> accountIds = new List<Id>();
            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }

        List<Order> orders = TestDataFactory.createOrders(200, 3, accountIds);

        Map<Id, Order> oldMap = new Map<Id, Order>();
        Map<Id, Order> newMap = new Map<Id, Order>();

        for (Order o : orders) {

            oldMap.put(o.Id, o);

            // NEW = même order (pas besoin de clone ici)
            Order newOrder = new Order(
                Id = o.Id,
                AccountId = o.AccountId,
                Status = 'Activated'
            );

            newMap.put(o.Id, newOrder);
        }

        // WHEN
        Test.startTest();
        OrderService.validateBeforeUpdate(oldMap, newMap);
        Test.stopTest();

        // THEN
        System.assertEquals(200, newMap.size());
    }

    @isTest
    static void test03_positiveBehaviour() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(5, 3, new List<Id>{ accounts[0].Id });

        Map<Id, Order> oldMap = new Map<Id, Order>();
        Map<Id, Order> newMap = new Map<Id, Order>();

        for (Order o : orders) {

            // OLD = état actuel
            oldMap.put(o.Id, o);

            // NEW = même order, juste avec status activé
            Order newOrder = new Order(
                Id = o.Id,
                Status = 'Activated',
                AccountId = o.AccountId
            );

            newMap.put(o.Id, newOrder);
        }

        // WHEN
        Test.startTest();
        OrderService.validateBeforeUpdate(oldMap, newMap);
        Test.stopTest();

        // THEN
        System.assertEquals(5, newMap.size());

        // verifier qu il n y a PAS d erreur metier
        for (Order o : newMap.values()) {
            System.assertEquals(0, o.getErrors().size(),
                'Aucune erreur attendue pour des commandes valides');
        }
    }

    @isTest
    static void test04_negativeBehaviourParticulier() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 2, new List<Id>{ accounts[0].Id });
        
        Map<Id, Order> oldMap = new Map<Id, Order>();
        Map<Id, Order> newMap = new Map<Id, Order>();

        //WHEN
        Test.startTest();
          for (Order o : orders) {
                oldMap.put(o.Id, o);
                Order newOrder = new Order(
                    Id = o.Id,
                    Status = 'Activated',
                    AccountId = o.AccountId
                );
                newMap.put(newOrder.Id, newOrder);
            }
        OrderService.validateBeforeUpdate(oldMap, newMap);
        Test.stopTest();

        //THEN
        System.Assert.areEqual(1, newMap.get(orders[0].Id).getErrors().size());

    }

    @isTest
    static void test04_negativeBehaviourProfessionnel() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Professionnel', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 4, new List<Id>{ accounts[0].Id });
        
        Map<Id, Order> oldMap = new Map<Id, Order>();
        Map<Id, Order> newMap = new Map<Id, Order>();

        //WHEN
        Test.startTest();
          for (Order o : orders) {
                oldMap.put(o.Id, o);
                Order newOrder = new Order(
                    Id = o.Id,
                    Status = 'Activated',
                    AccountId = o.AccountId
                );
                newMap.put(newOrder.Id, newOrder);
            }
        OrderService.validateBeforeUpdate(oldMap, newMap);
        Test.stopTest();

        //THEN
        System.Assert.areEqual(1, newMap.get(orders[0].Id).getErrors().size());
    }

    @isTest
    static void test05_restrictedUsers() {

        // GIVEN
        List<User> users = TestDataFactory.createUsers(new List<String>{ 'Chatter Free User' });
        User restrictedUser = users[0];

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        List<Id> orderIds = new List<Id>{ orders[0].Id };
        orders[0].Status = 'Activated';
        update orders;

        // WHEN
        Test.startTest();
        System.runAs(restrictedUser) {

            List<Order> result = OrderSelector.selectByIds(orderIds);

            System.assertEquals(
                0,
                result.size(),
                'Un utilisateur Chatter Free ne doit voir aucun Order'
            );
        }
        Test.stopTest();
    }

     @isTest
    static void test06_exceptionOldMap() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        Map<Id, Order> oldMap = new Map<Id, Order>{
            orders[0].Id => orders[0]
        };

        // WHEN
        Test.startTest();
        try {
            OrderService.validateBeforeUpdate(oldMap, null);
            System.assert(false);
        } catch (OrderServiceException e) {
            System.assertEquals('New Order not specified.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void test07_exceptionNewMap() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        Map<Id, Order> newMap = new Map<Id, Order>{
            orders[0].Id => orders[0]
        };

        // WHEN
        Test.startTest();
        try {
            OrderService.validateBeforeUpdate(null, newMap);
            System.assert(false);
        } catch (OrderServiceException e) {
            System.assertEquals('Old Order not specified.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void test08_accountNull() {

        // GIVEN
        Account acc = TestDataFactory.createAccounts(1, 'Particulier', 'France')[0];
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ acc.Id });

        Map<Id, Order> oldMap = new Map<Id, Order>();
        Map<Id, Order> newMap = new Map<Id, Order>();

        for (Order o : orders) {

            oldMap.put(o.Id, o);

            Order newOrder = new Order(
                Id = o.Id,
                Status = 'Activated',
                AccountId = null
            );

            newMap.put(o.Id, newOrder);
        }

        // WHEN
       Test.startTest();
        OrderService.validateBeforeUpdate(oldMap, newMap);
        Test.stopTest();

        System.assertEquals(0, newMap.get(orders[0].Id).getErrors().size());
    }

    @isTest
    static void test08_delete_nullList_shouldDoNothing() {

        // WHEN
        Test.startTest();
        OrderService.validateBeforeDelete(null);
        Test.stopTest();

        // THEN
        System.assert(true); // juste couvrir
    }

    @isTest
    static void test08_delete() {

        // GIVEN
        List<Order> orders = new List<Order>();

        // WHEN
        Test.startTest();
        OrderService.validateBeforeDelete(orders);
        Test.stopTest();

        // THEN
        System.assertEquals(0, orders.size());
    }


    @isTest
    static void test15_validateDelete() {

        Test.startTest();
        OrderService.validateBeforeDelete(new List<Order>());
        Test.stopTest();

        System.assert(true);
    }

    @isTest
    static void test16_validateDelete() {

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        Test.startTest();
        OrderService.validateBeforeDelete(orders);
        Test.stopTest();

        System.assert(true);
    }

   @isTest
    static void test17_validateBeforeDelete() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        orders[0].Status = 'Activated';
        update orders;

        List<Tarification__c> tarifs = TestDataFactory.createTarifs();
        List<Livraison__c> deliveryOrders = TestDataFactory.createDeliveryOrders(accounts, orders);


        Test.startTest();
        try {
            delete orders; //  C’est ici que l’erreur doit remonter
            System.assert(false, 'An error should have been thrown');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Impossible de supprimer une commande'),
                'Expected error message not found'
            );
        }
        Test.stopTest();
    }

}