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
            Account a = TestDataFactory.createAccount();
            Contract c = TestDataFactory.createContract(a.Id);
            Order o = TestDataFactory.createOrder(a.Id, c.Id);Transporteur__c tr = TestDataFactory.createTransporteur('Particulier');
		    List<Tarification__c> liste = TestDataFactory.createTarificationList();
            List<Tarification__c> result = TransporterOrchestrator.getAllTransporters(o.Id);
     
            Tarification__c fastest = result[0];
            Tarification__c cheapest = result[1];
            Tarification__c last = result[2];

            // L’utilisateur Sales doit pouvoir créer une livraison
            Id livId = OrderService.createLivraison(o.Id, fastest.Id);

            System.assertNotEquals(null, livId, 'L’utilisateur Sales doit pouvoir créer une livraison');
        }
    }
}
