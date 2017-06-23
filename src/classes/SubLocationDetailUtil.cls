public with sharing class SubLocationDetailUtil {

    public static void entry(TriggerParams triggerParams) {
        List<SubLocationDetail__c> triggerNew = (List<SubLocationDetail__c>)triggerParams.triggerNew;
        List<SubLocationDetail__c> triggerOld = (List<SubLocationDetail__c>)triggerParams.triggerOld;
        Map<Id, SubLocationDetail__c> oldMap = (Map<Id, SubLocationDetail__c>)triggerParams.oldMap;
        Map<Id, SubLocationDetail__c> newMap = (Map<Id, SubLocationDetail__c>)triggerParams.newMap;
        if(triggerParams.isBefore){
            if(triggerParams.isDelete){
            }
        }

        if (triggerParams.isAfter){
            if ( triggerParams.isInsert || triggerParams.isUpdate) {
               upateSubLocation(triggerNew);
               calculateSublocationsForProject(triggerNew);
            }

            if ( triggerParams.isInsert )
            {
                addRecordsForReport(triggerNew);
            }

            if ( triggerParams.isUpdate )
            {
                updateRecordsForReport(triggerNew, oldMap);
            }

            if( triggerParams.isDelete )
            {
                updateRecordsForReportBeforeDelete(triggerOld);
                upateSubLocation(triggerOld);

            }
        }
    }
      public static void upateSubLocation (List<SubLocationDetail__c> triggerNew) {
        System.debug('[****] upateSubLocation');
        Map <Id, Location__c> locationsToUpdateMap = new Map <Id, Location__c>();
        Set <Id> locationsToUpdateIds = new Set <Id>();

        for (SubLocationDetail__c subL: triggerNew) {
            if(!locationsToUpdateMap.containsKey(subL.Location__c)){
                locationsToUpdateIds.add(subL.Location__c);
            }

        }
        List <Location__c> locationsToUpdate = new List <Location__c>(locationsToUpdateMap.values());

        Map <Id, Location__c> locationsById = new Map <Id, Location__c>([select Id from Location__c where id in: locationsToUpdateIds]);
        List <SubLocationDetail__c> details = [select Id, Name, Location__c ,Reserved__c, To_Sum__c, Number_of_items__c from SubLocationDetail__c where Location__c in: locationsToUpdateIds];
        List<SubLocationDetail__c> subNotSum;

        Map <Id, Decimal> detByLocId = new Map<Id, Decimal>();
        Map <Id, Decimal> detRedByLocId = new Map<Id, Decimal>();
        Map <Id, List<SubLocationDetail__c>> subLocsBylocId = new Map<Id, List<SubLocationDetail__c>>();
        for (SubLocationDetail__c det: details) {
            if(subLocsBylocId.get(det.Location__c) == null){
                subLocsBylocId.put(det.Location__c, new List<SubLocationDetail__c>());
            }

            subLocsBylocId.get(det.Location__c).add(det);


            if (detByLocId.containsKey(det.Location__c)) {
                if (det.To_Sum__c) {
                    detByLocId.put(det.Location__c, detByLocId.get(det.Location__c) + det.Number_of_items__c);
                } else {
                    if (!det.Reserved__c && detRedByLocId.containsKey(det.Location__c)) {
                        detRedByLocId.put(det.Location__c, detRedByLocId.get(det.Location__c) + det.Number_of_items__c);
                    } else if(!det.Reserved__c) {
                        detRedByLocId.put(det.Location__c, det.Number_of_items__c);
                    }
                }
            } else {
                if (det.To_Sum__c) {
                    detByLocId.put(det.Location__c, det.Number_of_items__c);
                } else {
                    
                        if (!det.Reserved__c && detRedByLocId.containsKey(det.Location__c)) {
                            detRedByLocId.put(det.Location__c, det.Number_of_items__c);
                        } else if(!det.Reserved__c) {
                            detRedByLocId.put(det.Location__c, det.Number_of_items__c);
                        }
                }
                
            }
        }
        for(SubLocationDetail__c subNull : details){
            if(subNull.To_Sum__c){
                subNotSum = new List <SubLocationDetail__c>();
                subNotSum.add(subNull);
            }
        }
        if(subNotSum == null){
            for(Location__c loc : locationsById.values()){
                loc.Current_amount__c = null;
                loc.Available_amount__c = null;
                locationsToUpdate.add(loc);
            }
        }

        for (Location__c loc:locationsById.values()) {
            Boolean added = false;
            if (detByLocId.containsKey(loc.Id)) {
                loc.Current_amount__c = detByLocId.get(loc.Id);
                loc.Available_amount__c = detRedByLocId.get(loc.Id);
                locationsToUpdate.add(loc);
                added = true;
            }

            /*if(subLocsBylocId.get(loc.Id) == null )
            {
                loc.Current_amount__c = null;
                loc.Available_amount__c = null;
                if( added == false )
                {
                    locationsToUpdate.add(loc);
                }
            }*/
        }
        System.debug('upateSubLocation locationsToUpdate' + locationsToUpdate);
        update locationsToUpdate;
    }
    
    public static void calculateSublocationsForProject (List<SubLocationDetail__c> triggerNew) {
        Set<Id> wwwDetailIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        
        List<Projecten__c> projects = new List<Projecten__c>();
        List<Projecten__c> projToUpdate = new List<Projecten__c>();
        
        Map<Id, List<WWW_Detail__c>> wwwDetailsByProjectId = new Map<Id, List<WWW_Detail__c>>();
        Map<Id, List<SublocationDetail__c>> sublocDetailByWwwDetailId = new Map<Id, List<SublocationDetail__c>>();
        
        for(SubLocationDetail__c sd : triggerNew)
        {
            wwwDetailIds.add(sd.WWW_Detail__c);
        }
        
        List<WWW_Detail__c> wwwDetails = [select Id, Name, Project__c from WWW_Detail__c where Id in :wwwDetailIds];
        if( null != wwwDetails && !wwwDetails.isEmpty())
        {
            for(WWW_Detail__c wd : wwwDetails)
            {
                projectIds.add(wd.Project__c);
            }
            projects = [Select Id, Name from Projecten__c where Id in: projectIds];
            wwwDetails = [select Id, Name, Project__c from WWW_Detail__c where Project__c in :projectIds];
            if( null != wwwDetails && !wwwDetails.isEmpty() )
            {
                wwwDetailIds = new Set<Id>();
                
                for(WWW_Detail__c wd : wwwDetails)
                {
                    if(wwwDetailsByProjectId.get(wd.Project__c)==null)
                    {
                        wwwDetailsByProjectId.put(wd.Project__c, new List<WWW_Detail__c>());
                    }
                    wwwDetailsByProjectId.get(wd.Project__c).add(wd);
                    wwwDetailIds.add(wd.Id);
                }
                
                List<SublocationDetail__c> subLocDetails = [Select Id, Name, Location__r.Occupied__c, Location__r.Parent_Location__c, WWW_Detail__c from SublocationDetail__c 
                                                            where Location__r.Occupied__c = true AND Location__r.Parent_Location__c = null AND WWW_Detail__c in :wwwDetailIds];
                
                if(null != subLocDetails && !subLocDetails.isEmpty())
                {
                    for(SublocationDetail__c sd : subLocDetails)
                    {
                        if(sublocDetailByWwwDetailId.get(sd.WWW_Detail__c)==null)
                        {
                            sublocDetailByWwwDetailId.put(sd.WWW_Detail__c, new List<SublocationDetail__c>());
                        }
                        sublocDetailByWwwDetailId.get(sd.WWW_Detail__c).add(sd);
                    }
                }
            }
        }
        
        for(Projecten__c pr : projects)
        {
            Integer subLocCount = 0;
            List<WWW_Detail__c> currWwwDetails = wwwDetailsByProjectId.get(pr.Id);
            for(WWW_Detail__c wd : currWwwDetails)
            {
                List<SublocationDetail__c> subLocs = sublocDetailByWwwDetailId.get(wd.Id);
                subLocCount += subLocs == null ? 0 : subLocs.size();
            }
            pr.Aantal_palletplaatsen__c = subLocCount;
            System.debug('OBdeb subLocCount -->> ' + subLocCount);
        }
        
        update projects;
    }

    public static void addRecordsForReport(List<SubLocationDetail__c> triggerNew)
    {
        List<ProjectLocation__c> prepareDataForReport = prepareRecordsForReport(triggerNew);
        if( prepareDataForReport != null && !prepareDataForReport.isEmpty() )
        {
            insert prepareDataForReport;
        }
    }

    public static void updateRecordsForReport(List<SubLocationDetail__c> triggerNew,  Map<Id, SubLocationDetail__c> oldMap)
    {
        List<ProjectLocation__c> prepareDataForUpdate = prepareRecordsForUpdate(oldMap, triggerNew);
        System.debug('OBDEB prepareDataForUpdate -->> ' + prepareDataForUpdate);

        if( prepareDataForUpdate != null && !prepareDataForUpdate.isEmpty() )
        {
            insert prepareDataForUpdate;
        }
    }

    public static void updateRecordsForReportBeforeDelete(List<SubLocationDetail__c> triggerOld)
    {
        Set<Id> locationsIds = new Set<Id>();
        Set<String> projectIds = new Set<String>();

        for(SubLocationDetail__c sd : triggerOld)
        {
            locationsIds.add(sd.Location__c);
            projectIds.add(sd.ProjectId__c);
        }

        List<ProjectLocation__c> toDelete = new List<ProjectLocation__c>();
        List<ProjectLocation__c> projectLocations = new List<ProjectLocation__c>();

        List<ProjectLocation__c> tempProjectLocations = [Select Project__c, Location__c from ProjectLocation__c where Project__c in :projectIds];
        for( ProjectLocation__c pl : tempProjectLocations )
        {
            if( locationsIds.contains(pl.Location__c) )
            {
                projectLocations.add(pl);
            }
        }

        List<SublocationDetail__c> subLocs = [Select Id, Name, Location__c, ProjectId__c from SublocationDetail__c 
                                                    where ProjectId__c in :projectIds];

        if( subLocs != null && !subLocs.isEmpty() )
        {
            for( ProjectLocation__c pl : projectLocations )
            {
                Boolean isExist = false;
                for( SubLocationDetail__c sd : subLocs )
                {
                    if( pl.Location__c == sd.Location__c && pl.Project__c == sd.ProjectId__c )
                    {
                        isExist = true;
                    }
                }
                if( isExist == false )
                {
                    toDelete.add(pl);
                }
            }
        } else {
            toDelete.addAll(projectLocations);
        }

        if( null != toDelete && !toDelete.isEmpty() )
        {
            delete toDelete;
        }
    }

    public static List<ProjectLocation__c> prepareRecordsForReport(List<SubLocationDetail__c> subLocDetailList)
    {
        System.debug('RUN manageRecordsForReport');
        Set<Id> wwwDetailIds = new Set<Id>();
        Set<Id> locationsIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();

        List<Projecten__c> projects = new List<Projecten__c>();

        Map<Id, List<WWW_Detail__c>> wwwDetailsByProjectId = new Map<Id, List<WWW_Detail__c>>();
        Map<Id, List<SublocationDetail__c>> sublocDetailByWwwDetailId = new Map<Id, List<SublocationDetail__c>>();
        Map<Id, Set<Id>> locationIdsByProjectId = new Map<Id, Set<Id>>();

        for(SubLocationDetail__c sd : subLocDetailList)
        {
            wwwDetailIds.add(sd.WWW_Detail__c);
            locationsIds.add(sd.Location__c);

            if(sublocDetailByWwwDetailId.get(sd.WWW_Detail__c)==null)
            {
                sublocDetailByWwwDetailId.put(sd.WWW_Detail__c, new List<SublocationDetail__c>());
            }
            sublocDetailByWwwDetailId.get(sd.WWW_Detail__c).add(sd);
        }

        System.debug('OBDEB sublocDetailByWwwDetailId -->> ' + sublocDetailByWwwDetailId);

        List<WWW_Detail__c> wwwDetails = [select Id, Name, Project__c from WWW_Detail__c where Id in :wwwDetailIds];
        if( null != wwwDetails && !wwwDetails.isEmpty() )
        {
            for(WWW_Detail__c wd : wwwDetails)
            {
                if(wwwDetailsByProjectId.get(wd.Project__c)==null)
                {
                    wwwDetailsByProjectId.put(wd.Project__c, new List<WWW_Detail__c>());
                }
                wwwDetailsByProjectId.get(wd.Project__c).add(wd);
                projectIds.add(wd.Project__c);
            }

            System.debug('OBDEB wwwDetailsByProjectId -->> ' + wwwDetailsByProjectId);

            for(Id prId : wwwDetailsByProjectId.keySet())
            {
                for(WWW_Detail__c wwwd : wwwDetailsByProjectId.get(prId))
                {
                    for(SublocationDetail__c sbd : sublocDetailByWwwDetailId.get(wwwd.Id))
                    {
                        if(locationIdsByProjectId.get(prId)==null)
                        {
                            locationIdsByProjectId.put(prId, new Set<Id>());
                        }
                        locationIdsByProjectId.get(prId).add(sbd.Location__c);
                    }
                }
            }

            System.debug('OBDEB locationIdsByProjectId -->> ' + locationIdsByProjectId);

            List<ProjectLocation__c> projectLocations = new List<ProjectLocation__c>();
            List<ProjectLocation__c> plToCreate = new List<ProjectLocation__c>();

            projectLocations = [Select Project__c, Location__c from ProjectLocation__c where Project__c in :projectIds];
            if( null != projectLocations && !projectLocations.isEmpty() )
            {
                for(Id prId : locationIdsByProjectId.keySet())
                {
                    for(Id locId : locationIdsByProjectId.get(prId))
                    {
                        Boolean isExist = false;
                        for(ProjectLocation__c pr : projectLocations)
                        {
                            if( pr.Project__c == prId && pr.Location__c == locId)
                            {
                                isExist = true;
                            }
                        }

                        if( isExist == false )
                        {
                            ProjectLocation__c prLoc = new ProjectLocation__c();
                            prLoc.Project__c = prId;
                            prLoc.Location__c = locId;
                            plToCreate.add(prLoc);
                        }
                    }
                }
            } else {
                for(Id prId : locationIdsByProjectId.keySet())
                {
                    for(Id locId : locationIdsByProjectId.get(prId))
                    {
                        ProjectLocation__c prLoc = new ProjectLocation__c();
                        prLoc.Project__c = prId;
                        prLoc.Location__c = locId;
                        plToCreate.add(prLoc);
                    }
                }
            }

            System.debug('OBDEB plToCreate -->> ' + plToCreate);

            //if( plToCreate != null && !plToCreate.isEmpty() )
            //{
                //insert plToCreate;
            //}
            return plToCreate;
        } else {
            return null;
        }
    }

    public static List<ProjectLocation__c> prepareRecordsForUpdate(Map<Id, SubLocationDetail__c> oldSubLocDetails, List<SubLocationDetail__c> newSubLocDetailList)
    {
        //System.debug('OBDEB prepareRecordsForUpdate');
        List<SubLocationDetail__c> whereLocationChanged = new List<SubLocationDetail__c>();
        Set<String> oldProjectIds = new Set<String>();
        Set<String> newProjectIds = new Set<String>();
        Set<String> changedSubLocsIds = new Set<String>();
        //System.debug('OBDEB oldSubLocDetails -->> ' + oldSubLocDetails);
        //System.debug('OBDEB newSubLocDetailList -->> ' + newSubLocDetailList);
        for( SubLocationDetail__c sld : newSubLocDetailList )
        {
            if( sld.ProjectId__c != oldSubLocDetails.get(sld.Id).ProjectId__c )
            {
                //System.debug('OBDEB oldSubLocDetails.get(sld.Id).ProjectId__c -->> ' + oldSubLocDetails.get(sld.Id).ProjectId__c);
                //System.debug('OBDEB sld.ProjectId__c -->> ' + sld.ProjectId__c);
                whereLocationChanged.add(sld);
                oldProjectIds.add(oldSubLocDetails.get(sld.Id).ProjectId__c);
                //System.debug('OBDEB oldProjectIds -->> ' + oldProjectIds);
                newProjectIds.add(sld.ProjectId__c);
                changedSubLocsIds.add(sld.Id);
            }
        }

        //System.debug('OBDEB oldProjectIds -->> ' + oldProjectIds);
        //System.debug('OBDEB newProjectIds -->> ' + newProjectIds);
        //System.debug('OBDEB changedSubLocsIds -->> ' + changedSubLocsIds);

        if( whereLocationChanged != null && !whereLocationChanged.isEmpty() )
        {
            List<ProjectLocation__c> projectLocations = [select Id, Project__c, Location__c from ProjectLocation__c where Project__c in :oldProjectIds];
            //System.debug('OBDEB projectLocations -->> ' + projectLocations);
            List<ProjectLocation__c> toDelete = new List<ProjectLocation__c>();

            List<SubLocationDetail__c> otherSubLocs = [SELECT Id, Name, Location__c, WWW_Detail__c, ProjectCode__c, ProjectId__c FROM SublocationDetail__c where Id not in :changedSubLocsIds and ProjectId__c in :oldProjectIds];
            //System.debug('OBDEB otherSubLocs -->> ' + otherSubLocs);
            if( otherSubLocs != null && !otherSubLocs.isEmpty() )
            {
                //System.debug('OBDEB **************************');
                for( ProjectLocation__c pl : projectLocations )
                {
                    Boolean isExist = false;
                    for( SubLocationDetail__c sd : otherSubLocs )
                    {
                        if( pl.Location__c == sd.Location__c && pl.Project__c == sd.ProjectId__c )
                        {
                            isExist = true;
                        }
                    }
                    if( isExist == false )
                    {
                        toDelete.add(pl);
                    }
                }
            } else {
                //System.debug('OBDEB +++++++++++++++++++++++++++++++++++++++++');
                toDelete.addAll(projectLocations);
            }

            if( toDelete != null && !toDelete.isEmpty() )
            {
                delete toDelete;
                //System.debug('OBDEB toDelete -->> ' + toDelete.size() + ' -->> ' + toDelete);
            }

            List<ProjectLocation__c> prepareDataForReport = prepareRecordsForReport(whereLocationChanged);
            //System.debug('OBDEB prepareDataForReport -->> ' + prepareDataForReport.size() + ' -->> ' + prepareDataForReport);
            if( prepareDataForReport != null && !prepareDataForReport.isEmpty() )
            {
                return prepareDataForReport;
            }

            return null;
        } else {
            return null;
        }
    }
}