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
    public static User createUser() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1];

        User u = new User(
            FirstName = 'Test User',
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

        insert u;
        return u;
    }

    public static User createRestrictedUser() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
    
        User u = new User(
            FirstName = 'Test User',
            LastName = 'Restricted',
            Email = 'restricted@example.com',
            Username = 'restricted@example.com',
            Alias = 'restr',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'fr_FR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'fr',
            ProfileId = p.Id
        );

        insert u;
        return u;
    }

    
    	public static List<Account> createAccounts(Integer num, String customerType, String shippingCountry ) {
        
     	List<Account> accts = new List<Account>();

        for (Integer i = 1; i <= num; i++) {
            Account a = new Account( Name = 'Account ' + i, Customer_Type__c = customerType, ShippingCountry = shippingCountry);
            accts.add(a);
        }
								
        insert accts;	
        return accts;
        
        }

   		public static List<Order> createOrders(List<Id> accountIds, Integer numberOfProducts, Integer numberOfOrders) {

        // 1. Standard Pricebook
        Id pbId = Test.getStandardPricebookId();

        // 2. Création des Contracts (Draft)
        List<Contract> contracts = new List<Contract>();

        for (Id accId : accountIds) {
            for (Integer i = 0; i < numberOfOrders; i++) {
                Contract c = new Contract(
                    Name = 'Contract ' + i,
                    ContractTerm = 12,
                    AccountId = accId,
                    StartDate = Date.today(),
                    Status = 'Draft'
                );
            contracts.add(c);
            }
        }

        insert contracts;

        // Activation des Contracts
        for (Contract c : contracts) {
            c.Status = 'Activated';
            c.ActivatedDate = Date.today();
        }

        update contracts;

        // 0. Récupération des Accounts
         List<Account> accs = [
             SELECT Id, ShippingCountry
             FROM Account
            WHERE Id IN :accountIds
         ];

        Map<Id, Account> accMap = new Map<Id, Account>(accs);

         // 3. Création des Orders (Draft)
        List<Order> orders = new List<Order>();
        // Index pour parcourir les contrats et lier au bon order !
        Integer contractIndex = 0;

            for (Id accId : accountIds) {

                 Account acc = accMap.get(accId);

        for (Integer j = 0; j < numberOfOrders; j++) {

            Order o = new Order(
                Name = 'Order ' + j,
                AccountId = accId,
                ContractId = contracts[contractIndex].Id,
                Pricebook2Id = pbId,
                Status = 'Draft',
                ShippingCountry = acc.ShippingCountry,
                EffectiveDate = Date.today()
            );

            orders.add(o);
            contractIndex++;
         }
        }

        insert orders;

        // 4. Création des Products
         List<Product2> products = new List<Product2>();

        for (Integer i = 0; i < numberOfProducts; i++) {
        Product2 p2 = new Product2(
            Name = 'Product ' + (i+1),
            ProductCode = 'P2' + (i+1),
            IsActive = true
        );
        products.add(p2);
        }

        insert products;

        // 5. PricebookEntries
        List<PricebookEntry> entries = new List<PricebookEntry>();

        for (Product2 p : products) {
            PricebookEntry pe = new PricebookEntry(
                Pricebook2Id = pbId,
                Product2Id = p.Id,
                UnitPrice = 10000,
                IsActive = true
            );
        entries.add(pe);
        }

        insert entries;

        // 6. OrderItems
        List<OrderItem> items = new List<OrderItem>();

        for (Order o : orders) {
                for (Integer i = 0; i < numberOfProducts; i++) {

                    OrderItem oi = new OrderItem(
                        OrderId = o.Id,
                        PricebookEntryId = entries[i].Id,
                        Product2Id = products[i].Id,
                        Quantity = 1,
                        UnitPrice = entries[i].UnitPrice
                    );

            items.add(oi);
            }
        }

        insert items;

        // 7. Activation des Orders
         for (Order o : orders) {
             o.Status = 'Activated';
            o.ActivatedDate = Date.today();
        }

        update orders;

        return orders;
    }

    
    public static List<Tarification__c> createTarifs() {

     // 1. Création des Transporteurs
        List<Transporteur__c> transportors = new List<Transporteur__c>();    

        Transporteur__c chrono = new Transporteur__c (Name = 'Chronopost', Customer_Type__c = 'Particulier, Professionnel');  
        Transporteur__c ups = new Transporteur__c (Name = 'UPS', Customer_Type__c = 'Particulier, Professionnel');
        Transporteur__c geodis = new Transporteur__c (Name = 'Geodis', Customer_Type__c = 'Particulier, Professionnel');
        Transporteur__c dhl = new Transporteur__c (Name = 'DHL Express', Customer_Type__c = 'Professionnel');    
        Transporteur__c gls = new Transporteur__c (Name = 'GLS', Customer_Type__c = 'Particulier');

        transportors.add(chrono);
        transportors.add(ups);
        transportors.add(geodis);
        transportors.add(dhl);
        transportors.add(gls);

        insert transportors;   

     // 2. Création des Tarifications
        List<Tarification__c> tarifs = new List<Tarification__c>();
      
        // France - Particulier
        Tarification__c c1 = new Tarification__c(Zone_de_livraison__c = 'France', Tarif_de_livraison__c = 20, D_lai_de_Livraison_jours__c = 1, Transporteur__c = chrono.Id);
        Tarification__c c2 = new Tarification__c(Zone_de_livraison__c = 'France', Tarif_de_livraison__c = 23, D_lai_de_Livraison_jours__c = 2, Transporteur__c = ups.Id); 
        Tarification__c c3 = new Tarification__c(Zone_de_livraison__c = 'France', Tarif_de_livraison__c = 18, D_lai_de_Livraison_jours__c = 2, Transporteur__c = geodis.Id);
        Tarification__c c4 = new Tarification__c(Zone_de_livraison__c = 'France', Tarif_de_livraison__c = 14, D_lai_de_Livraison_jours__c = 3, Transporteur__c = gls.Id);

        // Belgique - Professionnel
        Tarification__c c5 = new Tarification__c(Zone_de_livraison__c = 'Belgique', Tarif_de_livraison__c = 25, D_lai_de_Livraison_jours__c = 2, Transporteur__c = dhl.Id);
        Tarification__c c6 = new Tarification__c(Zone_de_livraison__c = 'Belgique', Tarif_de_livraison__c = 18, D_lai_de_Livraison_jours__c = 3, Transporteur__c = chrono.Id); 
        Tarification__c c7 = new Tarification__c(Zone_de_livraison__c = 'Belgique', Tarif_de_livraison__c = 20, D_lai_de_Livraison_jours__c = 3, Transporteur__c = ups.Id);
   
        tarifs.add(c1);
        tarifs.add(c2);
        tarifs.add(c3);
        tarifs.add(c4);
        tarifs.add(c5);
        tarifs.add(c6);
        tarifs.add(c7);

        insert tarifs;

        return tarifs;
       
    }
  

    public static List<Livraison__c> createDeliveryOrders(List<Account> accounts, List<Order> orders) {
    List<Livraison__c> deliveries = new List<Livraison__c>();

    for (Order o : orders) {

        // 1. Récupérer la zone depuis l’Account
        String zone = accounts[0].ShippingCountry;

        // 2. Récupérer les tarifs correspondant à cette zone
        List<Tarification__c> tarifs = [
            SELECT Id, Zone_de_Livraison__c, Tarif_de_Livraison__c, D_lai_de_Livraison_jours__c, Transporteur__c
            FROM Tarification__c
            WHERE Zone_de_Livraison__c = :zone
        ];

        // 3. Sélection aléatoire via boucle
        Tarification__c selectedTarif;

        for (Tarification__c t : tarifs) {
            if (Math.random() > 0.5) {
                selectedTarif = t;
            }
        }

        // 4. Si aucun n’a été choisi, prendre le premier
        if (selectedTarif == null && !tarifs.isEmpty()) {
            selectedTarif = tarifs[0];
        }

        // 5. Créer la livraison
        Livraison__c d = new Livraison__c(
            Account__c = o.AccountId,
            Order__c = o.Id,
            Tarification__c = selectedTarif != null ? selectedTarif.Id : null
        );

        deliveries.add(d);
    }

    insert deliveries;
    return deliveries;
}

        
}

 

