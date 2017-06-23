public class NewDeliveredExtension {

    public WWW__c www {
        get {
            if (null == www ) {
                www = new WWW__c();
            }
            return www;
        } set;
    }

    public WWW_Detail__c detail {
        get {
            if (detail == null) {
                detail = new WWW_Detail__c ();
                detail.WWW__c = www.id;
                detail.Project__c = projectid;
            }
            return detail;
        } set;
    }

    public String selectedTime {
        get {
            if(selectedTime == null)
            {
                selectedTime = '8:00';
            }
            return selectedTime;
        } set;
    }
    public String selectedTime2 {
        get {
            if(selectedTime2 == null)
            {
                selectedTime2 = '8:00';
            }
            return selectedTime2;
        } set;
    }
    public String selectedTime3 {
        get {
            if(selectedTime3 == null)
            {
                selectedTime3 = '8:00';
            }
            return selectedTime3;
        } set;
    }
    public String selectedTime4 {
        get {
            if(selectedTime4 == null)
            {
                selectedTime4 = '8:00';
            }
            return selectedTime4;
        } set;
    }
    //public String selectedTime5 {
    //    get {
    //        if(selectedTime5 == null)
    //        {
    //            selectedTime5 = '8:00';
    //        }
    //        return selectedTime5;
    //    } set;
    //}
    public String selectedTime6 {
        get {
            if(selectedTime6 == null)
            {
                selectedTime6 = '8:00';
            }
            return selectedTime6;
        } set;
    }
    public String selectedTime7 {
        get {
            if(selectedTime7 == null)
            {
                selectedTime7 = '8:00';
            }
            return selectedTime7;
        } set;
    }

    public Boolean invoked {
        get {
            if (invoked == null) {
                invoked = false;
            }
            return invoked;
        } set;
    }
    public Boolean rejected {
        get {
            if (rejected == null) {
                rejected = false;
            }
            return rejected;
        } set;
    }
    public Boolean reserved {
        get {
            if (reserved == null) {
                reserved = false;
            }
            return reserved ;
        } set;
    }
    public Boolean delToProj {
        get {
            if (delToProj == null) {
                delToProj = false;
            }
            return delToProj;
        } set;
    }

    public Boolean delToHub {
        get {
            if (delToHub == null) {
                delToHub = false;
            }
            return delToHub ;
        } set;
    }

    //public String param {
    //    get {
    //        if (param == null) {
    //            param = '';
    //        }
    //        return param;
    //    } set;
    //}

    public List<SubLocation> sublocations1 {
        get {
            if (sublocations1 == null) {
                sublocations1 = new List<SubLocation>();
            }
            return sublocations1 ;
        } set;
    }

    public List<AfleverenSublocs> occupiedSublocs {
        get {
            if (occupiedSublocs == null) {
                occupiedSublocs = new List<AfleverenSublocs>();
            }
            return occupiedSublocs ;
        }set;
    }

    public Map<Id, WWW__c> wwwById {
        get{
            if (wwwById == null) {
                wwwById = WWWDetailHelper.fillMapWwwRecordsById();
            }
            return wwwById;
        } set;
    }

    public String wwwId {get; set;}
    public String projectId {get; set;}

    public Id isChecked {get; set;}

    //public Map<Id, WWW__c> wwwById = WWWDetailHelper.fillMapWwwRecordsById();

    public NewDeliveredExtension (ApexPages.StandardController controller) {
        detail.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');

        Map<Id, RecordType> recByNames = new Map<Id, RecordType>([select Id, Name, DeveloperName from RecordType where sObjectType = 'WWW_detail__c']);
        if (detail.RecordTypeId != null) {
            if (recByNames.get(detail.RecordTypeId).DeveloperName == 'Invoked') {
                invoked = true;
            } else if (recByNames.get(detail.RecordTypeId).DeveloperName == 'Reserved') {
                reserved = true;
            } else if (recByNames.get(detail.RecordTypeId).DeveloperName == 'Delivered_2_Hub') {
                delToHub = true;
            } else if (recByNames.get(detail.RecordTypeId).DeveloperName == 'Delivered_2_Project') {
                delToProj = true;
            } else {
                rejected  = true;
            }
        }

       getProjects();
    }

    public List<SelectOption> getProjects() {
        List<SelectOption> options = new List<SelectOption>();
        Map<Id, Projecten__c> prById= new Map<Id, Projecten__c>([select Id, Name from Projecten__c order by CreatedDate desc]);

        detail.Project__c = prById.values().get(0).id;
        for (Projecten__c rec: prById.values()) {
            if (www.Project__c  == null) {
                www.Project__c = rec.id;
            }
            options.add(new SelectOption(rec.Id, rec.Name));
        }

        return options;
    }

    public List<SelectOption> getTimes() {
        List<SelectOption> options = WWWDetailHelper.fillTimesSelectList();

        return options;
    }

    public List<SelectOption> getrecordTypes() {
        List<SelectOption> options = WWWDetailHelper.fillRecordTypesSelectListBySobject('WWW_Detail__c');

        return options;
    }

    public void getSubs() {
        sublocations1 = WWWDetailHelper.getSublocations(detail.Location__c);
    }

    public void getOccupiedSubs() {
        occupiedSublocs = WWWDetailHelper.getSublocationsForAfleveren(detail.Location__c, www.Id);
    }

    //public List<SelectOption> getWWWs() {
    //    List<SelectOption> options = new List<SelectOption>();

    //    detail.WWW__c = wwwById.values().get(0).id;
    //    for (WWW__c rec: wwwById.values()) {
    //        options.add(new SelectOption(rec.Id, rec.Name));
    //    }

    //    return options;
    //}

    public PageReference goToNewView() {
        PageReference pr = new PageReference('/apex/New_delivered_detail?RecordType=' + isChecked );
        pr.setRedirect(true);
        return pr;
    }

    public PageReference redBack() {
        PageReference pr = new PageReference('/apex/ChoseRecordType');
        pr.setRedirect(true);
        return pr;
    }

    public List<SelectOption> getLocationsForDelToPr() {
        List<SelectOption> options = WWWDetailHelper.getLocationsForAfleveren(www.id);

        return options;
    }

    public void setWWW () {
        detail.Location__c = null;
        www = wwwById.get(detail.WWW__c);
    }

    public PageReference saveDetail () {
        try {
            String paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Date_Of_Delivery');
            detail.Date_Of_Delivery__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Opslagduur__c');
            detail.Opslagduur__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime2);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Arrival_Truck_On_Hub__c');
            detail.Arrival_Truck_On_Hub__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime3);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Einddatum_opslag__c');
            detail.Einddatum_opslag__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime7);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Arrival_Truck_On_Project__c');
            detail.Arrival_Truck_On_Project__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime4);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Preferred_Delivery_Time__c');
            detail.Preferred_Delivery_Time__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime6);

            //FIELDS VALIDATION GOES NEXT
            String fieldsValidationError = WWWDetailHelper.customValidation(detail, sublocations1, occupiedSublocs, www, delToHub, delToProj, invoked, reserved);
            if (fieldsValidationError != '' && fieldsValidationError.length() > 0) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, fieldsValidationError,'');
                ApexPages.addMessage(myMsg);
                return null;
            }

            String locationWithSubs = WWWDetailHelper.makeSublocationStringForDelToHub(sublocations1, occupiedSublocs);
            if ((delToProj || delToHub) && !String.isBlank(locationWithSubs)) {
                detail.WWWD_sublocations__c = locationWithSubs;
            }

            insert detail;

            if (invoked) {
                String fullURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
                www = WWWDetailHelper.getWwwRecordById(www.Id);

                AfroepenAgenda__c afroepenAgenda = new AfroepenAgenda__c();
                afroepenAgenda.Extra_Remarks__c = detail.Extra_Remarks__c;
                afroepenAgenda.Preferred_Delivery_Time__c = detail.Preferred_Delivery_Time__c;
                //afroepenAgenda.End_Delivery_Time__c = makeDatetime(deliveryDate, '23:59');
                afroepenAgenda.ItemsAfroepen__c = www.Item__r.Name + ' ( ' +  detail.Number_Of_Items__c + ' ) \n';
                afroepenAgenda.ItemsList__c = '<a href="' + fullURL + detail.Id + '" >' + www.Item__r.Name + ' ( ' +  detail.Number_Of_Items__c + ' ) </a> <br />';
                afroepenAgenda.Project__c = www.Project__c;

                insert afroepenAgenda;
            }

            List <SubLocationDetail__c> locDets = WWWDetailHelper.generateSublocationDetailsToInsert(detail, delToProj, occupiedSublocs, sublocations1);
            insert locDets;

            return new PageReference('/' + detail.id);
        } catch (DMLException  e) {
            String message = WWWDetailHelper.cutErrorMessage(e.getMessage());

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message, '');
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
}