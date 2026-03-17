@isTest
public class OrderTriggerDeleteTest {

    @isTest
    static void testTriggerDeletesLivraisons() {

        // GIVEN
        Order o = TestDataFactory.createOrder();

        Livraison__c l1 = new Livraison__c(Order__c = o.Id);
        Livraison__c l2 = new Livraison__c(Order__c = o.Id);
        insert new List<Livraison__c>{ l1, l2 };

        // WHEN
        delete o;

        // THEN
        List<Livraison__c> remaining = [
            SELECT Id FROM Livraison__c WHERE Order__c = :o.Id
        ];

        System.assertEquals(0, remaining.size(), 'Le trigger doit supprimer les livraisons liées');
    }
}
