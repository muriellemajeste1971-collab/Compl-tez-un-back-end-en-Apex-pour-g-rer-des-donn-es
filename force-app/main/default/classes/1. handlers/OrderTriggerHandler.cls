public with sharing class OrderTriggerHandler {

    public static void run() {

        if(Trigger.isBefore && Trigger.isUpdate) {
            OrderService.validateBeforeUpdate(
                (Map<Id, Order>) Trigger.oldMap,
                (Map<Id, Order>) Trigger.newMap
            );
        }

        if(Trigger.isBefore && Trigger.isDelete) {
            OrderService.validateBeforeDelete(Trigger.old);
        }
    }
}
