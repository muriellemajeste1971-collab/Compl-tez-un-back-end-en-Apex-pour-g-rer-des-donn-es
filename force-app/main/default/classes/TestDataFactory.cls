@isTest
public class TestDataFactory {

    // ---------------------------------------------------------
    // 1. Données pour les tests Opportunity / Product
    // ---------------------------------------------------------
    public static OpportunityLineItem createOpportunityLineItem() {
        Id stdPbId = Test.getStandardPricebookId();

        Pricebook2 stdPb = new Pricebook2(
            Id = stdPbId,
            IsActive = true
        );
        update stdPb;

        Product2 p0 = new Product2(
            Name = 'Audi e-Tron',
            ProductCode = 'AUDI-ET',
            IsActive = true
        );
        insert p0;
        
        List<Product2> produits = new List<Product2>{
        new Product2(Name = 'Produit 1', IsActive = true),
        new Product2(Name = 'Produit 2', IsActive = true),  
        new Product2(Name = 'Produit 3', IsActive = true), 
        new Product2(Name = 'Produit 4', IsActive = true)
	    };
	    insert produits;

        PricebookEntry stdPbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id = p0.Id,
            UnitPrice = 50000,
            IsActive = true
        );
        insert stdPbe;
        
        Id pbId = Test.getStandardPricebookId();

		List<PricebookEntry> pbes = new List<PricebookEntry>();
		for (Product2 p2 : produits) {
    	pbes.add(new PricebookEntry(
        Pricebook2Id = pbId,
        Product2Id = p2.Id,
        UnitPrice = 10000,
        IsActive = true
    ) );
   }
   insert pbes;


        Pricebook2 customPb = new Pricebook2(
            Name = 'Test Pricebook',
            IsActive = true
        );
        insert customPb;

        PricebookEntry customPbe = new PricebookEntry(
            Pricebook2Id = customPb.Id,
            Product2Id = p0.Id,
            UnitPrice = 50000,
            IsActive = true
        );
        insert customPbe;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = customPbe.Id,
            Quantity = 2,
            UnitPrice = 50000
        );
        insert oli;

        return oli;
    }


    
    
    

    // ---------------------------------------------------------
    // 2. Données pour les tests User / Profil
    // ---------------------------------------------------------
    public static User createTestUser() {

        Profile p = [
            SELECT Id
                FROM Profile
                WHERE Name IN ('System Administrator', 'Administrateur Système')
            LIMIT 1
        ];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test.user@example.com',
            Username = 'test.user+' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'fr_FR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'fr',
            ProfileId = p.Id
        );

        insert testUser;

        return testUser;
    }
    
    	public static Account createAccount() {
        
     	Account a = new Account (
								Name = 'Account 1', 
         						Customer_Type__c = 'Particulier'); 
        insert a;
		return a;
        
    }

   		public static Contract createContract(Id accountId) {
        
     	Contract c = new Contract (
								Name = 'Contract 1 for Account 1', 
         						AccountId = accountId,
     							StartDate = Date.Today(),
     							Status = 'Draft'); 
        insert c;
        
        c.Status ='Activated';
        c.ActivatedDate = Date.Today();
        update c;
 		return c;
        
    }
    
     
    public static Order createOrder(Id accountId, Id contractId) {
	// 1. Récupération du standard pricebook
   		 Id pbId = Test.getStandardPricebookId();

        
    // 2. Création de la commande
    	Order o = new Order(
        					Name = 'Order 1 for Account 1',
        					AccountId = accountId,
        					ContractId = contractId,
            				Pricebook2Id = pbId,
        					Status = 'Draft',
        					ShippingCountry = 'FR',
        					EffectiveDate = Date.today()
    						);
    	insert o;

   

    // 3. création des bijoux
	     Product2 p1 = new Product2(
            Name = 'Bijoux 1',
            ProductCode = 'BJ01',
            IsActive = true
        );
        insert p1;
        
         Product2 p2 = new Product2(
            Name = 'Bijoux 2',
            ProductCode = 'BJ02',
            IsActive = true
        );
		insert p2;
        
         Product2 p3 = new Product2(
            Name = 'Bijoux 3',
            ProductCode = 'BJ03',
            IsActive = true
        );
        insert p3;
        
       // 4. création des bijoux
        
       PricebookEntry e1 = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = p1.Id,
            UnitPrice = 10000,
            IsActive = true
        );
        insert e1;
        
    	PricebookEntry e2 = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = p2.Id,
            UnitPrice = 20000,
            IsActive = true
        );
        insert e2;

     	PricebookEntry e3 = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = p3.Id,
            UnitPrice = 30000,
            IsActive = true
        );
        insert e3;
    

    // 4. Création des OrderItems
       OrderItem oi1 = new OrderItem(
            OrderId = o.Id,
            PricebookEntryId = e1.Id,
            Product2Id = p1.Id,
            Quantity = 2,
            UnitPrice = 10000
        );
        insert oi1;

 		OrderItem oi2 = new OrderItem(
            OrderId = o.Id,
            PricebookEntryId = e2.Id,
            Product2Id = p2.Id,
            Quantity = 1,
            UnitPrice = 20000
        );
        insert oi2;
        
        OrderItem oi3 = new OrderItem(
            OrderId = o.Id,
            PricebookEntryId = e3.Id,
            Product2Id = p3.Id,
            Quantity = 1,
            UnitPrice = 30000
        );
        insert oi3;
        
        
    // 5. Activation de la commande
    o.Status = 'Activated';
    o.ActivatedDate = Date.today();
    update o;

    return o;
}

    
    public static Transporteur__c createTransporteur(String typeClient) {
        
     Transporteur__c tr = new Transporteur__c (
        Name = 'Transporteur 1', 
        Customer_Type__c = typeClient ); 
        insert tr;
		return tr;
        
    }
    
    
    public static List<Tarification__c> createTarificationList() {

    List<Tarification__c> liste = new List<Tarification__c>();
        
    Transporteur__c tr = createTransporteur('Particulier');

    Tarification__c t1 = new Tarification__c(
        Name = 'Transporteur 1 (France : Particulier ; 7 € ; 6 jours)',
        Zone_de_livraison__c = 'France',
        Tarif_de_livraison__c = 7,
        D_lai_de_Livraison_jours__c = 6,
        Transporteur__c = tr.Id
    );

    Tarification__c t2 = new Tarification__c(
        Name = 'Transporteur 2 (France : Particulier)',
        Zone_de_livraison__c = 'France',
        Tarif_de_livraison__c = 10,
        D_lai_de_Livraison_jours__c = 4,
        Transporteur__c = tr.Id
    );

    Tarification__c t3 = new Tarification__c(
        Name = 'Transporteur 3 (France : Particulier ; 20€ ; 1 jour)',
        Zone_de_livraison__c = 'France',
        Tarif_de_livraison__c = 20,
        D_lai_de_Livraison_jours__c = 1,
        Transporteur__c = tr.Id
    );

    liste.add(t1);
    liste.add(t2);
    liste.add(t3);

    insert liste;
    return liste;
 }

}