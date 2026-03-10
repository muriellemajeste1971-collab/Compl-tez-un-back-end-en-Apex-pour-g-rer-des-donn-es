@IsTest
public class OrderServiceTest {


    /**
     * Création d'une livraison avec des données valides
     */
    @IsTest
    static void testCreateLivraison() {
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
       

        // When
        Test.startTest();
        Id bdlId = OrderService.createLivraison(o.Id, fastest.Id);
        Test.stopTest();

        // then
        

        System.assert(bdlId != null, 'La livraison ID ne doit pas être null');
        Livraison__c bdl = [SELECT Id, Order__c, Tarification__c, Account__c, Statut__c, Name 
                             FROM Livraison__c 
                             WHERE Id = :bdlId];
        
        System.assertEquals(o.Id, bdl.Order__c, 'La livraison doit être liée au bon Order');
        System.assertEquals(fastest.Id, bdl.Tarification__c, 'La tarification doit être correcte');
        System.assertEquals(a.Id, bdl.Account__c, 'Le compte doit être associé');
        System.assertEquals('En cours', bdl.Statut__c, 'Le statut doit être "En cours"');
        System.assert(bdl.Name.contains(o.ShippingCountry), 'Le Name doit contenir le pays');
		System.assert(bdl.Name.contains(a.Name), 'Le Name doit contenir le nom du compte');

    	Integer countbdl = [
        SELECT COUNT() FROM Livraison__c WHERE Order__c = :o.Id
    	];
    	System.assertEquals(1, countbdl, 'Il doit y avoir exactement une livraison');
    }
    
    
    /**
     * Récupération d'une livraison 
     */
    
    @IsTest
    static void testgetLivraisonByOrder() {
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

        // When
        Test.startTest();
        Livraison__c liv = OrderService.getLivraisonByOrder(o.Id);
        Test.stopTest();

        // then
	
		System.assertNotEquals(null, liv, 'La livraison ne doit pas être null');
    	System.assertEquals(createdLivId, liv.Id, 'La livraison retournée doit être la même');
    
    }
    

    /**
     * Test positive : Mise à jour d'une livraison avec nouvelle tarification
     */
    @IsTest
    static void testUpdateLivraison() {
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
        

        // Test
        Test.startTest();
        Id newLivId = OrderService.updateLivraison(createdLivId, cheapest.Id);
        Test.stopTest();

        // Verify
        System.assertNotEquals(createdLivId, newLivId, 'Une nouvelle livraison doit être créée');
        Livraison__c newLiv = [SELECT Id, Tarification__c, Statut__c FROM Livraison__c WHERE Id = :newLivId];
        System.assertEquals(cheapest.Id, newLiv.Tarification__c, 'La nouvelle tarification doit être appliquée');
        System.assertEquals('En cours', newLiv.Statut__c, 'Le statut doit être préservé');

        
    }

    /**
     * Test positive : Suppression d'une livraison via deleteLivraison
     */
    @IsTest
    static void testDeleteLivraison() {
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

        // When
        Test.startTest();
        OrderService.deleteLivraison(o.Id);
        Test.stopTest();

        // Then
        List<Livraison__c> livs = [SELECT Id FROM Livraison__c WHERE Order__c = :o.Id];
        System.assertEquals(0, livs.size(), 'Aucune livraison ne doit exister après suppression');
    }
    

    /**
     * Test positive : Suppression automatique via deleteLivraisonsByOrder
     */
    @IsTest
    static void testDeleteLivraisonsByOrder() {
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

        // Test
        Test.startTest();
        OrderService.deleteLivraisonsByOrder(o.Id);
        Test.stopTest();

        // Verify
        List<Livraison__c> livs = [SELECT Id FROM Livraison__c WHERE Order__c = :o.Id];
        System.assertEquals(0, livs.size(), 'Aucune livraison ne doit exister après suppression automatique');
    }

}