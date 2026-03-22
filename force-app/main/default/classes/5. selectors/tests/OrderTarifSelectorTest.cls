@IsTest
public class OrderTarifSelectorTest {

    @IsTest
    static void testFastestAndCheapest() {
       // GIVEN
       Account a = TestDataFactory.createAccount();
       Contract c = TestDataFactory.createContract(a.Id);
       Order o = TestDataFactory.createOrder(a.Id, c.Id);
       Transporteur__c tr = TestDataFactory.createTransporteur('Particulier');
        
       List<Tarification__c> tarifs = TestDataFactory.createTarificationList();

       Tarification__c t1 = tarifs[0];
       Tarification__c t3 = tarifs[2];

        // WHEN
        Test.startTest();
        List<Tarification__c> result = TransporterSelector.getAll(o.Id, 'France', 'Particulier');
        Test.stopTest();

       System.debug('RESULT SIZE = ' + result.size());
       System.debug('RESULT LIST = ' + result);
        
        Tarification__c cheapest = result[1];
        Tarification__c fastest = result[0];
       

        // THEN
        
      
        System.assert(result.size() > 2);
        System.assertEquals(t3.Id, fastest.Id);
        System.assertEquals(t1.Id, cheapest.Id);
       
    }
     @isTest
    static void SingleactionGetAccountsByIds() {

        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'France');
   

        //WHEN
        Test.startTest();
         List<Id> accountIds = new List<Id>{a[0].Id};
         List<Account> result = AccountSelector.getAccountsByIds(accountIds);
        Test.stopTest();

        // THEN
        System.Assert.areEqual('Account 1', a[0].Name);
        System.Assert.areEqual('Particulier', a[0].Customer_Type__c);
        System.Assert.areEqual('France', a[0].ShippingCountry);
        System.Assert.areEqual(1, result.size());
    
    }

    @isTest
    static void BulkactionsGetAccountsByIds() {
        
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
    static void PositivebehaviorGetAccountsByIds() {
    
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
    static void NegativebehaviorGetAccountsByIds() {
     
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
    static void RestricteduserGetAccountsByIds() {

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