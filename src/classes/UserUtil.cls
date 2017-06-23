public with sharing class UserUtil {
    public static void entry(TriggerParams triggerParams) {
        List<User> triggerNew = (List<User>)triggerParams.triggerNew;
        List<User> triggerOld = (List<User>)triggerParams.triggerOld;
        Map<Id, User> oldMap = (Map<Id, User>)triggerParams.oldMap;
        Map<Id, User> newMap = (Map<Id, User>)triggerParams.newMap;


        if (triggerParams.isAfter){
          if (triggerParams.isUpdate || triggerParams.isInsert) {
           Map <Id, Profile> profilesById = new Map <Id, Profile>([select Id from Profile 
                                                                    where Name = 'Bouwticket account' or Name = 'Bouwmanager']);
           System.debug('profilesById '+ profilesById);
           for(User user: triggerNew) {
                System.debug(user.ProfileId);
              System.debug(triggerParams.isUpdate && !profilesById.containsKey(oldMap.get(user.id).ProfileId ));
              System.debug(triggerParams.isUpdate && oldMap.get(user.Id).AccountId__c != newMap.get(user.Id).AccountId__c ) ;
                if ((triggerParams.isInsert 
                      || (triggerParams.isUpdate && !profilesById.containsKey(oldMap.get(user.id).ProfileId ) )
                      || (triggerParams.isUpdate && oldMap.get(user.Id).AccountId__c != newMap.get(user.Id).AccountId__c )
                      || (triggerParams.isUpdate && oldMap.get(user.Id).IsActive != newMap.get(user.Id).IsActive ))
                       && profilesById.containsKey(user.ProfileId) && newMap.get(user.Id).AccountId__c != null && newMap.get(user.Id).IsActive == true) {
                    System.debug(user.id);
                    System.debug(user.AccountId__c);
                            addNewSharing(user.id, newMap.get(user.Id).AccountId__c);
                            System.debug('*** SHARING WAS RUN ***');
                }
            }
          }
        }
    }
    @future
    public static void addNewSharing(Id userId, Id accId) {
      System.debug(userid);
        User user = [select Id, AccountId__c from User where id=: userId];
      user.AccountId__c = accId;
      System.debug(user);
        List <AccountShare> sharingAccount = [SELECT  AccountId, Id, UserOrGroupId 
                                                FROM AccountShare where UserOrGroupId =: user.id ];
        System.debug(sharingAccount.size() + ' ' + sharingAccount);
      try {
        delete sharingAccount;
      } catch(Exception e) {
          System.debug(e.getMessage());
      }

        AccountShare addShare = new AccountShare(UserOrGroupId = user.id, AccountId = user.AccountId__c, AccountAccessLevel = 'Edit',
                                                OpportunityAccessLevel = 'Edit', CaseAccessLevel = 'Edit', ContactAccessLevel = 'Edit');
        insert addShare;
        System.debug('toInsert ' +addShare);
        Map <Id, Building_Ticket__c> allowedBuildingTicketsById = new Map <Id, Building_Ticket__c>([select OwnerId, Id from Building_Ticket__c 
                                                                    where Hub_Building_Site__r.Project__r.Account__c =: user.AccountId__c]);
        List <Building_Ticket__Share> sharingTicket = [SELECT  ParentId, Id, UserOrGroupId , AccessLevel
                                                FROM Building_Ticket__Share where UserOrGroupId =: user.id and AccessLevel != 'All'];
        System.debug(sharingTicket.size() + ' ' + sharingTicket);

      try {
        Database.DeleteResult[] DR_Dels = Database.delete(sharingTicket);
        System.debug(DR_Dels);
        List <Building_Ticket__Share> sharingTicketOwner = [SELECT  Parent.OwnerId,  ParentId, Id, UserOrGroupId , AccessLevel
                          FROM Building_Ticket__Share where UserOrGroupId =: user.id and AccessLevel = 'All'];
        Set <Id> parentIds = new Set <Id>();
        for(Building_Ticket__Share sh: sharingTicketOwner) {
          parentIds.add(sh.ParentId);
        }
        Map <Id, Building_Ticket__c> ticketsById = new Map<Id, Building_Ticket__c>([select Id from Building_Ticket__c where id in:parentIds ]);
        User userAdmin = [select Id from User where (Profile.Name = 'System Administrator' or Profile.Name = 'Systeembeheerder') and isActive = true limit 1];
        List <Building_Ticket__c> toChangeOwner = new List <Building_Ticket__c>();
        for (Building_Ticket__Share sh: sharingTicketOwner) {
          Building_Ticket__c t = ticketsById.get(sh.ParentId);
          t.OwnerId = userAdmin.Id;
          toChangeOwner.add(t);
        }
        System.debug(toChangeOwner.size() + ' ' + toChangeOwner);

        update toChangeOwner;
      } catch(Exception e) {
          System.debug(e.getMessage());
      }
        
      
      List <Building_Ticket__Share> addTicketShare = new List <Building_Ticket__Share>();
      for (Building_Ticket__c t: allowedBuildingTicketsById.values()  ) {
        if (t.OwnerId != user.id) {
          Building_Ticket__Share sh = new Building_Ticket__Share(ParentId = t.id, UserOrGroupId = user.id,AccessLevel = 'Edit' );
          addTicketShare.add(sh);
        }
      }
      try {
        insert addTicketShare;
        System.debug('toInsert ' +addTicketShare);
      } catch(Exception e) {
        System.debug(e.getMessage());
      }
      
      Set <Id> hubIds = new Set <Id>();
      for (AccountHUB__c acHub: [select Id, Hub_Building_Site__c from AccountHUB__c  where Account__c =: user.AccountId__c]) {
          hubIDs.add(acHub.Hub_Building_Site__c );
      }
      System.debug('HUBIDS ' + hubIDs);
      Map <Id, Hub_Building_Site__c> hubs = new Map <Id, Hub_Building_Site__c>([select Id, Name from Hub_Building_Site__c 
                                                                              where Project__r.Account__c =: user.AccountId__c or Id in:hubIDs]);
      List<Hub_Building_Site__Share> hubShares = [select Id, ParentId from Hub_Building_Site__Share where UserOrGroupId =: user.id];
      
      try {
        delete hubShares;
      } catch(Exception e) {
          System.debug(e.getMessage());
      }
      
      List <Hub_Building_Site__Share> addHUbShare = new List <Hub_Building_Site__Share>();
      for (Hub_Building_Site__c t: hubs.values()  ) {
        Hub_Building_Site__Share sh = new Hub_Building_Site__Share(ParentId = t.id, UserOrGroupId = user.id,AccessLevel = 'Edit' );
          addHUbShare.add(sh);
      }
      insert addHUbShare;
      System.debug('toInsert addHUbShare' +addHUbShare); 

      Map <Id, Location__c> locations = new Map <Id, Location__c>([select Id, Name from Location__c 
                                                                              where Hub_Building_Site__r.Project__r.Account__c =: user.AccountId__c or Hub_Building_Site__c in: hubIDs]);
      List< Location__Share> locShares = [select Id, ParentId from Location__Share where UserOrGroupId =: user.id];
      try {
        delete locShares;
      } catch(Exception e) {
          System.debug(e.getMessage());
      }

      
      List <Location__Share> addLocShare = new List <Location__Share>();
      for (Location__c t: locations.values()  ) {
        Location__Share sh = new Location__Share(ParentId = t.id, UserOrGroupId = user.id,AccessLevel = 'Edit' );
        addLocShare.add(sh);
      }
      insert addLocShare;
      System.debug('toInsert addLocShare' +addLocShare);
      
      ////
      Map <Id, Projecten__c> projects = new Map <Id, Projecten__c>([select Id, Name from Projecten__c
                                                                              where Account__c =: user.AccountId__c ]);
      List< Projecten__Share> prShares = [select Id, ParentId from Projecten__Share where UserOrGroupId =: user.id];
      try {
        delete prShares ;
      } catch(Exception e) {
          System.debug(e.getMessage());
      }

      
      List <Projecten__Share> prShare = new List <Projecten__Share>();
      for (Projecten__c t: projects.values()  ) {
        Projecten__Share sh = new Projecten__Share(ParentId = t.id, UserOrGroupId = user.id,AccessLevel = 'Edit' );
        prShare.add(sh);
      }
      insert prShare;
      System.debug('toInsert addLocShare' +addLocShare);
    }
}