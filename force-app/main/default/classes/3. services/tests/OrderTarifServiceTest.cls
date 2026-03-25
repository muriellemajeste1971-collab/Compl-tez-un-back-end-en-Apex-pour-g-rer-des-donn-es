/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
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

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(5, 'Particulier', 'France');

        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        List<Order> orders = TestDataFactory.createOrders(5, 3, accountIds);

        TestDataFactory.createTarifs();
        TestDataFactory.createDeliveryOrders(accounts, orders);

        Set<Id> orderIds = new Set<Id>();
        for (Order o : orders) {
            orderIds.add(o.Id);
        }

        // WHEN
        Test.startTest();
        Map<Id, List<Tarification__c>> result =
            OrderTarifService.getByOrderIds(orderIds);
        Test.stopTest();

        // THEN
        System.assertEquals(5, result.size());
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
    static void getByOrderIds_noTarif_shouldReturnNull() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

        // PAS de tarif / livraison

        // WHEN
        Test.startTest();
        List<Tarification__c> result =
            OrderTarifService.getByOrderIds(orders[0].Id);
        Test.stopTest();

        // THEN
        System.assertEquals(null, result);
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