public class WWWDetailExtension {

    public WWW_Detail__c detail {
        get {
            if (detail == null) {
                detail = new WWW_Detail__c ();
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
        } set;}
    public String selectedTime2 {
        get {
            if(selectedTime2 == null)
            {
                selectedTime2 = '8:00';
            }
            return selectedTime2;
        } set;}
    public String selectedTime3 {
        get {
            if(selectedTime3 == null)
            {
                selectedTime3 = '8:00';
            }
            return selectedTime3;
        } set;}
    public String selectedTime4 {
        get {
            if(selectedTime4 == null)
            {
                selectedTime4 = '8:00';
            }
            return selectedTime4;
        } set;}
    public String selectedTime6 {
        get {
            if(selectedTime6 == null)
            {
                selectedTime6 = '8:00';
            }
            return selectedTime6;
        } set;}
    public String selectedTime7 {
        get {
            if(selectedTime7 == null)
            {
                selectedTime7 = '8:00';
            }
            return selectedTime7;
        } set;}

    public WWW__c www {get;set;}

    public Boolean delToHub {
        get {
            if (delToHub == null) {
                delToHub = false;
            }
            return delToHub;
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
    //public Boolean rejected {
    //    get {
    //        if (rejected == null) {
    //            rejected = false;
    //        }
    //        return rejected;
    //    } set;
    //}
    public Boolean delToProj {
        get {
            if (delToProj == null) {
                delToProj = false;
            }
            return delToProj;
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

    public List<SubLocation> sublocations1 {
        get {
            if (sublocations1  == null) {
                sublocations1  = new List<SubLocation>();
            }
            return sublocations1 ;
        } set;
    }

    public List<AfleverenSublocs> occupiedSublocs {
        get {
            if (occupiedSublocs  == null) {
                occupiedSublocs  = new List<AfleverenSublocs>();
            }
            return occupiedSublocs ;
        }set;
    }

    public String param {
        get {
            if (param == null) {
                param = '';
            }
            return param;
        } set;
    }

    @TestVisible String fieldsValidationError = '';

    public WWWDetailExtension(ApexPages.StandardController controller) {
        www = (WWW__c)controller.getRecord();
        www = WWWDetailHelper.getWwwRecordById(www.Id);

        param = ApexPages.currentPage().getParameters().get('param');
        if (param != null && param.indexOf('?') != -1) {
            param = param.substring(0, param.indexOf('?'));
        }
        System.debug('OBDEB constructor param -->> ' + param);

        List<RecordType> recordTypes = WWWDetailHelper.getRecordTypesBySobjectName('WWW_detail__c');
        Map <String, RecordType> recTypes = new Map <String, RecordType>();
        for (RecordType rT: recordTypes) {
            recTypes.put(rT.DeveloperName , rT);
        }

        if (param == 'delToHub') {
            delToHub = true;
            detail.RecordTypeId = recTypes.get('Delivered_2_Hub').Id;
        } else if (param == 'DelToProj') {
            delToProj = true;
            detail.RecordTypeId = recTypes.get('Delivered_2_Project').Id;
        } else if (param == 'Reserved') {
            reserved = true;
            detail.RecordTypeId = recTypes.get('Reserved').Id;
        } else {
            invoked = true;
            detail.RecordTypeId = recTypes.get('Invoked').Id;
        }

        //else if (param == 'Reject') {
        //    rejected = true;
        //    detail.RecordTypeId = recTypes.get('Rejected').Id;
        //}
    }

    public PageReference redirectDelToHub(){
        System.debug('OBDEB REDIRECT DELTOHUB');
        return new PageReference('/apex/New_Invoked?id=' + www.Id + '&param=delToHub');
    }

    public PageReference redirectDelToProj(){
        return new PageReference('/apex/New_Invoked?id=' + www.Id + '&param=DelToProj');
    }

    public PageReference redirectReserved(){
        return new PageReference('/apex/New_Invoked?id=' + www.Id + '&param=Reserved');
    }

    public PageReference redirectReject(){
        return new PageReference('/apex/New_Invoked?id=' + www.Id + '&param=Reject');
    }

    public void getSubs() {
        sublocations1 = WWWDetailHelper.getSublocations(detail.Location__c);
    }

    public List<SelectOption> getTimes() {
        List<SelectOption> options = WWWDetailHelper.fillTimesSelectList();

        return options;
    }

    public void getOccupiedSubs() {
        occupiedSublocs = WWWDetailHelper.getSublocationsForAfleveren(detail.Location__c, www.Id);
    }

    public List<SelectOption> getLocationsForDelToPr() {
        List<SelectOption> options = WWWDetailHelper.getLocationsForAfleveren(www.id);

        return options;
    }

    //public List<SelectOption> getProjects() {
    //    List<SelectOption> options = WWWDetailHelper.getProjectsForVerwatchen();

    //    return options;
    //}

    public PageReference saveDetail() {
        try {
            detail.WWW__c = www.id;

            String paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Arrival_Truck_On_Hub__c');
            detail.Arrival_Truck_On_Hub__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime3);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Einddatum_opslag__c');
            detail.Einddatum_opslag__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime7);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Date_Of_Delivery');
            detail.Date_Of_Delivery__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Opslagduur__c');
            detail.Opslagduur__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime2);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Preferred_Delivery_Time__c');
            detail.Preferred_Delivery_Time__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime6);

            paramDateOfDelivery = ApexPages.currentPage().getParameters().get('Arrival_Truck_On_Project__c');
            detail.Arrival_Truck_On_Project__c = WWWDetailHelper.madeDateFromNewDatepicker(paramDateOfDelivery, selectedTime4);


            //FIELDS VALIDATION GOES NEXT
            fieldsValidationError = WWWDetailHelper.customValidation(detail, sublocations1, occupiedSublocs, www, delToHub, delToProj, invoked, reserved);
            if (fieldsValidationError != '' && fieldsValidationError.length() > 0) {
                System.debug('ERROR -->> ' + fieldsValidationError);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, fieldsValidationError, '');
                ApexPages.addMessage(myMsg);
                return null;
            }

            String locationWithSubs = WWWDetailHelper.makeSublocationStringForDelToHub(sublocations1, occupiedSublocs);
            if ((delToProj || delToHub) && !String.isBlank(locationWithSubs)) {
                detail.WWWD_sublocations__c = locationWithSubs;
            }

            System.debug('detail ' + detail);
            insert detail;

            if (invoked) {
                String fullURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';

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

            return new PageReference('/' + www.id);
        } catch (Exception e) {
            String message = WWWDetailHelper.cutErrorMessage(e.getMessage());

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message, '');
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
}