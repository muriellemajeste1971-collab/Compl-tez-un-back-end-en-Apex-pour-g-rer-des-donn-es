@IsTest
private class AccountTriggerTest {

    @IsTest
    static void testBeforeInsertValid() {

        // GIVEN
        Account a = new Account(
            Name = 'Test Insert Valid',
            Customer_Type__c = 'Particulier',
            ShippingCountry = 'France'
        );

        // WHEN
        Test.startTest();
        insert a;
        Test.stopTest();

        // THEN
        Account inserted = [
            SELECT ShippingCountry, Customer_Type__c
            FROM Account
            WHERE Id = :a.Id
        ];

        System.assertEquals('FR', inserted.ShippingCountry);
        System.assertEquals('Particulier', inserted.Customer_Type__c);
    }

    @IsTest
    static void testBeforeInsertInvalidCustomerType() {

        // GIVEN
        Account a = new Account(
            Name = 'Test Insert Invalid CT',
            Customer_Type__c = 'Inconnu',
            ShippingCountry = 'France'
        );

        // WHEN + THEN
        try {
            Test.startTest();
            insert a;
            Test.stopTest();
            System.assert(false, 'L’insertion aurait dû échouer');
        }
        catch (Exception e) {
            System.assert(e.getMessage().contains('Customer Type'));
        }
    }

    @IsTest
    static void testBeforeUpdateValid() {

        // GIVEN
        Account a = new Account(
            Name = 'Test Update Valid',
            Customer_Type__c = 'Particulier',
            ShippingCountry = 'France'
        );
        insert a;

        // WHEN
        a.ShippingCountry = 'Belgique';
        a.Customer_Type__c = 'Professionnel';

        Test.startTest();
        update a;
        Test.stopTest();

        // THEN
        Account updated = [
            SELECT ShippingCountry, Customer_Type__c
            FROM Account
            WHERE Id = :a.Id
        ];

        System.assertEquals('BE', updated.ShippingCountry);
        System.assertEquals('Professionnel', updated.Customer_Type__c);
    }

    @IsTest
    static void testBeforeUpdateInvalidShippingCountry() {

        // GIVEN
        Account a = new Account(
            Name = 'Test Update Invalid Country',
            Customer_Type__c = 'Particulier',
            ShippingCountry = 'France'
        );
        insert a;

        // WHEN
        a.ShippingCountry = 'Spain';

        // THEN
        try {
            Test.startTest();
            update a;
            Test.stopTest();
            System.assert(false, 'La mise à jour aurait dû échouer');
        }
        catch (Exception e) {
            System.assert(e.getMessage().contains('Country'));
        }
    }
}
