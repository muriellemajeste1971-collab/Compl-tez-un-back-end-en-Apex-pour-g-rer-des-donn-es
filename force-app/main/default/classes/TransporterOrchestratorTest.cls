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