@isTest
private class PriceBookFactoryTest {

    @isTest
    static void testStandardPricebookActivation() {
        Pricebook2 pb = PricebookFactory.activateStandardPricebook();
        System.assertEquals(true, pb.IsActive);
    }
}
