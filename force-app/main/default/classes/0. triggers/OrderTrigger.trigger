trigger OrderTrigger on Order (before update, before delete) {
    OrderTriggerHandler.run();
}
