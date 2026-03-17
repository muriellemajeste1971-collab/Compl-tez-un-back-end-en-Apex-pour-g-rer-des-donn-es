trigger OrderTrigger on Order (before insert, before update, before delete) {
    OrderTriggerHandler.run();
}
