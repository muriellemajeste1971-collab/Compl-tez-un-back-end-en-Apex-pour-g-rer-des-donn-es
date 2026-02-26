
@isTest
private class FastestTransporterTest {

    @isTest
    static void testGetFastest() {
        Account a = TestDataFactory.createAccount('Acct 2', 'Professionnel');

        Transporteur__c t1 = TestDataFactory.createTransporter('TF1', 'Professionnel');
        Transporteur__c t2 = TestDataFactory.createTransporter('TF2', 'Professionnel');

        // t2 is faster than t1
        Tarification__c tf1 = TestDataFactory.createTarification(t1, 'France', 10, 5);
        Tarification__c tf2 = TestDataFactory.createTarification(t2, 'France', 20, 2);

        Test.startTest();
        Tarification__c fastest = FastestTransporter.getFastest('France', a.Customer_Type__c);
        Test.stopTest();

        System.assertEquals(tf2.Id, fastest.Id, 'Fastest should be tf2');
    }
}