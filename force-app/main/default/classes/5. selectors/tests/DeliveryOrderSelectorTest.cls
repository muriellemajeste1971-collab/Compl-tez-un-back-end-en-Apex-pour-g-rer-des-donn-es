@isTest
public class DeliveryOrderSelectorTest {

    @isTest
    static void singleactionGetDeliveryOrdersByorderIds() {

        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> o = TestDataFactory.createOrders(new List<Id>{ a[0].Id }, 3, 1);
        List<Tarification__c> t = TestDataFactory.createTarifs();
        List<Livraison__c> d = TestDataFactory.createDeliveryOrders(a, new List<Order>{ o[0] });

        // WHEN
        Test.startTest();
        List<Livraison__c> result = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(new Set<Id>{ o[0].Id });
        Test.stopTest();

        // THEN
        System.assertEquals(1, result.size(), 'Le selector doit renvoyer la livraison liées à l’Order');
        System.assertEquals(d[0].Id, result[0].Id, 'Le selector doit renvoyer la livraison liées à l’Order');

        //System.assert(result[0].Name.contains(o[0].ShippingCountry) , 'Le nom de la livraison doit avoir la zone de livraison correspondant au pays de livraison');
        //System.assert(result[0].Name.contains(a[0].Name), 'Le nom de la livraison doit avoir le nom du compte de la commande');
        //System.assert(result[0].Name.contains(o[0].OrderNumber), 'le nom de la livraison doit avoir le numéro de la commande');

        System.assertEquals(o[0].AccountId, result[0].Account__c, 'La livraison doit avoir faire remonter le compte de la commande');
        System.assertEquals(o[0].Id, result[0].Order__c, 'la livraison doit être liée à l’order');
        System.assert(result[0].Tarification__c != null,'la livraison doit avoir les frais de livraison correspondant à la zone de livraison de l’account lié à l’order');
        
        System.assertEquals('En cours', result[0].Statut__c, 'la livraison doit avoir le statut "En cours"');
        System.Assert.areEqual('Particulier', result[0].Account_Type__c,'la livraison doit avoir le même type de compte que l’account lié à l’order');
        System.assertEquals(3, result[0].Product_Number__c, 'la livraison doit avoir le même nombre de produits que l’order');
        
        }

    @isTest
    static void bulkactionGetDeliveryOrdersByorderIds() {
         // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Professionnel', 'Belgique');
        List<Order> o = TestDataFactory.createOrders(new List<Id>{ a[0].Id }, 5, 200);
        List<Tarification__c> t = TestDataFactory.createTarifs();
        List<Livraison__c> d = TestDataFactory.createDeliveryOrders(a, new List<Order>{ o[0] });

       

        // WHEN
        Test.startTest();
        List<Livraison__c> result = DeliveryOrderSelector.getDeliveryOrdersByOrderIds(new Set<Id>{ o[0].Id });
        Test.stopTest();

        // THEN
        System.assertEquals(1, result.size(), 'Le selector doit renvoyer la livraison liées à l’Order');
        System.assertEquals(d[0].Id, result[0].Id, 'Le selector doit renvoyer la livraison liées à l’Order');
       
    }

    @isTest
    static void positivebehaviorGetDeliveryOrdersByorderIds() {
       
    }

    @isTest
    static void negativebehaviorGetDeliveryOrdersByorderIds() {
       
    }

    @isTest
    static void restricteduseretDeliveryOrdersByorderIds() {
       
    }

}
