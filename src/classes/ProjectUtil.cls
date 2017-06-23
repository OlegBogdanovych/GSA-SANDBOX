public class ProjectUtil {
    public static void entry(TriggerParams triggerParams) {
        List <Projecten__c> triggerNew = (List<Projecten__c>)triggerParams.triggerNew;
        List <Projecten__c> triggerOld = (List<Projecten__c>)triggerParams.triggerOld;
        Map <Id, Projecten__c> oldMap = (Map<Id, Projecten__c>)triggerParams.oldMap;
        Map <Id, Projecten__c> newMap = (Map<Id, Projecten__c>)triggerParams.newMap;


        if (triggerParams.isBefore){
            if (triggerParams.isUpdate || triggerParams.isInsert) {
                checkName(triggerNew);
            }
            if (triggerParams.isDelete) {
                calculateRollupSum(new List <Projecten__c>(), triggerOld);
            }
        } else if ( triggerParams.isAfter){
            if (triggerParams.isUpdate || triggerParams.isInsert) {
                addShares(newMap.keySet());
                calculateRollupSum(triggerNew, triggerOld);
            }

            if( triggerParams.isDelete )
            {
                deleteReportData(triggerOld);
            }
        }
    }
    
    public static void deleteReportData(List<Projecten__c> triggerOld)
    {
        Set<Id> projectIds = new Set<Id>();
        for(Projecten__c pr : triggerOld)
        {
            projectIds.add(pr.Id);
        }

        List<ProjectLocation__c> projectLocations = [Select Project__c, Location__c from ProjectLocation__c where Project__c in :projectIds];
        if( null != projectLocations && !projectLocations.isEmpty() )
        {
            delete projectLocations;
        }
    }

    public static void calculateRollupSum(List<Projecten__c> newPr, List <Projecten__c> oldPr){
       System.debug(newPr);
        Set <Id> accIds = new Set <Id>();

        for (Projecten__c pr: newPr) {
            accIds.add(pr.Account__c);
        }
        if (oldPr!= null) {
            for (Projecten__c  pr: oldPr) {
                accIds.add(pr.Account__c);
            }
        }
        
        Map<Id, Account> accById = new Map <Id, Account>([select Id, Actueel_aantal_palletplaatsen1__c 
                                                        from Account where id in: accIds]);
        for (Projecten__c  pr: newPr) {
            if (accById.get(pr.Account__c).Actueel_aantal_palletplaatsen1__c == null) {
                accById.get(pr.Account__c).Actueel_aantal_palletplaatsen1__c = 0;
            }
            
        }
        for (Projecten__c  pr: newPr) {
            if (pr.Actueel_aantal_palletplaatsen__c!= null) {
                accById.get(pr.Account__c).Actueel_aantal_palletplaatsen1__c  += pr.Actueel_aantal_palletplaatsen__c;
            }
            
        }

        if (newPr.size() == 0) {
            for (Projecten__c  oldP: oldPr) {
                
                if (oldP.Actueel_aantal_palletplaatsen__c != null ) {
                    accById.get(oldP.Account__c).Actueel_aantal_palletplaatsen1__c -= oldP.Actueel_aantal_palletplaatsen__c;
                }
            }
        }
        System.debug(accById.values());
        update accById.values();
       
    }
    public static void checkName(List <Projecten__c> projects) {
        Set <String> names = new Set <String>();
        for (Projecten__c p: projects) {
            names.add(p.Name);
        }
        List <Projecten__c> oldprojects = [select Name from Projecten__c where Name in: names];
        Map<string, Projecten__c> byName = new Map <String, Projecten__c>();
        for (Projecten__c pr: oldprojects ) {
            byName.put(pr.Name, pr);
        }
        for (Projecten__c p: projects) {
           if (byName.containsKey(p.Name) && p.id !=  byName.get(p.Name).id) {
               System.debug('p'+p);
               System.debug(byName.get(p.Name));
                p.addError(Label.Unique);
            }
        }
        
    }
    @future
    public static void addShares(Set<Id> projectsIds) {
        List <Projecten__c>  projects = [select Id, Account__c from Projecten__c where id in: projectsIds];
        Set <Id> accIds = new Set <Id>();
        Set <Id> prIds = new Set <Id>();
        for (Projecten__c pr: projects) {
            prIds.add(pr.id);
            accIds.add(pr.Account__c);
        }
        List <User> users = [select Id, AccountId__c from User where AccountId__c in :accIds and isActive = true];
        Map <Id, List <User>> userByAccId = new Map <Id, List<User>>();
        Set <Id> usersIds = new Set <Id>();
        for (User u: users) {
            if (userByAccId.containsKey(u.AccountId__c)) {
                userByAccId.get(u.AccountId__c).add(u);
            } else {
                userByAccId.put(u.AccountId__c, new List <User>{u});
            }
            usersIds.add(u.id);
        }
        List <Projecten__Share> shares = [select Id from Projecten__Share where  ParentId in: prIds];
        try {
            Database.delete(shares, false );

        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        List <Projecten__Share> toInsert = new List <Projecten__Share>();
        for (Projecten__c pr: projects) {
            System.debug(userByAccId.get(pr.Account__c));
            if (userByAccId.containsKey(pr.Account__c)) {
                for (User user : userByAccId.get(pr.Account__c) ){
                    if (user != null){
                        Projecten__Share addShare = new Projecten__Share(UserOrGroupId = user.id, ParentId = pr.id, AccessLevel = 'Edit');
                        toInsert.add(addShare); 
                    } 
                }
            }
        }
        insert toInsert;
        System.debug('toInsert ' +toInsert);
    }
}