public with sharing class ContractFactory {

    public static List<Contract> assemble(Integer numberOfOrders, Integer numberOfProducts, List<Id> accountIds) {
    
        List<Contract> contracts = new List<Contract>();

            for (Id accId : accountIds) {
                
                for (Integer i = 0; i < numberOfOrders; i++) {

                    Contract c = new Contract(
                        Name = 'Contract ' + i,
                        ContractTerm = 12,
                        AccountId = accId,
                        StartDate = Date.today(),
                        Status = 'Draft'
                        );

                    contracts.add(c);
                }
            }

        return contracts;
    }
}