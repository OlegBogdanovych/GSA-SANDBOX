public without sharing class BuildingTicketUtil {
    public BuildingTicketUtil() {
        
    }
    public static void entry(TriggerParams triggerParams) {
        List<Building_Ticket__c> triggerNew = (List<Building_Ticket__c>)triggerParams.triggerNew;
        List<Building_Ticket__c> triggerOld = (List<Building_Ticket__c>)triggerParams.triggerOld;
        Map<Id, Building_Ticket__c> oldMap = (Map<Id, Building_Ticket__c>)triggerParams.oldMap;
        Map<Id, Building_Ticket__c> newMap = (Map<Id, Building_Ticket__c>)triggerParams.newMap;


        if (triggerParams.isBefore){
            if ( triggerParams.isInsert) {
                setName(triggerNew);
            }
        } else if (triggerParams.isAfter ){
            if (triggerParams.isUpdate || triggerParams.isInsert) {
                shareToForceUsers(newMap);
            }
        }
    }
    public static void setName (List <Building_Ticket__c> tickets) {
        List <UniqueNumber__c> uniqueNumbers = [select Name, Number__c from UniqueNumber__c];
        if (uniqueNumbers.size() == 0) {
            UniqueNumber__c unForToday = new UniqueNumber__c();
            unForToday.Name = String.valueOf(date.today().year()+'-'+date.today().month()+'-'+date.today().day());
            unForToday.Number__c = '1';
            insert unForToday;
        } else {
            if (uniqueNumbers.get(0).Name == String.valueOf(date.today().year()+'-'+date.today().month()+'-'+date.today().day())) {
                uniqueNumbers.get(0).Number__c = String.valueOf(Integer.valueOf(uniqueNumbers.get(0).Number__c) + 1);
                
            } else {
                uniqueNumbers.get(0).Number__c = '1';
                uniqueNumbers.get(0).Name = String.valueOf(date.today().year()+'-'+date.today().month()+'-'+date.today().day());
            }
            update uniqueNumbers;
        }
        uniqueNumbers = [select Name, Number__c from UniqueNumber__c];
        Set <Id> hubsIds = new Set <Id>();
        for (Building_Ticket__c ticket : tickets) {
            hubsIds.add(ticket.Hub_Building_Site__c);
        }
        Map <Id, Hub_Building_Site__c> hubsById = new Map <Id, Hub_Building_Site__c>([select Id, Name from Hub_Building_Site__c where id in: hubsIds]);
        
        for (Building_Ticket__c ticket : tickets) {
            ticket.Requestor__c = UserInfo.getUserId();
            //ticket.Name = hubsById.get(ticket.Hub_Building_Site__c).Name;
            
            //ticket.Name += ', '+uniqueNumbers.get(0).Number__c;
            //System.debug(ticket.Name);
        }
    }
    public static void shareToForceUsers (Map <Id, Building_Ticket__c> ticketsById){
        List <Building_Ticket__c> tickets = [select Id, Hub_Building_Site__r.Project__r.Account__c , OwnerId, Account__r.Id__c, Account__c 
                                            from Building_Ticket__c where id in: ticketsById.keySet() ];
        Set <Id> accIds = new Set <Id>();
        for (Building_Ticket__c t: tickets) {
            if (t.Hub_Building_Site__r.Project__r.Account__c != null){
                accIds.add(t.Hub_Building_Site__r.Project__r.Account__c);
            }

            if (t.Account__c != null){
                accIds.add(t.Account__r.Id__c);
            }
        }
        System.debug('accs '+ accIds);
        List <User> users = [select Id from User where AccountId__c in :accIds and IsActive = true];
        System.debug('users' + users.size() + ' '  + users);
        List <Building_Ticket__Share> sharingTicket = [SELECT  ParentId, Id, UserOrGroupId 
                                                FROM Building_Ticket__Share where ParentId in: ticketsById.keySet()  ];
        System.debug(sharingTicket.size() + ' ' + sharingTicket);
        Map <Id, Map<Id, Building_Ticket__Share>> shareByUserByTicket = new Map <Id, Map<Id, Building_Ticket__Share>>();
        for (Building_Ticket__Share sh: sharingTicket) {
            if (shareByUserByTicket.containsKey(sh.ParentId)) {
                shareByUserByTicket.get(sh.ParentId).put(sh.UserOrGroupId, sh);
            } else {
                Map <Id, Building_Ticket__Share> shByUser = new Map <Id, Building_Ticket__Share>();
                shareByUserByTicket.put(sh.ParentId, shByUser);
            }
        }
        System.debug('shareByUserByTicket' + shareByUserByTicket.size() + ' '  + shareByUserByTicket);
        List <Building_Ticket__Share> newSharings = new List <Building_Ticket__Share>();
        for (Building_Ticket__c t: tickets) {
            for (User u: users) {
                System.debug('shareByUserByTicket.get(t.id)' + shareByUserByTicket.get(t.id) + ' ' + u.id);
                if (!shareByUserByTicket.get(t.id).containsKey(u.Id) && t.OwnerId != u.id) {
                    newSharings.add(new Building_Ticket__Share(ParentId = t.id, UserOrGroupId = u.Id, AccessLevel = 'Edit'));
                }
            }
        }
        System.debug('add sharings ' + newSharings.size() + ' ' + newSharings);
        insert newSharings;
    }
}