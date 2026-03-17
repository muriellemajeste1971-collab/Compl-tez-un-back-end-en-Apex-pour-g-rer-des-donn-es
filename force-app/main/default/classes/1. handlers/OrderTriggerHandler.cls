public with sharing class OrderTriggerHandler {

    public static void run() {

        if(Trigger.isBefore && Trigger.isInsert) {
            OrderService.validateOrderBeforeInsert(Trigger.new);
        }

        if(Trigger.isBefore && Trigger.isUpdate) {
            OrderService.validateOrderBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }

        if(Trigger.isBefore && Trigger.isDelete) {
            OrderService.validateOrderBeforeDelete(Trigger.old);
        }
    }
}
