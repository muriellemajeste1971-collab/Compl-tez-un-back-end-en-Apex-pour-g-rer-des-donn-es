public with sharing class PricebookEntryFactory {
    public static List<PricebookEntry> assemble(List<Product2> products, Id pbId) {

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

            for (Product2 p : products) {

                PricebookEntry pe = new PricebookEntry(
                    Pricebook2Id = pbId,
                    Product2Id = p.Id,
                    UnitPrice = 10000,
                    IsActive = true
                );
                pricebookEntries.add(pe);
            }

        return pricebookEntries;
    }
}