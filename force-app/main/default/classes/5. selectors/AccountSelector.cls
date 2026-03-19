public with sharing class AccountSelector {

    /**
     * Returns Accounts for the provided Ids.
     * - Bulkified: handles empty and large input lists safely
     * - Uses WITH USER_MODE to enforce user permissions
     */
    public static List<Account> getAccountsByIds(List<Id> accountIds) {
        // Return early on null/empty to avoid unnecessary SOQL
        if (accountIds == null || accountIds.isEmpty()) {
            return new List<Account>();
        }
        // Deduplicate to keep query selective and under limits
        Set<Id> idSet = new Set<Id>(accountIds);

        return [
            SELECT Id, Name, Type, Customer_Type__c, ShippingCountry
            FROM Account
            WHERE Id IN :idSet
            WITH USER_MODE
        ];
    }
}
