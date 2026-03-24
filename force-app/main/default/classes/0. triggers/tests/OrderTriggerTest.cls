@IsTest
private class OrderTriggerTest {

    @IsTest
    static void testBeforeUpdateValid() {

        // GIVEN
        Account a = TestDataFactory.createAccounts(1, 'Particulier', 'France')[0];
        List<Order> orders = TestDataFactory.createOrders(1, 1, new List<Id>{a.Id});
        Order o = orders[0];

        // WHEN : valeur valide
        o.Status = 'Draft';

        Test.startTest();
        update o;
        Test.stopTest();

        // THEN
        Order updated = [
            SELECT Status
            FROM Order
            WHERE Id = :o.Id
        ];
        System.assertEquals('Draft', updated.Status);
    }

    @IsTest
    static void testBeforeUpdateInvalid() {

        // GIVEN
        Account a = TestDataFactory.createAccounts(1, 'Particulier', 'France')[0];
        List<Order> orders = TestDataFactory.createOrders(1, 1, new List<Id>{a.Id});
        Order o = orders[0];

        // WHEN : valeur qui doit déclencher une erreur
        o.Status = 'InvalidStatus';

        try {
            Test.startTest();
            update o;
            Test.stopTest();
            System.assert(false, 'La mise à jour aurait dû échouer');
        }
        catch (Exception e) {
            System.assert(true);
        }
    }

    @IsTest
    static void testBeforeDeleteValid() {

        // GIVEN
        Account a = TestDataFactory.createAccounts(1, 'Particulier', 'France')[0];
        List<Order> orders = TestDataFactory.createOrders(1, 1, new List<Id>{a.Id});
        Order o = orders[0];

        // WHEN
        Test.startTest();
        delete o;
        Test.stopTest();

        // THEN
        System.assertEquals(0, [
            SELECT Count()
            FROM Order
            WHERE Id = :o.Id
        ]);
    }

    @IsTest
    static void testBeforeDeleteInvalid() {

        // GIVEN
        Account a = TestDataFactory.createAccounts(1, 'Particulier', 'France')[0];
        List<Order> orders = TestDataFactory.createOrders(1, 1, new List<Id>{a.Id});
        Order o = orders[0];

        // WHEN : on force un état interdit
        o.Status = 'Activated';
        update o;

        try {
            Test.startTest();
            delete o;
            Test.stopTest();
            System.assert(false, 'La suppression aurait dû échouer');
        }
        catch (Exception e) {
            System.assert(true);
        }
    }
}
