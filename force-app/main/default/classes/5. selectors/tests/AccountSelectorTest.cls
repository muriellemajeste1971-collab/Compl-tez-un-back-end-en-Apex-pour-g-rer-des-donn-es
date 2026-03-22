@isTest
private class AccountSelectorTest {

    @isTest
    static void SingleactionGetAccountsByIds() {

        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        
            // Build List<Id>
            List<Id> accountIds = new List<Id>();
                for (Account acc : a) {     
                    accountIds.add(acc.Id);
                }

        //WHEN
        Test.startTest();
         List<Account> result = AccountSelector.getAccountsByIds(accountIds);
        Test.stopTest();

        // THEN
        System.Assert.areEqual('Account 1', result[0].Name);
        System.Assert.areEqual('Particulier', result[0].Customer_Type__c);
        System.Assert.areEqual('FR', result[0].ShippingCountry);
        System.Assert.areEqual(1, result.size());
    
    }

    @isTest
    static void BulkactionsGetAccountsByIds() {
        
        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(200, 'Professionnel', 'Luxembourg');
        
            // Build List<Id>
            List<Id> accountIds = new List<Id>();
                for (Account acc : a) {
                    accountIds.add(acc.Id);
                }
       
       // WHEN
        Test.startTest();
        List<Account> result = AccountSelector.getAccountsByIds(accountIds);
        Test.stopTest();

        // THEN
        System.Assert.areEqual('Account 1', result[0].Name);
        System.Assert.areEqual('Professionnel', result[0].Customer_Type__c);
        System.Assert.areEqual('LU', result[0].ShippingCountry);
        System.Assert.areEqual('Account 200', result[199].Name);
        System.Assert.areEqual('Professionnel', result[199].Customer_Type__c);
        System.Assert.areEqual('LU', result[199].ShippingCountry);
        System.Assert.areEqual(200, result.size());
    }

    @isTest
    static void PositivebehaviorGetAccountsByIds() {
    
        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(10, 'Professionnel', 'France');
        
            // Build List<Id>
            List<Id> accountIds = new List<Id>();
                for (Account acc : a) {
                    accountIds.add(acc.Id);
                }
       
       // WHEN
        Test.startTest();
        List<Account> result = AccountSelector.getAccountsByIds(accountIds);
        Test.stopTest();

        // THEN
        System.Assert.areEqual('Account 1', result[0].Name);
        System.Assert.areEqual('Professionnel', result[0].Customer_Type__c);
        System.Assert.areEqual('FR', result[0].ShippingCountry);
        System.Assert.areEqual('Account 10', result[9].Name);
        System.Assert.areEqual('Professionnel', result[9].Customer_Type__c);
        System.Assert.areEqual('FR', result[9].ShippingCountry);
        System.Assert.areEqual(10, result.size());
    }

    @isTest
    static void NegativebehaviorGetAccountsByIds() {
     
        // GIVEN
         List<Id> accountIds = new List<Id>(); // List<Id>.size = 0 vide

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
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'Suisse');
        
            // Build List<Id>
            List<Id> accountIds = new List<Id>();
                for (Account acc : a) {
                    accountIds.add(acc.Id);
                }

         // WHEN
        Test.startTest();
            System.runAs(restrictedUser) {
                try {
                    AccountSelector.getAccountsByIds(accountIds);

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

