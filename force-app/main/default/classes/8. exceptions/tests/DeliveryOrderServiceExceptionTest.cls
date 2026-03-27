@isTest
private class DeliveryOrderServiceExceptionTest {

    @isTest
    static void testExceptionInstantiation() {

        // WHEN
        DeliveryOrderServiceException ex =
            new DeliveryOrderServiceException();

        // THEN
        System.assertNotEquals(null, ex);
    }
}