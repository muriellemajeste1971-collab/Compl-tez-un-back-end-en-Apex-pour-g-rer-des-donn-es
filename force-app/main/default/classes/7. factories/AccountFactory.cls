public with sharing class AccountFactory {

    public static List<Account> assemble(Integer num, String customerType, String shippingCountry) {

        List<Account> accts = new List<Account>();

            for (Integer i = 1; i <= num; i++) {
                
                Account a = new Account( 
                    Name = 'Account ' + i,
                    Customer_Type__c  = customerType, 
                    ShippingCountry = shippingCountry);

                accts.add(a);
            }

        return accts;
    }
}