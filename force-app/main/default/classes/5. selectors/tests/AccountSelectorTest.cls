@isTest
private class AccountSelectorTest {

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
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'Suisse');
        
        // WHEN
        Test.startTest();
        System.runAs(restrictedUser) {
        List<Account> result = AccountSelector.getAccountsByIds(new List<Id>{a[0].Id});
        Test.stopTest();

        // THEN
        System.assertEquals(0, result.size());
        }
    }
}

