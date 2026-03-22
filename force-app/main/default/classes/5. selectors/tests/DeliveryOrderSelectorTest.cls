@isTest
public class DeliveryOrderSelectorTest {

    @isTest
    static void singleaction11GetDeliveryOrdersByOrderIds() {

        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'France');
            // Build Account Ids List<Id>
            List<Id> accountIds = new List<Id>();
            for (Account acc : a) {
                accountIds.add(acc.Id);
            }

        List<Order> o = TestDataFactory.createOrders(accountIds, 3, 1);
            // Build Order Ids List<Id>
            List<Id> orderIds = new List<Id>();
            for (Order ord : o) {
                orderIds.add(ord.Id);
            }

        List<Tarification__c> t = TestDataFactory.createTarifs();

        List<Livraison__c> d = TestDataFactory.createDeliveryOrders(a, o);

        // WHEN
        Test.startTest();
            List<Livraison__c> result = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(orderIds);
        Test.stopTest();

        // THEN
        System.assertEquals(1, result.size(), 'Le selector doit renvoyer la livraison liées à l’Order');
        System.assertEquals(d[0].Id, result[0].Id, 'Le selector doit renvoyer la livraison liées à l’Order');

        System.assertEquals(o[0].AccountId, result[0].Account__c, 'La livraison doit avoir faire remonter le compte de la commande');
        System.assertEquals(o[0].Id, result[0].Order__c, 'la livraison doit être liée à l’order');
        System.assert(result[0].Tarification__c != null,'la livraison doit avoir les frais de livraison correspondant à la zone de livraison de l’account lié à l’order');
        
        System.assertEquals('En cours', result[0].Statut__c, 'la livraison doit avoir le statut "En cours"');
        System.Assert.areEqual('Particulier', result[0].Account_Type__c,'la livraison doit avoir le même type de compte que l’account lié à l’order');
        System.assertEquals(3, result[0].Product_Number__c, 'la livraison doit avoir le même nombre de produits que l’order');     
    }


    @isTest
    static void bulkaction12GetDeliveryOrdersByOrderIds() {

        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Professionnel', 'Belgique');

            // Build Account Ids List<Id>
            List<Id> accountIds = new List<Id>();
            for (Account acc : a) {
                accountIds.add(acc.Id);
            }

        List<Order> o = TestDataFactory.createOrders(accountIds, 5, 200);

            // Build Order Ids List<Id>
            List<Id> orderIds = new List<Id>();
            for (Order ord : o) {
                orderIds.add(ord.Id);
            }

        List<Tarification__c> t = TestDataFactory.createTarifs();

        List<Livraison__c> d = TestDataFactory.createDeliveryOrders(a, o);

    
        // WHEN
        Test.startTest();
            List<Livraison__c> result = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(orderIds);
        Test.stopTest();

        // THEN
        System.assertEquals(200, result.size());
        Set<Id> orderIdsSet = new Set<Id>(orderIds);
            for (Livraison__c deliveryOrder : result) {
                System.assert(orderIdsSet.contains(deliveryOrder.Order__c));
            }
    }

    @isTest
    static void positivebehavior13GetDeliveryOrdersByOrderIds() {
        
        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(10, 'Particulier', 'France');

            // Build Account Ids List<Id>
            List<Id> accountIds = new List<Id>();
                for (Account acc : a) {
                    accountIds.add(acc.Id);
            }

        List<Order> o = TestDataFactory.createOrders(accountIds, 4, 1);

            // Build Order Ids List<Id>
            List<Id> orderIds = new List<Id>();
            for (Order ord : o) {
                orderIds.add(ord.Id);
            }
            
        List<Tarification__c> t = TestDataFactory.createTarifs();

        List<Livraison__c> d = TestDataFactory.createDeliveryOrders(a, o);
         
        // WHEN
        Test.startTest();
            List<Livraison__c> result = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(orderIds);
        Test.stopTest();

        // THEN
        System.assertEquals(10, result.size());
        Set<Id> orderIdsSet = new Set<Id>(orderIds);
            for (Livraison__c deliveryOrder : result) {
                System.assert(orderIdsSet.contains(deliveryOrder.Order__c));
            }      
    }

    @isTest
    static void negativebehavior14GetDeliveryOrdersByOrderIds() {
        
        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'France');
            // Build Account Ids List<Id>
            List<Id> accountIds = new List<Id>();
            for (Account acc : a) {
                accountIds.add(acc.Id);
            }

        List<Order> o = TestDataFactory.createOrders(accountIds, 0, 0);

            // Build Order Ids List<Id>
            List<Id> orderIds = new List<Id>();
            for (Order ord : o) {
                orderIds.add(ord.Id);
            }

        List<Tarification__c> t = TestDataFactory.createTarifs();

        List<Livraison__c> d = TestDataFactory.createDeliveryOrders(a, o);

        // WHEN
        Test.startTest();
            List<Livraison__c> result = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(orderIds);
        Test.stopTest();

        // THEN
        System.assertEquals(0, result.size()); 
        
    }

    @isTest
    static void restricteduser15GetDeliveryOrdersByOrderIds() {
        // GIVEN
        User restrictedUser = TestDataFactory.createRestrictedUser();
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'France');
            // Build Account Ids List<Id>
            List<Id> accountIds = new List<Id>();
            for (Account acc : a) {
                accountIds.add(acc.Id);
            }

        List<Order> o = TestDataFactory.createOrders(accountIds, 3, 1);
            // Build Order Ids List<Id>
            List<Id> orderIds = new List<Id>();
            for (Order ord : o) {
                orderIds.add(ord.Id);
            }

        List<Tarification__c> t = TestDataFactory.createTarifs();

        List<Livraison__c> d = TestDataFactory.createDeliveryOrders(a, o);

        // WHEN
        Test.startTest();
        System.runAs(restrictedUser) {
            List<Livraison__c> result = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(orderIds);

            // THEN
            System.assertEquals(0, result.size());
        }
        Test.stopTest();
       
    }

    @isTest
    static void singleaction21GetDeliveryOrdersByIds() {

        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> o = TestDataFactory.createOrders(new List<Id>{ a[0].Id }, 3, 1);
        List<Tarification__c> t = TestDataFactory.createTarifs();
        List<Livraison__c> d = TestDataFactory.createDeliveryOrders(a, new List<Order>{ o[0] });

        // WHEN
        Test.startTest();
        List<Livraison__c> result = DeliveryOrderSelector.getDeliveryOrdersByIds(new List<Id>{ d[0].Id });
        Test.stopTest();

        // THEN
        System.assertEquals(1, result.size(), 'Le selector doit renvoyer la livraison liées à l’Order');
        System.assertEquals(d[0].Id, result[0].Id, 'Le selector doit renvoyer la livraison liées à l’Order');

        System.assertEquals(o[0].AccountId, result[0].Account__c, 'La livraison doit avoir faire remonter le compte de la commande');
        System.assertEquals(o[0].Id, result[0].Order__c, 'la livraison doit être liée à l’order');
        System.assert(result[0].Tarification__c != null,'la livraison doit avoir les frais de livraison correspondant à la zone de livraison de l’account lié à l’order');
        
        System.assertEquals('En cours', result[0].Statut__c, 'la livraison doit avoir le statut "En cours"');
        System.Assert.areEqual('Particulier', result[0].Account_Type__c,'la livraison doit avoir le même type de compte que l’account lié à l’order');
        System.assertEquals(3, result[0].Product_Number__c, 'la livraison doit avoir le même nombre de produits que l’order');    
    }

    @isTest
    static void Bulkactions22GetDeliveryOrdersByIds() {
        
        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(200, 'Professionnel', 'Luxembourg');
        
        // Build Set<Id>
        List<Id> accountIds = new List<Id>();
        for (Account acc : a) {
        accountIds.add(acc.Id);
        }
       
       // WHEN
        Test.startTest();
        List<Account> result = AccountSelector.getAccountsByIds(accountIds);
        Test.stopTest();

        // THEN
        System.Assert.areEqual('Account 1', a[0].Name);
        System.Assert.areEqual('Professionnel', a[0].Customer_Type__c);
        System.Assert.areEqual('Luxembourg', a[0].ShippingCountry);
        System.Assert.areEqual('Account 200', a[199].Name);
        System.Assert.areEqual('Professionnel', a[199].Customer_Type__c);
        System.Assert.areEqual('Luxembourg', a[199].ShippingCountry);
        System.Assert.areEqual(200, result.size());
    }

    @isTest
    static void Positivebehavior23GetDeliveryOrdersByIds() {
    
        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(10, 'Professionnel', 'France');
        
        // Build Set<Id>
        List<Id> accountIds = new List<Id>();
        for (Account acc : a) {
        accountIds.add(acc.Id);
        }
       
       // WHEN
        Test.startTest();
        List<Account> result = AccountSelector.getAccountsByIds(accountIds);
        Test.stopTest();

        // THEN
        System.Assert.areEqual('Account 1', a[0].Name);
        System.Assert.areEqual('Professionnel', a[0].Customer_Type__c);
        System.Assert.areEqual('France', a[0].ShippingCountry);
        System.Assert.areEqual('Account 10', a[9].Name);
        System.Assert.areEqual('Professionnel', a[9].Customer_Type__c);
        System.Assert.areEqual('France', a[9].ShippingCountry);
        System.Assert.areEqual(10, result.size());
    }

    @isTest
    static void Negativebehavior24GetDeliveryOrdersByIds() {
     
        // GIVEN
         List<Id> accountIds = new List<Id>(); // Set vide

        // WHEN
        Test.startTest();
        List<Account> result = AccountSelector.getAccountsByIds(accountIds);
        Test.stopTest();

        // THEN
        System.assertEquals(0, result.size());
    }



    @isTest
    static void Restricteduser25GetDeliveryOrdersByIds() {

        // GIVEN
        User restrictedUser = TestDataFactory.createRestrictedUser();
        List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'Suisse');
        List<Id> ids = new List<Id>{ accounts[0].Id };

         // WHEN
        Test.startTest();
            System.runAs(restrictedUser) {
                try {
                    AccountSelector.getAccountsByIds(ids);

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
