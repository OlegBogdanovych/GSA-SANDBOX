public with sharing class CalendarExtension {
    public Building_Ticket__c ticket {get; set;}
    public String dateFromStr {get; set;}
    public CalendarExtension () {
    }
    public ComponentData componentData {get; set;}
    public CalendarExtension(ApexPages.StandardController controller) {
     
        /*ticket = (Building_Ticket__c)[select Id, Location__c, Delivery_Date__c, Arrival_Time__c,
                                        Loading_And_Unloading_Time__c, Gate__c, Hub_Building_Site__c, End_Point__c, 
                                        Description_Of_Delivery__c, Vertical_Transport__c
                                    from Building_Ticket__c where Id =: controller.getRecord().Id];

        dateFromStr = String.valueOf(ticket.Delivery_Date__c.year()) + '-' + String.valueOf(ticket.Delivery_Date__c.month()) + 
            '-'+String.valueOf(ticket.Delivery_Date__c.day());*/
        componentData = new ComponentData();
        componentData.hubSelected = controller.getRecord().id;
    }
    
   

    
    
  

}