@isTest
private class TransporterOrchestratorTest {

    @isTest
    static void testCheapestAndFastestDifferent() {
		Account a = TestDataFactory.createAccount();
        Contract c = TestDataFactory.createContract(a.Id);
     	Order o = TestDataFactory.createOrder(a.Id,c.Id);
        Transporteur__c tr = TestDataFactory.createTransporteur('Particulier');
        List<Tarification__c> liste = TestDataFactory.createTarificationList(); 
        
       	Tarification__c t1 = liste[0];
        Tarification__c t2 = liste[1];
       	Tarification__c t3 = liste[2];

        Test.startTest();
        List<Tarification__c> result = TransporterOrchestrator.getAllTransporters(o.Id);
        Test.stopTest();
        
        Tarification__c fastest = result[0];
        Tarification__c cheapest = result[1];
        Tarification__c last = result[2];
        

        // fastest should be first, cheapest second
        System.assertEquals(t3.Id, fastest.Id, 'First should be fastest');
        System.assertEquals(t1.Id, cheapest.Id, 'Second should be cheapest');
		System.assertEquals(t2.Id, last.Id, 'Other');
        System.assertEquals(3,result.size(), 'remonte bien les 3 tarifs');
        
    
    }
}