
@isTest
private class OrderItemAggregatorTest {

@isTest
static void test01_singleAction() {

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
static void test02_bulkActions() {

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
static void test03_positiveBehaviour() {

    // GIVEN
    List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
    List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ accounts[0].Id });
    orders[0].Status = 'Activated';
    update orders;

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
static void test04_negativeBehaviour() {
    // GIVEN
    List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');

    // Prepare order ids set in outer scope so it's visible in catch
    Set<Id> oIds = new Set<Id>();

    // WHEN
    Test.startTest();
    try {
        List<Order> orders = TestDataFactory.createOrders(1, 0, new List<Id>{ accounts[0].Id });
        for (Order o : orders) oIds.add(o.Id);
    } catch (DmlException e) {
        Map<Id, Decimal> result = OrderItemAggregator.TotalQuantityByOrder(oIds);
        System.Assert.isTrue(e.getMessage().contains('La commande doit contenir au moins 3 produits'));
        System.assertEquals(0, result.size());
    }
    Test.stopTest();
}
   

@isTest
static void test05_restrictedUser() {

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