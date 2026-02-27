
@isTest
private class TransporterOrchestratorTest {

    @isTest
    static void testCheapestAndFastestDifferent() {
        Transporteur__c t1 = TestDataFactory.createTransporter('TO1', 'Professionnel');
        Transporteur__c t2 = TestDataFactory.createTransporter('TO2', 'Professionnel');
        Transporteur__c t3 = TestDataFactory.createTransporter('TO3', 'Professionnel');

        // t1 cheapest, t2 fastest
        Tarification__c tf1 = TestDataFactory.createTarification(t1, 'France', 5, 5);
        Tarification__c tf2 = TestDataFactory.createTarification(t2, 'France', 15, 1);
        Tarification__c tf3 = TestDataFactory.createTarification(t3, 'France', 25, 3);

        Order o = TestDataFactory.createOrder('Acct 4', Date.today(), 'Draft');

        Test.startTest();
        List<Tarification__c> result = TransporterOrchestrator.getAllTransporters(o.Id);
        Test.stopTest();

        // fastest should be first, cheapest second
        System.assertEquals(tf2.Id, result[0].Id, 'First should be fastest');
        System.assertEquals(tf1.Id, result[1].Id, 'Second should be cheapest');
        // others should contain tf3
        Boolean found = false;
        for (Integer i=2;i<result.size();i++) if (result[i].Id == tf3.Id) found = true;
        System.assert(found, 'Result should contain the other transporter');
    }

    @isTest static void testCheapestAndFastestSame() {
        Transporteur__c t1 = TestDataFactory.createTransporter('TS1', 'Particulier');
        Transporteur__c t2 = TestDataFactory.createTransporter('TS2', 'Particulier');

        // Make t1 both cheapest and fastest
        Tarification__c tf1 = TestDataFactory.createTarification(t1, 'France', 5, 1);
        Tarification__c tf2 = TestDataFactory.createTarification(t2, 'France', 15, 3);

        Order o = TestDataFactory.createOrder('Acct 5', Date.today(), 'Draft');

        Test.startTest();
        List<Tarification__c> result = TransporterOrchestrator.getAllTransporters(o.Id);
        Test.stopTest();

        // when same, only one instance of tf1 should be added before others
        System.assertEquals(tf1.Id, result[0].Id, 'First should be tf1');
        // second position should be tf2 (the only other)
        System.assertEquals(tf2.Id, result[1].Id, 'Second should be tf2');
    }
}