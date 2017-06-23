public with sharing class TicketPDFExtension {
    public Building_Ticket__c ticket {get; set;}
    public String excpectedDateTime {get;set;}
    public String excpectedTime {get;set;}
    public User user {
        get {
            if (user == null) {
                user = new User();
            }
            return user;
        } set;
    }
    public TicketPDFExtension(ApexPages.StandardController controller) {
        ticket = (Building_Ticket__c)[SELECT Arrival_Time__c, Content_Delivery__c, CreatedById, CreatedDate, IsDeleted, 
                                            Delivery_Date__c, Description_Of_Activity__c, Description_Of_Delivery__c, Account__r.Name,Account__c,
                                            End_Point__c, Gate__c, Gate__r.Name, Hub_Building_Site__c, LastActivityDate, LastModifiedById,
                                            LastModifiedDate, Loading_And_Unloading_Time__c, Location__c, Location__r.Name, Name, OwnerId, Id, 
                                            Requestor__c, Status__c, SystemModstamp, Vertical_Transport__c, Vertical_Transport__r.Name, 
                                            Hub_Building_Site__r.City__c, Hub_Building_Site__r.Postalcode__c, Requestor__r.Name,
                                            Hub_Building_Site__r.Street__c, Hub_Building_Site__r.Name, Number__c, Hub_Building_Site__r.telefoonnummer_contactpersoon_bouwplaats__c,
                                            Hub_Building_Site__r.RecordType.Name, UserId__c, Projectmember__c, Projectmember__r.Name
                                    FROM Building_Ticket__c where Id =: controller.getRecord().Id];
        if (ticket.Arrival_Time__c!= null && ticket.Loading_And_Unloading_Time__c != null) {
            excpectedDateTime = String.valueOf(ticket.Arrival_Time__c.addMinutes(Integer.valueOf(ticket.Loading_And_Unloading_Time__c)).hour())
            +':' +String.valueOf(ticket.Arrival_Time__c.addMinutes(Integer.valueOf(ticket.Loading_And_Unloading_Time__c)).minute());
            
            excpectedTime =  String.valueOf(ticket.Arrival_Time__c.hour())+':'+ String.valueOf(ticket.Arrival_Time__c.minute());
        }
        if (excpectedDateTime.contains(':') && excpectedDateTime.indexOf(':') != excpectedDateTime.length() - 3) {
            excpectedDateTime+='0';
        }
        if (excpectedTime.contains(':') && excpectedTime.indexOf(':') != excpectedTime.length() - 3) {
            excpectedTime +='0';
        }
        if (ticket.UserId__c != null) {
            user = [select Id, Name from User where Id=:ticket.UserId__c ];
        }

    }
}