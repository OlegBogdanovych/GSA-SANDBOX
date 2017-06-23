trigger SubLocationDetailTrigger on SubLocationDetail__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

	ActiveTrigger__c aT = ActiveTrigger__c.getInstance('SubLocationDetailUtil');
	Boolean isActive = aT.isActive__c;

	if(isActive == true){
		SubLocationDetailUtil.entry(new TriggerParams(trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                                            trigger.isUndelete, trigger.new, trigger.old, trigger.newMap, trigger.oldMap)); 
	}

}