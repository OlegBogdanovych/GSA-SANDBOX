public with sharing class ApprovingExtension {
	public ApprovingExtension() {
		
	}
	public Building_Ticket__c ticket {get;set;}
	public ApprovingExtension(ApexPages.StandardController controller) {
		ticket = [select Id, Status__c, Hub_Building_Site__c, Arrival_Time__c from Building_Ticket__c where id=: controller.getRecord().id];
		ticket.Status__c = 'Assigned';
		update ticket;
	}
	public pageReference runScript() {
		return new PageReference('/apex/Calendar?id='+ticket.Hub_Building_Site__c+'&dateFrom='+ticket.Arrival_Time__c);
	}
}