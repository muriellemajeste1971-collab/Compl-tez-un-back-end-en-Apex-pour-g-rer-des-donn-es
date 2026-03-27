
@IsTest
private class AccountDomainTest {

    @IsTest
    static void testValidShippingCountryFrance() {

        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Professionnel', 'france');

        // WHEN
        Test.startTest();
        // rien à insérer : la TDF l'a déjà fait
        Test.stopTest();

        // THEN
        Account inserted = [
            SELECT ShippingCountry
            FROM Account
            WHERE Id = :a[0].Id
        ];
        System.assertEquals('FR', inserted.ShippingCountry);
    }

    @IsTest
    static void testInvalidShippingCountry() {

        // GIVEN
        // Ici, la TDF va essayer d'insérer un Account invalide
        // donc l'erreur se produit DANS la TDF
        try {
            TestDataFactory.createAccounts(1, 'Professionnel', 'Spain');
            System.assert(false, 'L’insertion aurait dû échouer');
        }
        catch (Exception e) {
            // THEN
            System.assert(e.getMessage().contains('Country'));
        }
    }

    @IsTest
    static void testValidCustomerType() {

        // GIVEN
        List<Account> a = TestDataFactory.createAccounts(1, 'Particulier', 'France');

        // WHEN
        Test.startTest();
        // rien à insérer : la TDF l'a déjà fait
        Test.stopTest();

        // THEN
        Account inserted = [
            SELECT Customer_Type__c
            FROM Account
            WHERE Id = :a[0].Id
        ];
        System.assertEquals('Particulier', inserted.Customer_Type__c);
    }

    @IsTest
    static void testInvalidCustomerType() {

        // GIVEN
        try {
            TestDataFactory.createAccounts(1, 'Inconnu', 'France');
            System.assert(false, 'L’insertion aurait dû échouer');
        }
        catch (Exception e) {
            // THEN
            System.assert(e.getMessage().contains('Customer Type'));
        }
    }
}