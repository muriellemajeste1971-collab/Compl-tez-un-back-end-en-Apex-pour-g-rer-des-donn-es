@isTest
public class TestDataFactory {
   
    // 1. Create User Dummy Data for Unit Tests
    public static List<User> createUsers(List<String> profileNames) {

        List<Profile> profiles = ProfileFactory.assemble(profileNames); 
        List<User> users = UserFactory.assemble(profiles); 

        insert users; 
        return users; 
    }

    // 3. Create Acccount Dummy Data for Unit Tests
    public static List<Account> createAccounts(Integer num, String customerType, String shippingCountry ) {
        
        List<Account> accts = AccountFactory.assemble(num, customerType, shippingCountry);
        insert accts;	
        return accts; 
    }
    	
    // 4. Create Order Dummy Data for Unit Tests
    public static List<Order> createOrders(Integer numberOfOrders, Integer numberOfProducts,  List<Id> accountIds) {

        // 1. Standard Pricebook
        Id pbId = Test.getStandardPricebookId();

        // 2. Create Contract Dummy Data Status Draft
        List<Contract> contracts = ContractFactory.assemble(numberOfOrders, numberOfProducts, accountIds);
        insert contracts;
            for (Contract c : contracts) {
                c.Status = 'Activated';       
            }
        update contracts;   

        // 3. Create Order Dummy Data Status Draft
        List<Order> orders = OrderFactory.assemble(contracts, pbId);
        insert orders;

        // 4. Création des Products
        List<Product2> products = Product2Factory.assemble(numberOfProducts);
        insert products;  

        // 5. PricebookEntries
        List<PricebookEntry> entries = PricebookEntryFactory.assemble(products, pbId);
        insert entries;

        // 6. OrderItems
        List<OrderItem> items = OrderItemFactory.assemble(orders, numberOfProducts, entries, products);
        insert items;

        // 7. Activation des Orders
            for (Order o : orders) {
                o.Status = 'Activated';
            }

        update orders;
        return orders;
    }
   		
    public static List<Tarification__c> createTarifs() {

        // 1. Création des Transporteurs
        List<Transporteur__c> transporters = TransporterFactory.assemble();
        insert transporters;   

        // 2. Création des Tarifications
        List<Tarification__c> tarifs = OrderTarifFactory.assemble(transporters);
        insert tarifs;
        return tarifs;
    }
  
    public static List<Livraison__c> createDeliveryOrders(List<Account> accounts, List<Order> orders) {

        // 1. Récupérer toutes les zones
        Set<String> zones = new Set<String>();
            for (Account acc : accounts) { zones.add(acc.ShippingCountry);}

        // 2. Tarifs groupés par zone
        Map<String, List<Tarification__c>> tarifsByZone = new Map<String, List<Tarification__c>>();

            for (Tarification__c t : [
                SELECT Id, Zone_de_Livraison__c, Tarif_de_Livraison__c, D_lai_de_Livraison_jours__c, Transporteur__c
                FROM Tarification__c
                WHERE Zone_de_Livraison__c IN :zones
            ]) 

            {
            if (!tarifsByZone.containsKey(t.Zone_de_Livraison__c)) {
            tarifsByZone.put(t.Zone_de_Livraison__c, new List<Tarification__c>());
            }
            tarifsByZone.get(t.Zone_de_Livraison__c).add(t);

            }

        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

        // Map OrderId → TarifId (ce que la factory métier attend)
        Map<Id, Id> selectedTarifIds = new Map<Id, Id>();
        
        // 3. Boucle principale
            for (Order o : orders) {

                String zone = accountMap.get(o.AccountId).ShippingCountry;
                List<Tarification__c> tarifs = tarifsByZone.get(zone);

                // Simulation de la selection de tarifs
                Tarification__c selectedTarif;

                if (tarifs != null) {
                    for (Tarification__c t : tarifs) {
                        if (Math.random() > 0.5) {
                            selectedTarif = t;
                        }
                    }
                }

                if (selectedTarif == null && tarifs != null && !tarifs.isEmpty()) {
                    selectedTarif = tarifs[0];
                }

                // remplit la map pour la factory métier
                selectedTarifIds.put(o.Id, selectedTarif != null ? selectedTarif.Id : null);
            }

        List<Livraison__c> deliveries = DeliveryOrderFactory.assemble(orders, selectedTarifIds);

        insert deliveries;
        return deliveries;
        } 
    }