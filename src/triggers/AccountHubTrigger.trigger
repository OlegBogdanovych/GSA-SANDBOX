trigger AccountHubTrigger on AccountHub__c (after delete, after insert, after undelete, 
                                    after update, before delete, before insert, before update) {

	ActiveTrigger__c aT = ActiveTrigger__c.getInstance('AccountHubUtil');
	Boolean isActive = aT.isActive__c;

	if (isActive == true){

    AccountHubUtil.entry(new TriggerParams(trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                                            trigger.isUndelete, trigger.new, trigger.old, trigger.newMap, trigger.oldMap));
    } 

}