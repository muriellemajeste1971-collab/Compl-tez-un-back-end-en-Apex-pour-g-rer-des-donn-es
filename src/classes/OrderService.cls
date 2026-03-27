public with sharing class OrderService {

    /**
     * Validates Orders before insert/update operations.
     * Bulkified: accepts a list of Order records.
     */
    public static void validateOrder(List<Order> orders) {
        if (orders == null || orders.isEmpty()) {
            return;
        }
        // Implement real validation or delegate to the force-app version if this file is packaged/deployed.
        // Keeping method signature aligned to avoid compile-time signature mismatches.
    }

    // TODO : Compléter la classe avec toute autre méthode nécessaire pour gérer la logique métier liée aux commandes

}
