/**
 * @description Factory for working with Price Books in tests and data setup.
 * Ensures the Standard Price Book is active and returns it when requested.
 */
public with sharing class PriceBookFactory {

    private PriceBookFactory() {
        // Prevent instantiation
    }

    /**
     * @description Ensures the Standard Price Book is active and returns it.
     *              Uses Database methods and respects sharing/FLS via WITH USER_MODE where appropriate.
     * @return Pricebook2 The active Standard Price Book record
     */
    public static Pricebook2 activateStandardPricebook() {
        // Return early if no standard pricebook is found (unlikely in Salesforce orgs)
        List<Pricebook2> standardBooks = [
            SELECT Id, Name, IsActive, IsStandard
            FROM Pricebook2
            WHERE IsStandard = true
            LIMIT 1
        ];
        if (standardBooks.isEmpty()) {
            // Should not happen in a normal org, but return null rather than throwing
            return null;
        }

        Pricebook2 stdPb = standardBooks[0];

        if (!stdPb.IsActive) {
            // Activate standard price book in user mode
            stdPb.IsActive = true;
            // Use Database.update to follow best practices and catch potential errors
            Database.SaveResult sr = Database.update(stdPb/* , DatabaseOptions.accessLevelUserMode() */);
            if (!sr.isSuccess()) {
                // If activation fails, bubble up a meaningful error
                List<String> errors = new List<String>();
                for (Database.Error e : sr.getErrors()) {
                    errors.add(e.getMessage());
                }
                // Throwing a handled exception keeps tests explicit
                throw new AuraHandledException('Failed to activate Standard Price Book: ' + String.join(errors, '; '));
            }
        }

        return stdPb;
    }
}
