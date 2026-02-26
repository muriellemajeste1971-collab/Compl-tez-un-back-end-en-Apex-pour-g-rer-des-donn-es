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
private class OtherTransportersTest {

    @isTest
    static void testGetOthersExcludesIds() {
        Account a = TestDataFactory.createAccount('Acct 3', 'Particulier');

        Transporteur__c t1 = TestDataFactory.createTransporter('O1', 'Particulier');
        Transporteur__c t2 = TestDataFactory.createTransporter('O2', 'Particulier');
        Transporteur__c t3 = TestDataFactory.createTransporter('O3', 'Particulier');

        Tarification__c cheapest = TestDataFactory.createTarification(t1, 'France', 5, 5);
        Tarification__c fastest = TestDataFactory.createTarification(t2, 'France', 10, 1);
        Tarification__c other = TestDataFactory.createTarification(t3, 'France', 15, 3);

        Test.startTest();
        List<Tarification__c> others = OtherTransporters.getOthers(cheapest.Id, fastest.Id, 'France', a.Customer_Type__c);
        Test.stopTest();

        System.assertEquals(1, others.size(), 'There should be one other transporter');
        System.assertEquals(other.Id, others[0].Id, 'Other should be the remaining tarif');
    }
}