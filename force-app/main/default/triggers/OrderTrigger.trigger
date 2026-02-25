trigger OrderTrigger on Order (after insert, after update) {

    // On boucle sur les commandes concernées
    for (Order ord : Trigger.new) {

        // On appelle l'orchestrateur pour chaque commande
        TransporterOrchestrator.getAllTransporters(ord.Id);
    }
}
