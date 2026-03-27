@isTest
private class OrderServiceExceptionTest {

    @isTest
    static void testExceptionInstantiation() {

        OrderServiceException ex =
            new OrderServiceException();

        System.assertNotEquals(null, ex);
    }
}