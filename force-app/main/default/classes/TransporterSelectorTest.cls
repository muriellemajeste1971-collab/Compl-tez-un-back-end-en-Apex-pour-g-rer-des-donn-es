@IsTest
public class TransporterSelectorTest {

    @IsTest
    static void testFastestAndCheapest() {
       // GIVEN
       Account a = TestDataFactory.createAccount();
       Contract c = TestDataFactory.createContract(a.Id);
       Order o = TestDataFactory.createOrder(a.Id, c.Id);
       Transporteur__c tr = TestDataFactory.createTransporteur('Particulier');
        
       List<Tarification__c> tarifs = TestDataFactory.createTarificationList();

       Tarification__c t1 = tarifs[0];
       Tarification__c t3 = tarifs[2];

        // WHEN
        Test.startTest();
        List<Tarification__c> result = TransporterSelector.getAll(o.Id, 'France', 'Particulier');
        Test.stopTest();

       System.debug('RESULT SIZE = ' + result.size());
       System.debug('RESULT LIST = ' + result);
        
        Tarification__c cheapest = result[1];
        Tarification__c fastest = result[0];
       

        // THEN
        
      
        System.assert(result.size() > 2);
        System.assertEquals(t3.Id, fastest.Id);
        System.assertEquals(t1.Id, cheapest.Id);
       
    }
}