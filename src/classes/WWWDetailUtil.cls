public class WWWDetailUtil{
    public static List <SubLocationDetail__c> subLocDet = new List <SubLocationDetail__c>();

    public static void entry(TriggerParams triggerParams) {
        List<WWW_detail__c> triggerNew = (List<WWW_detail__c>)triggerParams.triggerNew;
        List<WWW_detail__c> triggerOld = (List<WWW_detail__c>)triggerParams.triggerOld;
        Map<Id, WWW_detail__c> oldMap = (Map<Id, WWW_detail__c>)triggerParams.oldMap;
        Map<Id, WWW_detail__c> newMap = (Map<Id, WWW_detail__c>)triggerParams.newMap;


        if (triggerParams.isBefore){
            if (triggerParams.isUpdate || triggerParams.isInsert ) {
                checkAvailability(triggerNew, oldMap);
            }
            if (triggerParams.isDelete) {
                calculateRollupSum(new List <WWW_detail__c>(), triggerOld, triggerParams, oldMap);
                subLocDet = getSubLocDet(triggerOld);
                if(null != subLocDet){
                    deleteSubD(subLocDet);
                }
            }

        }
        if (triggerParams.isAfter){
            if (triggerParams.isUpdate || triggerParams.isInsert ) {
                //checkAvailability(triggerNew );
                if(!System.isFuture() && !System.isBatch()){
                    if(!triggerHelper.entryHasStartedAfterInUp){
                        if (triggerParams.isUpdate) {
                            List<WWW_Detail__c> updated = new List<WWW_Detail__c>();
                            for (WWW_Detail__c det : triggerNew) {
                                if (det.Number_Of_Items__c != oldMap.get(det.Id).Number_Of_Items__c) {
                                    updated.add(det);
                                }
                            }

                            if (!updated.isEmpty()) {
                                System.debug('update in trigger records -->> ' + updated.size());
                                calculateRollupSum(updated, triggerOld, triggerParams, oldMap);
                            }
                        } else if (triggerParams.isInsert) {
                            calculateRollupSum(triggerNew, triggerOld, triggerParams, oldMap);
                        }
                    }
                    if(!triggerHelper.entryHasStartedAfterInUp){
                        triggerHelper.recursiveHelperAfterInUp(true);
                    }
               }
            }
            if (triggerParams.isDelete) {
                updateParentLocations(triggerOld);
            }
            

        }
    }

    public static void updateParentLocations(List<WWW_detail__c> triggerOld) {
        Set <Id> parentLocationIds = new Set <Id>();
        for (WWW_detail__c wwwD: triggerOld) {
            if (wwwD.Location__c != null) {
                parentLocationIds.add(wwwD.Location__c);
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
    }

    public static void calculateRollupSum(List<WWW_detail__c> newDetails, List <WWW_detail__c> oldDetails, TriggerParams triggerParams,  Map<Id, WWW_detail__c> oldMap){
        Map <Id, RecordType> recordTypes = new Map <Id, RecordType>([select Id, developerName from RecordType where sObjectType= 'WWW_detail__c']);
        Set <Id> wwwIds = new Set <Id>();

        for (WWW_detail__c detail: newDetails) {
            wwwIds.add(detail.WWW__c);
        }

        if (oldDetails != null) {
            for (WWW_detail__c detail: oldDetails ) {
                wwwIds.add(detail.WWW__c);
            }
        }

        Map<Id, WWW__c> wwwById = new Map <Id, WWW__c>([select Id, Toename_Aantal_palletplaatsen1__c, Total_Items_Invoked__c,
                                                        Total_Items_Delivered_Hub__c, Total_Items_Delivered_Project__c,
                                                        Total_Items_Rejected_Hub__c, Total_Items_Rejected_Project__c, Total_Items_Reserved__c,
                                                        Totale_afname_aantal_palletplaatsen1__c, Total1__c
                                                        from WWW__c where id in: wwwIds]);

        if(triggerParams.isDelete){
            for (WWW_detail__c detail: oldDetails) {
                if (detail.Number_Of_Items__c != null && detail.WWW__c != null) {
                    if (detail.Toename_palletplaatsen__c != null) {
                        wwwById.get(detail.WWW__c).Toename_Aantal_palletplaatsen1__c += detail.Toename_palletplaatsen__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Delivered_2_Hub') {
                        wwwById.get(detail.WWW__c).Total_Items_Delivered_Hub__c -= detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Delivered_2_Project') {
                        wwwById.get(detail.WWW__c).Total_Items_Delivered_Project__c -= detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Invoked') {
                        wwwById.get(detail.WWW__c).Total_Items_Invoked__c -= detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Rejected' && detail.Rejected_On__c == 'Hub') {
                        wwwById.get(detail.WWW__c).Total_Items_Rejected_Hub__c -= detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Rejected'&& detail.Rejected_On__c == 'Project') {
                        wwwById.get(detail.WWW__c).Total_Items_Rejected_Project__c -= detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Reserved') {
                        wwwById.get(detail.WWW__c).Total_Items_Reserved__c -= detail.Number_Of_Items__c;
                    }
                    if (detail.Afname_palletplaatsen__c != null ) {
                        wwwById.get(detail.WWW__c).Totale_afname_aantal_palletplaatsen1__c -= detail.Afname_palletplaatsen__c;
                    }
                    if (detail.Number_Of_Packages__c != null ) {
                        wwwById.get(detail.WWW__c).Total1__c -= detail.Number_Of_Packages__c;
                    }
                }
            }
        }

        for (WWW_detail__c detail: triggerParams.isDelete ? oldDetails : newDetails) {
            if (detail.WWW__c != null) {
                if(wwwById.get(detail.WWW__c).Toename_Aantal_palletplaatsen1__c < 0){
                    wwwById.get(detail.WWW__c).Toename_Aantal_palletplaatsen1__c = 0;
                }
                if(wwwById.get(detail.WWW__c).Total_Items_Delivered_Hub__c < 0){
                    wwwById.get(detail.WWW__c).Total_Items_Delivered_Hub__c = 0;
                }
                if(wwwById.get(detail.WWW__c).Total_Items_Delivered_Project__c < 0){
                    wwwById.get(detail.WWW__c).Total_Items_Delivered_Project__c = 0;
                }
                if(wwwById.get(detail.WWW__c).Total_Items_Invoked__c < 0){
                    wwwById.get(detail.WWW__c).Total_Items_Invoked__c = 0;
                }
                if(wwwById.get(detail.WWW__c).Toename_Aantal_palletplaatsen1__c < 0){
                    wwwById.get(detail.WWW__c).Toename_Aantal_palletplaatsen1__c = 0;
                }
                if(wwwById.get(detail.WWW__c).Total_Items_Rejected_Hub__c < 0){
                    wwwById.get(detail.WWW__c).Total_Items_Rejected_Hub__c = 0;
                }
                if(wwwById.get(detail.WWW__c).Total_Items_Rejected_Project__c < 0){
                    wwwById.get(detail.WWW__c).Total_Items_Rejected_Project__c = 0;
                }
                if(wwwById.get(detail.WWW__c).Total_Items_Reserved__c < 0){
                    wwwById.get(detail.WWW__c).Total_Items_Reserved__c = 0;
                }
                if(wwwById.get(detail.WWW__c).Totale_afname_aantal_palletplaatsen1__c < 0){
                    wwwById.get(detail.WWW__c).Totale_afname_aantal_palletplaatsen1__c = 0;
                }
                if(wwwById.get(detail.WWW__c).Total1__c < 0){
                    wwwById.get(detail.WWW__c).Total1__c = 0;
                }
            }
        }

        for (WWW_detail__c detail: newDetails) {
            if (detail.WWW__c != null) {
                if (wwwById.get(detail.WWW__c).Toename_Aantal_palletplaatsen1__c == null) {
                    wwwById.get(detail.WWW__c).Toename_Aantal_palletplaatsen1__c = 0;
                }
                if (wwwById.get(detail.WWW__c).Total_Items_Delivered_Hub__c == null) {
                    wwwById.get(detail.WWW__c).Total_Items_Delivered_Hub__c = 0;
                }
                if (wwwById.get(detail.WWW__c).Total_Items_Delivered_Project__c == null) {
                    wwwById.get(detail.WWW__c).Total_Items_Delivered_Project__c = 0;
                }
                if (wwwById.get(detail.WWW__c).Total_Items_Invoked__c == null) {
                    wwwById.get(detail.WWW__c).Total_Items_Invoked__c = 0;
                }
                if (wwwById.get(detail.WWW__c).Total_Items_Rejected_Hub__c == null) {
                    wwwById.get(detail.WWW__c).Total_Items_Rejected_Hub__c = 0;
                }
                if (wwwById.get(detail.WWW__c).Total_Items_Rejected_Project__c == null) {
                    wwwById.get(detail.WWW__c).Total_Items_Rejected_Project__c = 0;
                }
                if (wwwById.get(detail.WWW__c).Total_Items_Reserved__c == null) {
                    wwwById.get(detail.WWW__c).Total_Items_Reserved__c = 0;
                }
                if (wwwById.get(detail.WWW__c).Totale_afname_aantal_palletplaatsen1__c == null ) {
                    wwwById.get(detail.WWW__c).Totale_afname_aantal_palletplaatsen1__c = 0;
                }
                if (wwwById.get(detail.WWW__c).Total1__c == null ) {
                    wwwById.get(detail.WWW__c).Total1__c = 0;
                }
            }
        }

        for (WWW_detail__c detail: newDetails) {
            if (detail.WWW__c != null) {
                if (triggerParams.isInsert) {
                    if (detail.Toename_palletplaatsen__c != null) {
                        wwwById.get(detail.WWW__c).Toename_Aantal_palletplaatsen1__c += detail.Toename_palletplaatsen__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Delivered_2_Hub') {
                        wwwById.get(detail.WWW__c).Total_Items_Delivered_Hub__c += detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Delivered_2_Project') {
                        wwwById.get(detail.WWW__c).Total_Items_Delivered_Project__c += detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Invoked') {
                        wwwById.get(detail.WWW__c).Total_Items_Invoked__c += detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Rejected' && detail.Rejected_On__c == 'Hub') {
                        wwwById.get(detail.WWW__c).Total_Items_Rejected_Hub__c += detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Rejected'&& detail.Rejected_On__c == 'Project') {
                        wwwById.get(detail.WWW__c).Total_Items_Rejected_Project__c += detail.Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Reserved') {
                        wwwById.get(detail.WWW__c).Total_Items_Reserved__c += detail.Number_Of_Items__c;
                    }
                    if (detail.Afname_palletplaatsen__c != null ) {
                        wwwById.get(detail.WWW__c).Totale_afname_aantal_palletplaatsen1__c += detail.Afname_palletplaatsen__c;
                    }
                    if (detail.Number_Of_Packages__c != null ) {
                        wwwById.get(detail.WWW__c).Total1__c += detail.Number_Of_Packages__c;
                    }
                } else if (triggerParams.isUpdate) {
                    if (detail.Toename_palletplaatsen__c != null) {
                        wwwById.get(detail.WWW__c).Toename_Aantal_palletplaatsen1__c += detail.Toename_palletplaatsen__c - oldMap.get(detail.Id).Toename_palletplaatsen__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Delivered_2_Hub') {
                        wwwById.get(detail.WWW__c).Total_Items_Delivered_Hub__c += detail.Number_Of_Items__c - oldMap.get(detail.Id).Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Delivered_2_Project') {
                        wwwById.get(detail.WWW__c).Total_Items_Delivered_Project__c += detail.Number_Of_Items__c - oldMap.get(detail.Id).Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Invoked') {
                        wwwById.get(detail.WWW__c).Total_Items_Invoked__c += detail.Number_Of_Items__c - oldMap.get(detail.Id).Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Rejected' && detail.Rejected_On__c == 'Hub') {
                        wwwById.get(detail.WWW__c).Total_Items_Rejected_Hub__c += detail.Number_Of_Items__c - oldMap.get(detail.Id).Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Rejected'&& detail.Rejected_On__c == 'Project') {
                        wwwById.get(detail.WWW__c).Total_Items_Rejected_Project__c += detail.Number_Of_Items__c - oldMap.get(detail.Id).Number_Of_Items__c;
                    }
                    if (detail.Number_Of_Items__c != null && recordTypes.get(detail.RecordTypeId).developerName == 'Reserved') {
                        wwwById.get(detail.WWW__c).Total_Items_Reserved__c += detail.Number_Of_Items__c - oldMap.get(detail.Id).Number_Of_Items__c;
                    }
                    if (detail.Afname_palletplaatsen__c != null ) {
                        wwwById.get(detail.WWW__c).Totale_afname_aantal_palletplaatsen1__c += detail.Afname_palletplaatsen__c - oldMap.get(detail.Id).Afname_palletplaatsen__c;
                    }
                    if (detail.Number_Of_Packages__c != null ) {
                        wwwById.get(detail.WWW__c).Total1__c += detail.Number_Of_Packages__c - oldMap.get(detail.Id).Number_Of_Packages__c;
                    }
                }
            }
        }

        if (newDetails.size() == 0) {
            for (WWW_detail__c oldDetail: newDetails) {
                if (oldDetail.WWW__c != null) {
                    if (oldDetail.Toename_palletplaatsen__c != null && oldDetail.Number_Of_Items__c != 0) {
                        wwwById.get(oldDetail.WWW__c).Toename_Aantal_palletplaatsen1__c  -= oldDetail.Toename_palletplaatsen__c;
                    }
                    if (oldDetail.Number_Of_Items__c != null && oldDetail.Number_Of_Items__c != 0 && recordTypes.get(oldDetail.RecordTypeId).developerName == 'Delivered_2_Hub') {
                        wwwById.get(oldDetail.WWW__c).Total_Items_Delivered_Hub__c  -= oldDetail.Number_Of_Items__c;
                    }
                    if (oldDetail.Number_Of_Items__c != null && oldDetail.Number_Of_Items__c != 0 && recordTypes.get(oldDetail.RecordTypeId).developerName == 'Delivered_2_Project') {
                        wwwById.get(oldDetail.WWW__c).Total_Items_Delivered_Project__c  -= oldDetail.Number_Of_Items__c;
                    }
                    if (oldDetail.Number_Of_Items__c != null && oldDetail.Number_Of_Items__c != 0 && recordTypes.get(oldDetail.RecordTypeId).developerName == 'Invoked') {
                        wwwById.get(oldDetail.WWW__c).Total_Items_Invoked__c  -= oldDetail.Number_Of_Items__c;
                    }
                    if (oldDetail.Number_Of_Items__c != null && oldDetail.Number_Of_Items__c != 0 && recordTypes.get(oldDetail.RecordTypeId).developerName == 'Rejected' && oldDetail.Rejected_On__c == 'Hub') {
                        wwwById.get(oldDetail.WWW__c).Total_Items_Rejected_Hub__c  -= oldDetail.Number_Of_Items__c;
                    }
                    if (oldDetail.Number_Of_Items__c != null && oldDetail.Number_Of_Items__c != 0 && recordTypes.get(oldDetail.RecordTypeId).developerName == 'Rejected'&& oldDetail.Rejected_On__c == 'Project') {
                        wwwById.get(oldDetail.WWW__c).Total_Items_Rejected_Project__c  -= oldDetail.Number_Of_Items__c;
                    }
                    if (oldDetail.Number_Of_Items__c != null && oldDetail.Number_Of_Items__c != 0 && recordTypes.get(oldDetail.RecordTypeId).developerName == 'Reserved') {
                        wwwById.get(oldDetail.WWW__c).Total_Items_Reserved__c -= oldDetail.Number_Of_Items__c;
                    }
                    if (oldDetail.Afname_palletplaatsen__c != null && oldDetail.Number_Of_Items__c != 0  ) {
                        wwwById.get(oldDetail.WWW__c).Totale_afname_aantal_palletplaatsen1__c -= oldDetail.Afname_palletplaatsen__c;
                    }
                    if (oldDetail.Number_Of_Packages__c != null && oldDetail.Number_Of_Items__c != 0  ) {
                        wwwById.get(oldDetail.WWW__c).Total1__c -= oldDetail.Number_Of_Packages__c;
                    }
                }
            }
        }

        try {
            update wwwById.values();
        } catch(DmlException e){
            if(e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('Unique_field__c')) {
                e.setMessage('Er is al een www met deze naam, controleer of je de bestaande www niet kan gebruiken.');
            }
        }
    }

    public static void checkAvailability(List<WWW_detail__c> details, Map<Id, WWW_detail__c> oldMap){
        Boolean hasChanges = false;
        List<WWW_Detail__c> updated = new List<WWW_Detail__c>();

        if (oldMap == null) {
            hasChanges = true;
            updated.addAll(details);
        } else {
            for (WWW_detail__c det : details) {
                if (det.Number_Of_Items__c != oldMap.get(det.Id).Number_Of_Items__c) {
                    updated.add(det);
                    hasChanges = true;
                }
            }
        }

        if (hasChanges == true && !updated.isEmpty()) {
            Set <Id> wwwIds = new Set <Id>();
            for (WWW_detail__c detail: updated) {
               wwwIds.add(detail.WWW__c);
            }
            RecordType rT = [select Id from RecordType where DeveloperName = 'Invoked' and SobjectType = 'WWW_detail__c'];
            RecordType rTdelToProj = [select Id from RecordType where DeveloperName = 'Delivered_2_Project' and SobjectType = 'WWW_detail__c'];
            RecordType rTdelToHub = [select Id from RecordType where DeveloperName = 'Delivered_2_Hub' and SobjectType = 'WWW_detail__c'];

            Map <Id, WWW__c> wwwsById = new Map <Id, WWW__c>([select Id, Curr_Items_To_Be_Delivered_On_Hub__c, Curr_Items_To_Be_Delivered_On_Project__c, Curr_Items_To_Invoke__c,
                                                                    Curr_Items_To_Invoke_Incl_Rejected__c, Can_be_delivered__c, Total_Items_Delivered_Project__c, Total_Items_Invoked__c
                                                                from WWW__c where id in: wwwIds]);
            for (WWW_detail__c detail: updated){
                //if (detail.RecordTypeId == rT.Id && (wwwsById.get(detail.WWW__c).Curr_Items_To_Invoke__c > wwwsById.get(detail.WWW__c).Curr_Items_To_Be_Delivered_On_Project__c) 
                //                                    && (detail.Number_Of_Items__c > wwwsById.get(detail.WWW__c).Curr_Items_To_Invoke__c)) {
                //    detail.addError(Label.Too_much_packages);
                //}

                //if (detail.RecordTypeId == rt.Id && (detail.Number_Of_Items__c > wwwsById.get(detail.WWW__c).Curr_Items_To_Invoke__c)) {
                //    detail.addError(Label.Too_much_packages);
                //} else if (detail.RecordTypeId == rTdelToProj.Id && (detail.Number_Of_Items__c > wwwsById.get(detail.WWW__c).Can_be_delivered__c)) {
                //    detail.addError(Label.Too_much_packages);
                //}

                //Decimal items = 0;

                if (detail.RecordTypeId == rt.Id) {
                    Decimal items = wwwsById.get(detail.WWW__c).Curr_Items_To_Invoke__c;
                    items += oldMap == null ? 0 : oldMap.get(detail.Id).Number_Of_Items__c;

                    if (detail.Number_Of_Items__c > items) {
                        detail.addError(Label.Too_much_packages);
                    }
                } else if (detail.RecordTypeId == rTdelToProj.Id) {
                    Decimal items = wwwsById.get(detail.WWW__c).Can_be_delivered__c;
                    items += oldMap == null ? 0 : oldMap.get(detail.Id).Number_Of_Items__c;

                    if (detail.Number_Of_Items__c > items) {
                        detail.addError(Label.Too_much_packages);
                    }
                } else if (detail.RecordTypeId == rTdelToHub.Id && oldMap != null) {
                    if (detail.Number_Of_Items__c < wwwsById.get(detail.WWW__c).Total_Items_Delivered_Project__c 
                            || detail.Number_Of_Items__c < wwwsById.get(detail.WWW__c).Total_Items_Invoked__c) {
                        detail.addError(Label.Too_much_packages);
                    }
                }
            }
        }
    }




    public static void deleteSubD(List<SubLocationDetail__c> SubDetToDelete){
        System.debug('[***] SubDetToDelete +' + SubDetToDelete);
            delete SubDetToDelete;
    }

    public static List <SubLocationDetail__c> getSubLocDet (List<WWW_detail__c> triggerOld){
        Set<Id> wwwDetIds = new Set<Id>();

        for(WWW_detail__c wwwd : triggerOld){
            wwwDetIds.add(wwwd.Id);
        }
        List <SubLocationDetail__c> subLocDet2 = [SELECT Id, WWW_Detail__c FROM SubLocationDetail__c WHERE WWW_Detail__c =: wwwDetIds];
        return subLocDet2;
    }

    
}