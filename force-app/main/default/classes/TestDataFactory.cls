@IsTest
public class TestDataFactory {

    // ===== Helpers =====
    private static String uniq(String prefix) {
        return prefix + '_' + DateTime.now().getTime();
    }

    private static Pricebook2 getStdPricebook() {
        Id pbId = Test.getStandardPricebookId();
        Pricebook2 pb = [SELECT Id, IsActive FROM Pricebook2 WHERE Id = :pbId LIMIT 1];
        if (!pb.IsActive) {
            pb.IsActive = true;
            update pb;
        }
        return pb;
    }

    private static Profile getProfile(String name) {
        return [SELECT Id FROM Profile WHERE Name = :name LIMIT 1];
    }

    // ===== Account =====
    public static Account createAccount(String customerType) {
        Account a = new Account(
            Name = 'Account ' + uniq(customerType)
        );
        insert a;
        return a;
    }

    // ===== User =====
    public static User createStandardUser() {
        Profile p = getProfile('Standard User');
        String u = uniq('user');

        User usr = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tusr',
            Email = u + '@test.com',
            Username = u + '@test.com',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'fr_FR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'fr',
            ProfileId = p.Id
        );
        insert usr;
        return usr;
    }

    // ===== Order =====
    public static Order createOrder(String accountName, Date effectiveDate, String status) {
        Account acct = new Account(Name = accountName);
        insert acct;

        Pricebook2 pb = getStdPricebook();

        Order o = new Order(
            AccountId = acct.Id,
            EffectiveDate = effectiveDate == null ? Date.today() : effectiveDate,
            Status = String.isBlank(status) ? 'Draft' : status,
            Pricebook2Id = pb.Id
        );
        insert o;
        return o;
    }

    // ===== Order Items =====
    public static void addOrderItems(Id orderId, Integer qtyTotal) {
        Pricebook2 pb = getStdPricebook();

        Product2 p = new Product2(Name='Produit ' + uniq('P'), IsActive=true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = p.Id,
            UnitPrice = 10,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;

        OrderItem oi = new OrderItem(
            OrderId = orderId,
            Quantity = qtyTotal == null ? 1 : qtyTotal,
            UnitPrice = 10,
            PricebookEntryId = pbe.Id
        );
        insert oi;
    }

    // ===== Transporteur =====
    public static Transporteur__c createTransporter(String name, String clientType) {
        Transporteur__c t = new Transporteur__c(
            Name = name == null ? uniq('Transporteur') : name,
            Customer_Type__c = clientType
        );
        insert t;
        return t;
    }

    // ===== Tarification =====
    public static Tarification__c createTarification(
        Transporteur__c transporteur,
        String pays,
        Decimal cout,
        Integer delai
    ) {
        Tarification__c tar = new Tarification__c(
            Name = transporteur.Name + ' - ' + pays,
            Transporteur__c = transporteur.Id,
            Zone_de_Livraison__c = pays,
            Tarif_de_livraison__c = cout,
            D_lai_de_livraison_jours__c = delai
        );
        insert tar;
        return tar;
    }

    // ===== Livraison =====
    public static Livraison__c createLivraison(
        Id orderId,
        Id transporteurId,
        String statut
    ) {
        Livraison__c liv = new Livraison__c(
            Name = 'Livraison ' + uniq('L'),
            Order__c = orderId,
            Transporteur__c = transporteurId,
            Statut__c = String.isBlank(statut) ? 'Brouillons' : statut
        );
        insert liv;
        return liv;
    }

    // ===== Pack complet =====
    public class LivraisonPack {
        public Order orderRec;
        public Transporteur__c transporteur;
        public Tarification__c tarification;
        public Livraison__c livraison;
    }

    public static LivraisonPack createLivraisonPack() {
        LivraisonPack p = new LivraisonPack();

        p.orderRec = createOrder('Account ' + uniq('A'), Date.today(), 'Draft');
        addOrderItems(p.orderRec.Id, 2);

        p.transporteur = createTransporter('Transporteur ' + uniq('T'), 'B2C');
        p.tarification = createTarification(p.transporteur, 'FR', 10, 3);

        p.livraison = createLivraison(p.orderRec.Id, p.transporteur.Id, 'Brouillons');

        return p;
    }
}