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
private class OrderItemAggregatorTest {

@isTest
static void singleAction() {

    // GIVEN
    List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
    List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

    // WHEN
    Test.startTest();
    Map<Id, Decimal> result =
        OrderItemAggregator.TotalQuantityByOrder(
            new Set<Id>{ orders[0].Id }
        );
    Test.stopTest();

    // THEN
    System.assert(result.containsKey(orders[0].Id));
}

@isTest
static void bulkActions() {

    // GIVEN
    List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) accountIds.add(acc.Id);

    List<Order> orders = TestDataFactory.createOrders(200, 3, accountIds);

    Set<Id> orderIds = new Set<Id>();
    for (Order o : orders) orderIds.add(o.Id);

    // WHEN
    Test.startTest();
    Map<Id, Decimal> result =
        OrderItemAggregator.TotalQuantityByOrder(orderIds);
    Test.stopTest();

    // THEN
    System.assertEquals(200, result.size());
}

@isTest
static void positiveBehaviour() {

    // GIVEN
    List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
    List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

    // WHEN
    Test.startTest();
    Map<Id, Decimal> result =
        OrderItemAggregator.TotalQuantityByOrder(
            new Set<Id>{ orders[0].Id }
        );
    Test.stopTest();

    // THEN
    System.assert(result.get(orders[0].Id) > 0);
}

@isTest
static void negativeBehaviour_noOrderItems() {

    // GIVEN
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

    // PAS de OrderItems

    // WHEN
    Test.startTest();
    Map<Id, Decimal> result =
        OrderItemAggregator.TotalQuantityByOrder(
            new Set<Id>{ o.Id }
        );
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

    List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
    List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });

    // WHEN
    Test.startTest();
    Map<Id, Decimal> result;

    System.runAs(restrictedUser) {
        result =
            OrderItemAggregator.TotalQuantityByOrder(
                new Set<Id>{ orders[0].Id }
            );
    }
    Test.stopTest();

    // THEN
    System.assert(
        result.isEmpty() || result.get(orders[0].Id) == null
    );
}
}