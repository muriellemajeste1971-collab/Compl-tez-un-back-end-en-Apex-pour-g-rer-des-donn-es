@isTest
public class TestDataFactory {

    public static Account createAccount(String customerType) {
        Account a = new Account(
            Name = 'Test Account ' + customerType
            // TODO si tu as un champ qui pilote Account_Type__c sur Order:
            // Customer_Type__c = customerType
        );
        insert a;
        return a;
    }

    public static Order createOrder(Id accountId, String status) {
        // Standard Pricebook obligatoire pour OrderItem
        Id stdPbId = Test.getStandardPricebookId();

        Order o = new Order(
            AccountId = accountId,
            EffectiveDate = Date.today(),
            Status = status,
            Pricebook2Id = stdPbId
        );
        insert o;
        return o;
    }

    public static void addOrderItems(Id orderId, Integer qtyTotal) {
        // Produit + PricebookEntry requis pour OrderItem
        Product2 p = new Product2(Name='Test Product', IsActive=true);
        insert p;

        Id stdPbId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id = p.Id,
            UnitPrice = 10,
            IsActive = true
        );
        insert pbe;

        // On crée 1 ligne avec Quantity = qtyTotal (simple)
        OrderItem oi = new OrderItem(
            OrderId = orderId,
            Quantity = qtyTotal,
            UnitPrice = 10,
            PricebookEntryId = pbe.Id
        );
        insert oi;
    }

    public static SObject createTransporteurIfNeeded() {
        // Si Tarification__c a un lookup obligatoire vers Transporteur__c
        // adapte l'API name si besoin
        Transporteur__c t = new Transporteur__c(Name='Test Transporteur');
        insert t;
        return t;
    }

    public static Tarification__c createTarification(Id transporteurId) {
        Tarification__c tar = new Tarification__c(
            Name = 'Tarif Test'
            // TODO si champ requis :
            // Transporteur__c = transporteurId
            // Pays__c = 'France', Delai__c = 1, Cout__c = 20, etc...
        );
        // Si tu as bien Transporteur__c obligatoire, décommente :
        if (transporteurId != null) {
            tar.put('Transporteur__c', transporteurId);
        }

        insert tar;
        return tar;
    }
}