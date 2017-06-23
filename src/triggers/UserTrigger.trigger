trigger UserTrigger on User (after delete, after insert, after undelete, 
                  after update, before delete, before insert, before update) {

	ActiveTrigger__c aT = ActiveTrigger__c.getInstance('UserUtil');
	Boolean isActive = aT.isActive__c;

	if(isActive == true){
  		UserUtil.entry(new TriggerParams(trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                              trigger.isUndelete, trigger.new, trigger.old, trigger.newMap, trigger.oldMap));
	}

}