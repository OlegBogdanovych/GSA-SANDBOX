public with sharing class LocationUtil {
    public static void entry(TriggerParams triggerParams) {
        List<Location__c> triggerNew = (List<Location__c>)triggerParams.triggerNew;
        List<Location__c> triggerOld = (List<Location__c>)triggerParams.triggerOld;
        Map<Id, Location__c> oldMap = (Map<Id, Location__c>)triggerParams.oldMap;
        Map<Id, Location__c> newMap = (Map<Id, Location__c>)triggerParams.newMap;

      
        
        if (triggerParams.isAfter){
          if (triggerParams.isUpdate || triggerParams.isInsert) {
            updateParentLocations(triggerNew);
            shareToForceUsers(newMap);
          }

          if (triggerParams.isUpdate) {
            recalculateLocationsCount(triggerNew, oldMap);
          }
          if (triggerParams.isDelete) {
            updateParentLocations(triggerOld);
            Set <Id> parentLocationIds = new Set <Id>();
            for (Location__c loc: triggerOld) {
                if (loc.Parent_Location__c != null) {
                    parentLocationIds.add(loc.Parent_Location__c);
                }
            }
          updateParentLocationsNoChild(parentLocationIds);

          }
        }
    }
    public static void shareToForceUsers (Map <Id, Location__c> locById){
        List <Location__c> tickets = [select Id, Hub_Building_Site__r.Project__r.Account__c , OwnerId, Hub_Building_Site__c 
                                            from Location__c where id in: locById.keySet() ];
        Set <Id> hubIds = new Set <Id>();
        for (Location__c loc: tickets) {
            hubIds.add(loc.Hub_building_Site__c);
        }                                   
        List <AccountHUb__c> accHubs = [select Id, Account__c from AccountHub__c where Hub_Building_Site__c in: hubIds];
        Set <Id> accIds1 = new Set <Id>();
        for (AccountHub__c acH: accHubs){
            accIds1.add(acH.account__c);
        }
        Set <Id> accIds = new Set <Id>();
        for (Location__c t: tickets) {
            if (t.Hub_Building_Site__r.Project__r.Account__c != null) {
                accIds.add(t.Hub_Building_Site__r.Project__r.Account__c);
            }
        }
        accIds.addAll(accIds1);
        System.debug('accs '+ accIds);
        List <User> users = [select isActive, Id from User where AccountId__c in :accIds and isActive = true];
        Map <Id, User> userById = new Map <Id, User>(users);
        System.debug('users' + users.size() + ' '  + users);
        List <Location__Share> sharingTicket = [SELECT  ParentId, Id, UserOrGroupId 
                                                FROM Location__Share where ParentId in: locById.keySet()  ];
        System.debug(sharingTicket.size() + ' ' + sharingTicket);
        Map <Id, Map<Id, Location__Share>> shareByUserByTicket = new Map <Id, Map<Id, Location__Share>>();
        for (Location__Share sh: sharingTicket) {
            if (shareByUserByTicket.containsKey(sh.ParentId)) {
                shareByUserByTicket.get(sh.ParentId).put(sh.UserOrGroupId, sh);
            } else {
                Map <Id, Location__Share> shByUser = new Map <Id, Location__Share>();
                shareByUserByTicket.put(sh.ParentId, shByUser);
            }
        }
        System.debug('shareByUserByTicket' + shareByUserByTicket.size() + ' '  + shareByUserByTicket);
        List <Location__Share> newSharings = new List <Location__Share>();
        for (Location__c t: tickets) {
            for (User u: users) {
                System.debug('shareByUserByTicket.get(t.id)' + shareByUserByTicket.get(t.id) + ' ' + u.id);
                if (!shareByUserByTicket.get(t.id).containsKey(u.Id) && t.OwnerId != u.id && u.isActive) {
                    newSharings.add(new Location__Share(ParentId = t.id, UserOrGroupId = u.Id, AccessLevel = 'Read'));
                }
            }
        }
        System.debug('add sharings ' + newSharings.size() + ' ' + newSharings);
        insert newSharings;
    }
    
    public static void updateParentLocations(List <Location__c> locations) {
        Set <Id> parentLocationIds = new Set <Id>();
        for (Location__c loc: locations) {
            if (loc.Parent_Location__c != null) {
                parentLocationIds.add(loc.Parent_Location__c);
            }
        }
        Map <Id, Location__c> parentLocations = new Map <Id, Location__c>([Select Id from Location__c where id in: parentLocationIds]);
        List<WWW_Detail__c> wwwDs = [SELECT Id, RecordType.DeveloperName, Location__c, Number_Of_Items__c FROM WWW_Detail__c 
                                    where (RecordType.DeveloperName = 'Delivered_2_Hub' OR RecordType.DeveloperName = 'Delivered_2_Project')
                                            and Location__c in :parentLocationIds and IsDeleted = false];

        Map<Id, List<WWW_Detail__c>> delToHubByLocationId = new Map<Id, List<WWW_Detail__c>>();
        Map<Id, List<WWW_Detail__c>> delToProjectByLocationId = new Map<Id, List<WWW_Detail__c>>();
        if( wwwDs != null && !wwwDs.isEmpty() ) {
            for(WWW_Detail__c wwwD : wwwDs) {
                if( wwwD.RecordType.DeveloperName == 'Delivered_2_Hub' ) {
                    if( delToHubByLocationId.get(wwwD.Location__c) == null ) {
                        delToHubByLocationId.put(wwwD.Location__c, new List<WWW_Detail__c>());
                    }
                    delToHubByLocationId.get(wwwD.Location__c).add(wwwD);
                }

                if( wwwD.RecordType.DeveloperName == 'Delivered_2_Project' ) {
                    if( delToProjectByLocationId.get(wwwD.Location__c) == null ) {
                        delToProjectByLocationId.put(wwwD.Location__c, new List<WWW_Detail__c>());
                    }
                    delToProjectByLocationId.get(wwwD.Location__c).add(wwwD);
                }
            }
        }

        for(Location__c parent: parentLocations.values()) {
            parent.Current_amount__c = 0;
            if( delToHubByLocationId.get(parent.Id) != null ) {
                for(WWW_Detail__c wwwD : delToHubByLocationId.get(parent.Id) ) {
                    parent.Current_amount__c += wwwD.Number_Of_Items__c;
                }
            }

            parent.Available_amount__c = 0;
            if( delToProjectByLocationId.get(parent.Id) != null ) {
                for(WWW_Detail__c wwwD : delToProjectByLocationId.get(parent.Id) ) {
                    parent.Available_amount__c += wwwD.Number_Of_Items__c;
                }
            }
        }

        System.debug('parentLocations ' + parentLocations.size() + ' ' + parentLocations);
        update parentLocations.values();
        //List <Location__c> childLocations = [select Id, Current_amount__c, Available_amount__c , Parent_Location__c from Location__c where Parent_Location__c in: parentLocationIds];
        //Map <Id, Decimal> sumByParentId = new Map <Id, Decimal>();
        //Map <Id, Decimal> sumRedByParentId = new Map <Id, Decimal>();
        //for (Location__c loc: childLocations) {
        //    if (loc.Current_amount__c == null) {
        //        loc.Current_amount__c = 0;
        //    }
        //    if (sumByParentId.containsKey(loc.Parent_Location__c)) {
        //        if (loc.Current_amount__c != null) {
        //            sumByParentId.put(loc.Parent_Location__c, sumByParentId.get(loc.Parent_Location__c)+loc.Current_amount__c);
        //        }
        //    } else {
        //         if (loc.Current_amount__c != null) {
        //            sumByParentId.put(loc.Parent_Location__c, loc.Current_amount__c);
        //            }
        //    }
        //    if (sumRedByParentId.containsKey(loc.Parent_Location__c)) {
        //        if (loc.Available_amount__c != null) {
        //            sumRedByParentId.put(loc.Parent_Location__c, sumRedByParentId.get(loc.Parent_Location__c)+loc.Available_amount__c);
        //        }
        //    } else {
        //        if (loc.Available_amount__c != null) {
        //            sumRedByParentId.put(loc.Parent_Location__c, loc.Available_amount__c);
        //        }
        //    }
        //}
        //for (Location__c parent: parentLocations.values()) {
        //    if (sumByParentId.containsKey(parent.Id)) {
        //        parent.Current_amount__c = sumByParentId.get(parent.Id);
        //        parent.Available_amount__c = sumRedByParentId.get(parent.id);
        //    }

        //}
        //System.debug('parentLocations ' + parentLocations.size() + ' ' + parentLocations);
        //update parentLocations.values();

    }

    public static void recalculateLocationsCount(List<Location__c> triggerNew, Map<Id, Location__c> oldMap)
    {
        Set<Id> locationIdsTorecalculate = new Set<Id>();
        List<Location__c> locationsToRecalculate = new List<Location__c>();

        for(Location__c loc : triggerNew)
        {
            Location__c oldLoc = oldMap.get(loc.Id);
            if( oldLoc != null )
            {
                if( oldLoc.Occupied__c != loc.Occupied__c )
                {
                    locationIdsTorecalculate.add(loc.Id);
                    locationsToRecalculate.add(loc);
                }
            }
        }

        List<SublocationDetail__c> subLocDetails = [Select Id, Name, Location__c, Location__r.Occupied__c, Location__r.Parent_Location__c, WWW_Detail__c from SublocationDetail__c 
                                                            where Location__c in :locationIdsTorecalculate];

        SubLocationDetailUtil.calculateSublocationsForProject(subLocDetails);
    }

    @future
    public static void updateParentLocationsNoChild (Set <Id> locations) {
        Map <Id, Location__c> parentLocations = new Map <Id, Location__c>([Select Id, Name, Current_amount__c from Location__c where id in: locations]);
        List <Location__c> childLocations =  new List <Location__c>([select Id, Name, Current_amount__c, Available_amount__c , Parent_Location__c from Location__c where Parent_Location__c in: locations]);
        List <Location__c> toUpdate = new List<Location__c>();
        List <Id> toSkipIds = new List<Id>();
        for(Location__c loc : childLocations){
            if(loc.Parent_Location__c != null){
                toSkipIds.add(loc.Parent_Location__c);
            }
        }
        Map <Id, Location__c> toSkip = new Map <Id, Location__c>([Select Id, Name, Current_amount__c from Location__c where id in: toSkipIds]);
        for(Id skip : toSkip.keySet()){
            if(parentLocations.containsKey(skip)){
                parentLocations.remove(skip);
            }
        }
        for(Location__c loc2Up : parentLocations.values()){

            loc2Up.Current_amount__c = null;
            toUpdate.add(loc2Up);
        }
        update toUpdate;
    }

}