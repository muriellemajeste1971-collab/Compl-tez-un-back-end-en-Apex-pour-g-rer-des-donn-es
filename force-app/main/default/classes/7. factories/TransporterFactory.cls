public with sharing class TransporterFactory {
    public static List<Transporteur__c> assemble() {

        List<Transporteur__c> transporters = new List<Transporteur__c>();    
 
        Transporteur__c chrono = new Transporteur__c (Name = 'Chronopost', Customer_Type__c = 'Particulier, Professionnel');  
        Transporteur__c ups = new Transporteur__c (Name = 'UPS', Customer_Type__c = 'Particulier, Professionnel');
        Transporteur__c geodis = new Transporteur__c (Name = 'Geodis', Customer_Type__c = 'Particulier, Professionnel');
        Transporteur__c dhl = new Transporteur__c (Name = 'DHL Express', Customer_Type__c = 'Professionnel');    
        Transporteur__c gls = new Transporteur__c (Name = 'GLS', Customer_Type__c = 'Particulier');

        transporters.add(chrono);
        transporters.add(ups);
        transporters.add(geodis);
        transporters.add(dhl);
        transporters.add(gls);

        return transporters;

    }
}