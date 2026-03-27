@isTest
public class OrderTriggerTest {
  
    @isTest
    static void testBeforeUpdateValid() {

        // GIVEN
        List<Account> acc = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ acc[0].Id });

        // WHEN
        Test.startTest();
        update orders;
        Test.stopTest();

        // THEN
        System.assert(true);
    }

   
    @isTest
    static void testBeforeUpdateInvalid() {

        // GIVEN
        List<Account> acc = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        

        // WHEN
        Test.startTest();

        try {
            List<Order> orders = TestDataFactory.createOrders(1, 1, new List<Id>{ acc[0].Id });
            orders[0].status = 'Activated';
            update orders;
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('La commande doit contenir au moins 3 produits'),
                'Le message d’erreur est incorrect'
            );
        }

        Test.stopTest();
    }

    // =========================================
    // UPDATE INVALID (Professionnel < 5 produits)
    // =========================================
    @isTest
    static void testBeforeUpdateInvalid_Professionnel() {

        // GIVEN
        List<Account> acc = TestDataFactory.createAccounts(1, 'Professionnel', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ acc[0].Id });
        orders[0].status = 'Activated';

        // WHEN
        Test.startTest();

        try {
            update orders;
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('La commande doit contenir au moins 5 produits'),
                'Le message d’erreur est incorrect'
            );
        }

        Test.stopTest();
    }

    // =========================================
    // DELETE INVALID (avec livraison)
    // =========================================
    @isTest
    static void testBeforeDeleteInvalid() {

        // GIVEN
        List<Account> acc = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ acc[0].Id });
        orders[0].status = 'Activated';
        update orders;

        // 👉 créer livraison avec ta factory
        TestDataFactory.createTarifs(); // obligatoire pour livraison
        TestDataFactory.createDeliveryOrders(acc, orders);

        // WHEN
        Test.startTest();
        try {
            delete orders;
            System.assert(false);
        } catch (DmlException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    // =========================================
    // DELETE VALID (sans livraison)
    // =========================================
    @isTest
    static void testBeforeDeleteValid() {

        // GIVEN
        List<Account> acc = TestDataFactory.createAccounts(1, 'Particulier', 'France');
        List<Order> orders = TestDataFactory.createOrders(1, 3, new List<Id>{ acc[0].Id });
        update orders;

        // WHEN
        Test.startTest();
        delete orders;
        Test.stopTest();

        // THEN
        System.assert(true);
    }
}