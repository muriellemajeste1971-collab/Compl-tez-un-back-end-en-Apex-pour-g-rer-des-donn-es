@IsTest
public class DeliveryOrderServiceTest {

    // =========================================
    // 1. SINGLE ACTION
    // =========================================
    @isTest
    static void test01_singleAction() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        orders[0].Status = 'Activated';
        update orders;

        List<Tarification__c> tarifs = TestDataFactory.createTarifs();

        Map<Id, Id> selectedTarifIds = new Map<Id, Id>{
            orders[0].Id => tarifs[0].Id
        };

        // WHEN
        Test.startTest();
        Map<Id, Id> result =
            DeliveryOrderService.createByOrderIds(
                new List<Id>{ orders[0].Id },
                selectedTarifIds
            );
        Test.stopTest();

        // THEN
        System.assertEquals(1, result.size());
    }

    // =========================================
    // 2. BULK ACTIONS
    // =========================================
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
            for (Order o : orders) {
                oldMap.put(o.Id, o);
            }

        Map<Id, Order> newMap = new Map<Id, Order>();
            for (Order o : orders) {
                Order newOrder = new Order(
                    Id = o.Id,
                    Status = 'Activated',
                    AccountId = null
                );
                newMap.put(o.Id, newOrder);
            }
            
        update newMap.values();

        List<Tarification__c> tarifs = TestDataFactory.createTarifs();

        Map<Id, Id> selectedTarifIds = new Map<Id, Id>();
            for (Order o : orders) {
                selectedTarifIds.put(o.Id, tarifs[0].Id);
            }

        List<Id> orderIds = new List<Id>();
            for (Order o : orders) {
                orderIds.add(o.Id);
            }

        // WHEN
        Test.startTest();
        Map<Id, Id> result =
            DeliveryOrderService.createByOrderIds(orderIds, selectedTarifIds);
        Test.stopTest();

        // THEN
        System.assertEquals(200, result.size());
    }

    // =========================================
    // 3. POSITIVE BEHAVIOUR
    // =========================================
    @isTest
    static void test03_positiveBehaviour() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(2, 'Particulier', 'France');
        List<Id> accountIds = new List<Id>();
            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }

        List<Order> orders = TestDataFactory.createOrders(2, 3, accountIds);
            for (Order o : orders) {
                o.Status = 'Activated';
            }
        update orders;

        List<Tarification__c> tarifs = TestDataFactory.createTarifs();

        Map<Id, Id> selectedTarifIds = new Map<Id, Id>();
            for (Order o : orders) {
                selectedTarifIds.put(o.Id, tarifs[0].Id);
            }

        // WHEN
        Test.startTest();
        Map<Id, Id> created =
            DeliveryOrderService.createByOrderIds(
                new List<Id>{ orders[0].Id, orders[1].Id },
                selectedTarifIds
            );

        Map<Id, List<Livraison__c>> fetched =
            DeliveryOrderService.getByOrderIds(new List<Id>{ orders[0].Id, orders[1].Id });
        Test.stopTest();

        // THEN
        System.assertEquals(2, created.size());
        System.assertEquals(2, fetched.size());
    }

    // =========================================
    // 4. NEGATIVE BEHAVIOUR
    // =========================================
    @isTest
    static void test04_negativeBehaviour() {

        // GIVEN
        List<Id> orderIds = new List<Id>();
        Map<Id, Id> selectedTarifIds = new Map<Id, Id>();

        // WHEN
        Test.startTest();
        try {
            DeliveryOrderService.createByOrderIds(orderIds, selectedTarifIds);
            System.assert(false, 'Une exception était attendue');
        } catch (DeliveryOrderServiceException e) {
            System.assertEquals('Delivery Order not specified.', e.getMessage());
        }
        Test.stopTest();
    }

    // =========================================
    // 5. RESTRICTED USER
    // =========================================
    @isTest
    static void test05_restrictedUser() {

        // GIVEN
        List<User> users = TestDataFactory.createUsers(
            new List<String>{ 'Chatter Free User' }
        );
        User restrictedUser = users[0];

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        orders[0].Status = 'Activated';
        update orders;
        
        List<Tarification__c> tarifs = TestDataFactory.createTarifs();

        Map<Id, Id> selectedTarifIds = new Map<Id, Id>{
            orders[0].Id => tarifs[0].Id
        };

        // WHEN
        Test.startTest();
        System.runAs(restrictedUser) {
            Map<Id, Id> result =
                DeliveryOrderService.createByOrderIds(
                    new List<Id>{ orders[0].Id },
                    selectedTarifIds
                );

            // THEN
            System.assertEquals(0, result.size(),
                'User restreint ne doit rien créer ou voir');
        }
        Test.stopTest();
    }

    // =========================================
    // 6. UPDATE (COUVERTURE)
    // =========================================
    @isTest
    static void test06_updateByIds_shouldWork() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        orders[0].Status = 'Activated';
        update orders;

        List<Tarification__c> tarifs = TestDataFactory.createTarifs();

        // création initiale
        Map<Id, Id> selectedTarifIds = new Map<Id, Id>{
            orders[0].Id => tarifs[0].Id
        };

        Map<Id, Id> created =
            DeliveryOrderService.createByOrderIds(
                new List<Id>{ orders[0].Id },
                selectedTarifIds
            );

        Id deliveryId = created.values()[0];

        // nouveau tarif
        Map<Id, Id> newTarifIds = new Map<Id, Id>{
            deliveryId => tarifs[0].Id
        };

        // WHEN
        Test.startTest();
        Map<Id, Id> updated =
            DeliveryOrderService.updateByIds(
                new List<Id>{ deliveryId },
                newTarifIds
            );
        Test.stopTest();

        // THEN
        System.assertEquals(1, updated.size());
    }

    @isTest
    static void test07_updateByIds_missingTarif_shouldFail() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        orders[0].Status = 'Activated';
        update orders;

        List<Tarification__c> tarifs = TestDataFactory.createTarifs();

        Map<Id, Id> selectedTarifIds = new Map<Id, Id>{
            orders[0].Id => tarifs[0].Id
        };

        Map<Id, Id> created =
            DeliveryOrderService.createByOrderIds(
                new List<Id>{ orders[0].Id },
                selectedTarifIds
            );

        Id deliveryId = created.values()[0];

        Map<Id, Id> newTarifIds = new Map<Id, Id>(); // vide

        // WHEN
        Test.startTest();
        try {
            DeliveryOrderService.updateByIds(
                new List<Id>{ deliveryId },
                newTarifIds
            );
            System.assert(false, 'Une exception était attendue');
        } catch (Exception e) {
            System.assertNotEquals(null, e);
            System.assert(
                e instanceof AuraHandledException,
                'Le type d’exception attendu est AuraHandledException, reçu : ' + e.getTypeName()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void test08_negativeBehaviour_selectedTarifEmpty_shouldFail() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
        orders[0].status = 'Activated';
        update orders;

        List<Id> orderIds = new List<Id>{ orders[0].Id };

        Map<Id, Id> selectedTarifIds = new Map<Id, Id>(); // ⚠️ vide

        // WHEN
        Test.startTest();
        try {
            DeliveryOrderService.createByOrderIds(orderIds, selectedTarifIds);
            System.assert(false, 'Une exception était attendue');
        } catch (DeliveryOrderServiceException e) {
            System.assertEquals('Selected Tarif not specified.', e.getMessage());
        }
        Test.stopTest();
    }

    
}