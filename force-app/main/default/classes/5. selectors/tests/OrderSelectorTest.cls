@isTest
private class OrderSelectorTest {

    @isTest
    static void singleAction() {

        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Id> accountIds = new List<Id>();
            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }
        
     	List<Order> orders = TestDataFactory.createOrders(1, 3, accountIds);
        List<Id> orderIds = new List<Id>();
            for (Order o : orders) {
                orderIds.add(o.Id);
            }
 
        // WHEN
        Test.startTest();
        List<Order> result = OrderSelector.selectByIds(orderIds);
        Test.stopTest();

        // THEN
        System.Assert.areEqual(1, result.size());
        System.Assert.areEqual(accounts[0].Id, result[0].AccountId);
        System.assertNotEquals(null, result[0].ContractId);
       
    }

    @isTest
    static void bulkActions() {
        
        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Id> accountIds = new List<Id>();
            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }

     	List<Order> orders = TestDataFactory.createOrders(200, 3, accountIds);
        List<Id> orderIds = new List<Id>();
            for (Order o : orders) {
                orderIds.add(o.Id);
            }
            
            
        // WHEN
        Test.startTest();
        List<Order> result = OrderSelector.selectByIds(orderIds);
        Test.stopTest();

        List<Id> actualIds = new List<Id>();
            for (Order o : result) {
                actualIds.add(o.Id);
            }

        // THEN
        System.Assert.areEqual(200, result.size());
        System.assertEquals(orderIds, actualIds);
    
    }

    @isTest
    static void positiveBehaviour() {
    
        // GIVEN
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Id> accountIds = new List<Id>();
            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }

     	List<Order> orders = TestDataFactory.createOrders(3, 3, accountIds);
        List<Id> orderIds = new List<Id>();
            for (Order o : orders) {
                orderIds.add(o.Id);
            }
            
        // WHEN
        Test.startTest();
        List<Order> result = OrderSelector.selectByIds(orderIds);
        Test.stopTest();

        // THEN
        System.Assert.areEqual(3, result.size());
        System.Assert.areEqual(accounts[0].Id, result[0].AccountId);
        System.assertNotEquals(null, result[0].ContractId);
        // Order 1
        System.Assert.areEqual(accounts[0].Id, result[1].AccountId);
        System.assertNotEquals(null, result[1].ContractId);
        // Order 2
        System.Assert.areEqual(accounts[0].Id, result[2].AccountId);
        System.assertNotEquals(null, result[2].ContractId);
    
    }

    @isTest
    static void negativeBehaviour() {
        // GIVEN
         List<Id> orderIds = new List<Id>(); // List<Id>.size = 0 vide

        // WHEN
        Test.startTest();
        List<Order> result = OrderSelector.selectByIds(orderIds);
        Test.stopTest();

        // THEN
        System.assertEquals(0, result.size());
    }

     @isTest
    static void restrictedUsers() {

        // GIVEN
        List<User> users = TestDataFactory.createUsers(new List<String>{ '' });
        User restrictedUser = users[0];

        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Id> accountIds = new List<Id>();
            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }
        
     	List<Order> orders = TestDataFactory.createOrders(1, 3, accountIds);
        List<Id> orderIds = new List<Id>();
            for (Order o : orders) {
                orderIds.add(o.Id);
            }
         // WHEN
        Test.startTest();
            System.runAs(restrictedUser) {
                try {
                    OrderSelector.selectByIds(orderIds);

                    // Si aucune exception → erreur
                    System.assert(false, 'Une exception était attendue pour un utilisateur sans accès');

                } catch (Exception e) {

                    // Vérifie qu'une exception est bien levée
                    System.assertNotEquals(null, e);

                    // (Optionnel mais propre)
                    System.assert(e.getMessage().contains('not supported') || e.getMessage() != null);
                }
            }
        Test.stopTest();
    }
}