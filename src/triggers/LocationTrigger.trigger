trigger LocationTrigger on Location__c (after delete, after insert, after undelete, 
                  after update, before delete, before insert, before update) {

	ActiveTrigger__c aT = ActiveTrigger__c.getInstance('LocationUtil');
	Boolean isActive = aT.isActive__c;
  		
  	if (isActive == true){
  		LocationUtil.entry(new TriggerParams(trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                              trigger.isUndelete, trigger.new, trigger.old, trigger.newMap, trigger.oldMap));  
  	}
}