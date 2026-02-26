
@isTest
private class CheapestTransporterTest {

    @isTest
    static void testGetCheapest() {
        Account a = TestDataFactory.createAccount('Acct 1', 'Particulier');

        Transporteur__c t1 = TestDataFactory.createTransporter('T1', 'Particulier');
        Transporteur__c t2 = TestDataFactory.createTransporter('T2', 'Particulier');

        // t1 is cheaper than t2
        Tarification__c tf1 = TestDataFactory.createTarification(t1, 'France', 10, 5);
        Tarification__c tf2 = TestDataFactory.createTarification(t2, 'France', 20, 3);

        Test.startTest();
        Tarification__c cheapest = CheapestTransporter.getCheapest('France', a.Customer_Type__c);
        Test.stopTest();

        System.assertEquals(tf1.Id, cheapest.Id, 'Cheapest should be tf1');
    }
}