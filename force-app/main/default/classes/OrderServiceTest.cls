
@isTest
private class OrderServiceTest {

    @isTest
    static void testCreateLivraison() {
        // order creation no longer needs a pre-existing account record
        // the helper will spin one up with a default type internally
        Transporteur__c t = TestDataFactory.createTransporter('OS1', 'Particulier');
        Tarification__c tf = TestDataFactory.createTarification(t, 'France', 12.5, 4);

        Order o = TestDataFactory.createOrder('Acct 6', Date.today(), 'Draft');

        Test.startTest();
        Id livId = OrderService.createLivraison(o.Id, tf.Id);
        Test.stopTest();

        Livraison__c created = [SELECT Id, Order__c, Account__c, Tarification__c, Statut__c FROM Livraison__c WHERE Id = :livId LIMIT 1];

        System.assertEquals(o.Id, created.Order__c, 'Order__c should match');
        System.assertEquals(o.AccountId, created.Account__c, 'Account__c should match');
        System.assertEquals(tf.Id, created.Tarification__c, 'Tarification__c should match');
        System.assertEquals('En cours', created.Statut__c, 'Statut should be En cours');
    }
}