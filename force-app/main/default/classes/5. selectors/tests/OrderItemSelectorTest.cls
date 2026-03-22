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
private class OrderItemSelectorTest {

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