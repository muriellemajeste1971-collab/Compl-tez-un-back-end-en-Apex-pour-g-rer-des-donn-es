trigger AccountTrigger on Account (before insert, before update) {
    
    AccountTriggerHandler.run();

}