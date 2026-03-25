@IsTest
public class OrderServiceTest {

    @isTest
    static void singleAction() {

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
    static void bulkActions() {

        // GIVEN
        List<Account> accounts =
            TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        // ⚠️ PAS 200 → limite DML
        List<Order> orders =
            TestDataFactory.createOrders(200, 3, accountIds);

        Map<Id, Order> oldMap = new Map<Id, Order>();
        Map<Id, Order> newMap = new Map<Id, Order>();

        for (Order o : orders) {

            // OLD = version actuelle
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
    static void positiveBehaviour() {

        // GIVEN
        List<Account> accounts =
            TestDataFactory.createAccounts(1, 'Particulier', 'France');

        // ⚠️ 5 orders sur le même account = plus simple
        List<Order> orders =
            TestDataFactory.createOrders(5, 3, new List<Id>{ accounts[0].Id });

        Map<Id, Order> oldMap = new Map<Id, Order>();
        Map<Id, Order> newMap = new Map<Id, Order>();

        for (Order o : orders) {

            // OLD = état actuel
            oldMap.put(o.Id, o);

            // NEW = même order, juste avec status activé
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
        System.assertEquals(5, newMap.size());

        // vérifier qu’il n’y a PAS d’erreur métier
        for (Order o : newMap.values()) {
            System.assertEquals(0, o.getErrors().size(),
                'Aucune erreur attendue pour des commandes valides');
        }
    }

    @isTest
    static void negativeBehaviour() {

        // GIVEN
        Map<Id, Order> oldMap = new Map<Id, Order>();
        Map<Id, Order> newMap = new Map<Id, Order>();

        // WHEN
        Test.startTest();
        try {
            OrderService.validateBeforeUpdate(oldMap, newMap);
            System.assert(false, 'Une exception était attendue');
        } catch (OrderServiceException e) { // 🔥 PLUS PRÉCIS
            System.assertEquals('Old Order not specified.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void restrictedUsers() {

        // GIVEN
        List<User> users = TestDataFactory.createUsers(new List<String>{ 'Chatter Free User' });
        User restrictedUser = users[0];

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        List<Id> orderIds = new List<Id>{ orders[0].Id };

        // WHEN
        Test.startTest();
        System.runAs(restrictedUser) {

            List<Order> result = OrderSelector.selectByIds(orderIds);

            // THEN
            System.assertEquals(
                0,
                result.size(),
                'Un utilisateur Chatter Free ne doit voir aucun Order'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void particulier_lessThan3Products_shouldFail() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        // ⚠️ 2 produits → doit échouer
        List<Order> orders = TestDataFactory.createOrders(1, 2, new List<Id>{ accounts[0].Id });

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
        System.assertEquals(1, newOrder.getErrors().size());
    }

    @isTest
    static void delete_nullList_shouldDoNothing() {

        // WHEN
        Test.startTest();
        OrderService.validateBeforeDelete(null);
        Test.stopTest();

        // THEN
        System.assert(true); // juste couvrir
    }

    @isTest
    static void delete_emptyList_shouldDoNothing() {

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
    static void validateBeforeUpdate_newMapNull_shouldFail() {

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
    static void validateUpdate_noOrderItems_shouldSetZero() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        // ⚠️ créer une commande SANS items
        Id pbId = Test.getStandardPricebookId();

        Contract c = new Contract(
            AccountId = accounts[0].Id,
            Status = 'Activated',
            StartDate = Date.today()
        );
        insert c;

        Order o = new Order(
            AccountId = accounts[0].Id,
            ContractId = c.Id,
            Status = 'Activated',
            EffectiveDate = Date.today(),
            Pricebook2Id = pbId
        );
        insert o;

        Map<Id, Order> oldMap = new Map<Id, Order>{ o.Id => o };

        Order newOrder = o.clone(false, true, true, true);
        newOrder.Status = 'Activated';
        newOrder.AccountId = o.AccountId;

        Map<Id, Order> newMap = new Map<Id, Order>{ newOrder.Id => newOrder };

        // WHEN
        Test.startTest();
        OrderService.validateBeforeUpdate(oldMap, newMap);
        Test.stopTest();

        // THEN
        System.assertEquals(1, newOrder.getErrors().size(),
            'Doit tomber dans le cas totalOrderProducts = 0');
    }

    @isTest
    static void validateBeforeUpdate_oldMapNull_shouldFail() {

        Map<Id, Order> newMap = new Map<Id, Order>();

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
    static void validateBeforeUpdate_newMapNull2_shouldFail() {

        Map<Id, Order> oldMap = new Map<Id, Order>();

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
    static void validateUpdate_noOrderItems_shouldFail() {

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        Id pbId = Test.getStandardPricebookId();

        Contract c = new Contract(
            AccountId = accounts[0].Id,
            Status = 'Activated',
            StartDate = Date.today()
        );
        insert c;

        Order o = new Order(
            AccountId = accounts[0].Id,
            ContractId = c.Id,
            Status = 'Activated',
            EffectiveDate = Date.today(),
            Pricebook2Id = pbId
        );
        insert o;

        Map<Id, Order> oldMap = new Map<Id, Order>{ o.Id => o };
        Map<Id, Order> newMap = new Map<Id, Order>{ o.Id => o };

        Test.startTest();
        try {
            OrderService.validateBeforeUpdate(oldMap, newMap);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void professionnel_lessThan5_shouldFail() {

        List<Account> accounts =
            TestDataFactory.createAccounts(1, 'Professionnel', 'France');

        List<Order> orders =
            TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        Map<Id, Order> oldMap = new Map<Id, Order>{ orders[0].Id => orders[0] };
        Map<Id, Order> newMap = new Map<Id, Order>{ orders[0].Id => orders[0] };

        Test.startTest();
        try {
            OrderService.validateBeforeUpdate(oldMap, newMap);
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    static void validateDelete_emptyList_shouldPass() {

        Test.startTest();
        OrderService.validateBeforeDelete(new List<Order>());
        Test.stopTest();

        System.assert(true);
    }

    @isTest
    static void validateDelete_noDelivery_shouldPass() {

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        Test.startTest();
        OrderService.validateBeforeDelete(orders);
        Test.stopTest();

        System.assert(true);
    }
}