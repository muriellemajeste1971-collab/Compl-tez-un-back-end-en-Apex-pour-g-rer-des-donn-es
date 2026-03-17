public with sharing class AccountDomain {

    public static void validateAccountBeforeInsert(List <Account> newList) { 

        for (Account accs : newList) {
            validateShippingCountry(accs);
        }

    }

    public static void validateAccountBeforeUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        
        for (Account accs : newMap.values()) {
            validateShippingCountry(accs);
        }
        
    }

    private static void validateShippingCountry(Account accs) {

        Set<String> allowedShippingCountry= new Set<String>{
            'France', 'FR', 'FRANCE', 'france', 'fr', 'france', 'fr',
            'Belgique', 'BE', 'BELGIQUE', 'belgique', 'be',
            'Luxembourg', 'LU', 'LUXEMBOURG', 'luxembourg', 'lu',
            'Suisse', 'CH', 'SUISSE', 'suisse', 'ch'
        };

        if (!allowedShippingCountry.contains(accs.ShippingCountry)) {
            accs.addError('Country must be France or FR, Belgique or BE, Luxembourg or LU, Suisse or CH');
            return;
        }

         switch on accs.ShippingCountry {
                        
            when 'France', 'FR', 'FRANCE', 'france', 'fr' {
                                accs.ShippingCountry = 'FR';
                }
                    
            when 'Belgique', 'BE', 'BELGIQUE', 'belgique', 'be' {
                                accs.ShippingCountry = 'BE';
                }
                    
            when 'Luxembourg', 'LU', 'LUXEMBOURG', 'luxembourg', 'lu' { 
                                accs.ShippingCountry = 'LU';
                }       
                    
            when 'Suisse', 'CH', 'SUISSE', 'suisse', 'ch' { 
                                accs.ShippingCountry = 'CH';
                }
        }
    
  }
       
     
}