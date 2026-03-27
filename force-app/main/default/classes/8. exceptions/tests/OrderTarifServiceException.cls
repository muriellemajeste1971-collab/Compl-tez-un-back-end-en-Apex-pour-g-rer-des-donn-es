@isTest
private class OrderTarifServiceExceptionTest {

    @isTest
    static void testExceptionInstantiation() {

        OrderTarifServiceException ex =
            new OrderTarifServiceException();

        System.assertNotEquals(null, ex);
    }
}