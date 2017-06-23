public without sharing class HubUtil {
	public static void entry(TriggerParams triggerParams) {
        List<Hub_building_site__c> triggerNew = (List<Hub_building_site__c>)triggerParams.triggerNew;
        List<Hub_building_site__c> triggerOld = (List<Hub_building_site__c>)triggerParams.triggerOld;
        Map<Id, Hub_building_site__c> oldMap = (Map<Id, Hub_building_site__c>)triggerParams.oldMap;
        Map<Id, Hub_building_site__c> newMap = (Map<Id, Hub_building_site__c>)triggerParams.newMap;
        if (triggerParams.isAfter){
          if (triggerParams.isUpdate || triggerParams.isInsert) {
           shareToForceUsers(newMap);
          }
        }
    }
    public static void shareToForceUsers (Map <Id, Hub_building_site__c> locById){
        List <Hub_building_site__c> tickets = [select Id, Project__r.Account__c , OwnerId 
                                            from Hub_building_site__c where id in: locById.keySet() ];
        Set <Id> accIds = new Set <Id>();
        for (Hub_building_site__c t: tickets) {
            if (t.Project__r.Account__c != null) {
                accIds.add(t.Project__r.Account__c);
            }
        }
        System.debug('accs '+ accIds);
        List <User> users = [select Id, isActive from User where AccountId__c in :accIds and isActive = true];
        Map <Id, User> userById = new Map <Id, User>(users);
        System.debug('users' + users.size() + ' '  + users);
        List <Hub_building_site__Share> sharingTicket = [SELECT  ParentId, Id, UserOrGroupId 
                                                FROM Hub_building_site__Share where ParentId in: locById.keySet()  ];
        System.debug(sharingTicket.size() + ' ' + sharingTicket);
        Map <Id, Map<Id, Hub_building_site__Share>> shareByUserByTicket = new Map <Id, Map<Id, Hub_building_site__Share>>();
        for (Hub_building_site__Share sh: sharingTicket) {
            if (shareByUserByTicket.containsKey(sh.ParentId)) {
                shareByUserByTicket.get(sh.ParentId).put(sh.UserOrGroupId, sh);
            } else {
                Map <Id, Hub_building_site__Share> shByUser = new Map <Id, Hub_building_site__Share>();
                shareByUserByTicket.put(sh.ParentId, shByUser);
            }
        }
        System.debug('shareByUserByTicket' + shareByUserByTicket.size() + ' '  + shareByUserByTicket);
        List <Hub_building_site__Share> newSharings = new List <Hub_building_site__Share>();
        for (Hub_building_site__c t: tickets) {
            for (User u: users) {
                System.debug('shareByUserByTicket.get(t.id)' + shareByUserByTicket.get(t.id) + ' ' + u.id);
                if (!shareByUserByTicket.get(t.id).containsKey(u.Id) && t.OwnerId != u.id && u.isActive ) {
                    newSharings.add(new Hub_building_site__Share(ParentId = t.id, UserOrGroupId = u.Id, AccessLevel = 'Edit'));
                }
            }
        }
        System.debug('add sharings ' + newSharings.size() + ' ' + newSharings);
        insert newSharings;
    }
}