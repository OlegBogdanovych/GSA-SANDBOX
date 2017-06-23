trigger HubTrigger on Hub_Building_Site__c (after delete, after insert, after undelete, 
                  after update, before delete, before insert, before update) {

	ActiveTrigger__c aT = ActiveTrigger__c.getInstance('HubUtil');
	Boolean isActive = aT.isActive__c;

	if (isActive == true){
  		HubUtil.entry(new TriggerParams(trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                              trigger.isUndelete, trigger.new, trigger.old, trigger.newMap, trigger.oldMap));  
	}

}