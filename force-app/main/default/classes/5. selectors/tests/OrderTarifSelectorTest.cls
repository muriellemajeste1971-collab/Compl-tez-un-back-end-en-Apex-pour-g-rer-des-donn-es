@IsTest
public class OrderTarifSelectorTest {

    @IsTest
    static void singleAction() {

        // GIVEN
        List<Tarification__c> tarifs =
            TestDataFactory.createTarifs();

        // WHEN
        Test.startTest();
        List<Tarification__c> result =
            OrderTarifSelector.selectByTarif();
        Test.stopTest();

        // THEN
        for (Tarification__c t : result) {
            System.assertNotEquals(null, t.Zone_de_Livraison__c);
            System.assertNotEquals(null, t.Tarif_de_Livraison__c);
        }
    }

    @isTest
    static void bulkActions() {

        // GIVEN
        List<Tarification__c> tarifs =
            TestDataFactory.createTarifs();

        // WHEN
        Test.startTest();
        List<Tarification__c> result =
            OrderTarifSelector.selectByTarif();
        Test.stopTest();

        // THEN
        System.assert(result.size() >= tarifs.size());
    }

    @isTest
    static void positiveBehaviour() {

        // GIVEN
        List<Tarification__c> tarifs =
            TestDataFactory.createTarifs();

        // WHEN
        Test.startTest();
        List<Tarification__c> result =
            OrderTarifSelector.selectByTarif();
        Test.stopTest();

        // THEN
        for (Tarification__c t : result) {
            System.assertNotEquals(null, t.Zone_de_Livraison__c);
            System.assertNotEquals(null, t.Tarif_de_Livraison__c);
        }
    }

    @isTest
    static void negativeBehaviour() {

        // GIVEN
        // pas de création de tarifs

        // WHEN
        Test.startTest();
        List<Tarification__c> result =
            OrderTarifSelector.selectByTarif();
        Test.stopTest();

        // THEN
        System.assertEquals(0, result.size());
    }

    @isTest
    static void restrictedUser() {

        // GIVEN
        List<User> users = TestDataFactory.createUsers(
            new List<String>{ 'Chatter Free User' }
        );
        User restrictedUser = users[0];

        TestDataFactory.createTarifs();

        // WHEN
        Test.startTest();
        System.runAs(restrictedUser) {

            List<Tarification__c> result =
                OrderTarifSelector.selectByTarif();

            // THEN
            System.assertNotEquals(null, result);
        }
        Test.stopTest();
    }
}