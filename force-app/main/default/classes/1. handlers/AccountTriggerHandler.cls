public with sharing class AccountTriggerHandler {
   
    public static void run() {

        if(Trigger.isBefore && Trigger.isInsert) {
            AccountDomain.validateAccountBeforeInsert(Trigger.new);
        }

        if(Trigger.isBefore && Trigger.isUpdate) {
            AccountDomain.validateAccountBeforeUpdate((Map<Id, Account>)Trigger.oldMap, (Map<Id, Account>)Trigger.newMap);
        }

    }
}