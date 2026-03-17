@isTest
private class OrderTriggerTest {


     @IsTest
    static void testBeforeDelete() {
           // Given
        Account a = TestDataFactory.createAccount();
        Contract c = TestDataFactory.createContract(a.Id);
     	Order o = TestDataFactory.createOrder(a.Id,c.Id);
        Transporteur__c tr = TestDataFactory.createTransporteur('Particulier');
		List<Tarification__c> liste = TestDataFactory.createTarificationList();
        List<Tarification__c> result = TransporterOrchestrator.getAllTransporters(o.Id);
     
        Tarification__c fastest = result[0];
        Tarification__c cheapest = result[1];
        Tarification__c last = result[2];
     
        Id createdLivId = OrderService.createLivraison(o.Id, fastest.Id);
        
        o.Status = 'Draft';
        update o;

        // Test
        Test.startTest();
        delete o;
        Test.stopTest();

       Order ord = [
                    SELECT Id, IsDeleted 
                    FROM Order 
                    WHERE Id = :o.Id 
                    ALL ROWS
                ];

        System.assertEquals(true, ord.IsDeleted, 'L’Order doit être supprimé');


        // Verify : les livraisons liées n’existent plus
        List<Livraison__c> livs = [
        SELECT Id FROM Livraison__c WHERE Order__c = :o.Id
         ];
        System.assertEquals(0, livs.size(), 'Aucune livraison ne doit exister après suppression automatique');
    }

}