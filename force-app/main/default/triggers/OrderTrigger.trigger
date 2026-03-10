trigger OrderTrigger on Order (after insert, after update, before delete) {

    // --- AFTER INSERT / AFTER UPDATE ---
    if (Trigger.isInsert || Trigger.isUpdate) {

        List<Id> orderIdsToProcess = new List<Id>();

        for (Order ord : Trigger.new) {

            String accountType = ord.Account_Type__c;
            Decimal nbProduits = ord.Product_Number__c;

            if (nbProduits == null) nbProduits = 0;

            Boolean shouldProcess =
                (accountType == 'Particulier' && nbProduits >= 3) ||
                (accountType == 'Professionnel' && nbProduits >= 5);

            if (!shouldProcess) continue;

            // Sur update : éviter de recalculer si rien n’a changé
            if (Trigger.isUpdate) {
                Order oldOrd = Trigger.oldMap.get(ord.Id);

                Decimal oldNb = oldOrd.Product_Number__c;
                if (oldNb == null) oldNb = 0;

                if (oldOrd.Account_Type__c == accountType &&
                    oldNb == nbProduits) {
                    continue;
                }
            }

            orderIdsToProcess.add(ord.Id);
        }

        // appel orchestrateur uniquement pour les orders éligibles
        for (Id oid : orderIdsToProcess) {
            TransporterOrchestrator.getAllTransporters(oid);
        }
    }

    // --- BEFORE DELETE ---
    if (Trigger.isDelete) {
        for (Order ord : Trigger.old) {
            OrderService.deleteLivraisonsByOrder(ord.Id);
        }
    }
}
