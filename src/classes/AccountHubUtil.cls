public class AccountHubUtil {
    public static void entry(TriggerParams triggerParams) {
        List<AccountHub__c> triggerNew = (List<AccountHub__c>)triggerParams.triggerNew;
        List<AccountHub__c> triggerOld = (List<AccountHub__c>)triggerParams.triggerOld;
        Map<Id, AccountHub__c> oldMap = (Map<Id, AccountHub__c>)triggerParams.oldMap;
        Map<Id, AccountHub__c> newMap = (Map<Id, AccountHub__c>)triggerParams.newMap;
        if (triggerParams.isAfter && triggerParams.isInsert) {
            addSharings(triggerNew );
        }
        if (triggerParams.isBefore && triggerParams.IsDelete){
            deleteSharings(triggerOld);
        }
        
    }
    public static void deleteSharings (List<AccountHub__c> accHubs) {
        Set <Id> hubIds = new Set <Id>();
        Set <Id> accIds = new Set <Id>();
        for (AccountHub__c accHub:accHubs ) {
            hubIds.add(accHub.Hub_building_site__c );
            accIds.add(accHub.Account__c);
        }
        Map<Id, Hub_Building_Site__c> hubs = new Map <Id, Hub_building_site__c>([select Id from Hub_building_site__c where id in : hubIds]);
        Map<Id, User> users = new Map <Id, User>([select Id from User where Accountid__c in : accIds]);
        Map<Id, Location__c> locs = new Map <Id, Location__c>([select Id from Location__c where Hub_building_site__c  in : hubIds]);
        List<Hub_Building_Site__Share> hubShares = [select Id, ParentId from Hub_Building_Site__Share where UserOrGroupId in: users.keyset() and ParentId  in: hubIds and AccessLevel != 'All'];
        delete hubShares;
        List<Location__Share> locShares = [select Id, ParentId from Location__Share where UserOrGroupId in: users.keyset() and ParentId  in: locs.keyset() and AccessLevel != 'All'];
        delete locShares;
      
      try {
        delete hubShares;
      } catch(Exception e) {
          System.debug(e.getMessage());
      }
    }
    public static void addSharings (List<AccountHub__c> accHubs) {
        Set <Id> hubIds = new Set <Id>();
        Set <Id> accIds = new Set <Id>();
        for (AccountHub__c accHub:accHubs ) {
            hubIds.add(accHub.Hub_building_site__c );
            accIds.add(accHub.Account__c);
        }
        List <Hub_building_site__c> sites = [select Id, Project__r.Account__c , OwnerId 
                                            from Hub_building_site__c where id in: hubIds];
       
        
        System.debug('accs '+ accIds);
        List <User> users = [select Id, isActive from User where AccountId__c in :accIds and isActive = true];
        Map <Id, User> userById = new Map <Id, User>(users);
        System.debug('users' + users.size() + ' '  + users);
        List <Hub_building_site__Share> sharingTicket = [SELECT  ParentId, Id, UserOrGroupId 
                                                FROM Hub_building_site__Share where ParentId in:hubIds ];
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
        for (Hub_building_site__c t: sites ) {
            for (User u: users) {
                System.debug('shareByUserByTicket.get(t.id)' + shareByUserByTicket.get(t.id) + ' ' + u.id);
                if (!shareByUserByTicket.get(t.id).containsKey(u.Id) && t.OwnerId != u.id && u.isActive ) {
                    newSharings.add(new Hub_building_site__Share(ParentId = t.id, UserOrGroupId = u.Id, AccessLevel = 'Edit'));
                }
            }
        }
        System.debug('add sharings ' + newSharings.size() + ' ' + newSharings);
        insert newSharings;
        Map <Id, Location__c> locations = new Map <Id, Location__c>([select Id, Name from Location__c 
                                                                              where Hub_Building_Site__c in: hubIDs]);
      List< Location__Share> locShares = [select Id, ParentId from Location__Share where UserOrGroupId in: userById.keyset() and ParentId in : locations.keyset() and AccessLevel != 'All'];
     delete locShares;
      
      List <Location__Share> addLocShare = new List <Location__Share>();
      for (Location__c t: locations.values()  ) {
          for (User us: users) {
            Location__Share sh = new Location__Share(ParentId = t.id, UserOrGroupId = us.id,AccessLevel = 'Edit' );
            addLocShare.add(sh);
        }
      }
      insert addLocShare;
    }
    
}