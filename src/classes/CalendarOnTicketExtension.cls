public with sharing class CalendarOnTicketExtension {
    public ComponentData componentData {get; set;}
    public CalendarOnTicketExtension(ApexPages.StandardController controller) {
        componentData = new ComponentData();
        Building_Ticket__c ticket = [select Id, Hub_Building_Site__c, Delivery_Date__c from Building_Ticket__c where id=:controller.getRecord().id ];
        componentData.hubSelected = ticket.Hub_Building_Site__c;

        String month = String.valueOf(ticket.Delivery_Date__c.month());
        String day = String.valueOf(ticket.Delivery_Date__c.day());
        if (month.length() == 1) {
        	month ='0'+month;
        }
        if (day.length() == 1) {
        	day ='0'+day;
        }
        componentData.dateSelected = String.valueOf(ticket.Delivery_Date__c.year()+'-'+month+'-'+day);
    }

}