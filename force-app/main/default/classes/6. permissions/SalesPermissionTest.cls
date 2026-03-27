@IsTest
private class SalesPermissionTest {

    @IsTest
    static void testSalesUserCanCreateLivraison() {

        // 1. Créer un utilisateur Sales
        List<User> users = TestDataFactory.createUsers(new List<String>{ 'Sales' });
        User u = users[0];
        

        // 2. Récupérer la permission set créée dans Setup
        PermissionSet ps = [
            SELECT Id FROM PermissionSet WHERE Name = 'Gestion_des_Commandes' LIMIT 1
        ];

        // 3. Assigner la permission à l’utilisateur
        insert new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );

        // 4. Tester le comportement sous cet utilisateur
        System.runAs(u) {
            List<Account> accounts = TestDataFactory.createAccounts(1, 'Particulier', 'France');
            List<Id> accountIds = new List<Id>();
                for (Account a : accounts) {
                    accountIds.add(a.Id);
                }
            
            List<Order> orders = TestDataFactory.createOrders(1, 3, accountIds);
            List<Id> orderIds = new List<Id>();
                for (Order o : orders) {
                    orderIds.add(o.Id);
                }

            List<Tarification__c> tarifs = TestDataFactory.createTarifs();
            Map<Id, Id> tarifIds = new Map<Id,Id>();
                for (Order o : orders) {
                    tarifIds.put(o.Id, tarifs[0].Id);
                }
		    
            Test.startTest();
            Map<Id, Id> deliveryOrders = DeliveryOrderService.createByOrderIds(orderIds, tarifIds);
            Map<Id, Id> deliveryOrderIds = new Map<Id,Id>();
                for (Id orderId : deliveryOrders.keySet()) {
                    deliveryOrderIds.put(orderId, deliveryOrders.get(orderId));
                }
            Test.stopTest();

            System.assertNotEquals(null, deliveryOrderIds, 'L’utilisateur Sales doit pouvoir créer une livraison');
        }
    }
}
