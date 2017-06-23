public with sharing class CreateTicketExtension {
    public ComponentData compData {get; set;}

    public Building_Ticket__c ticket {
        get {
            if (ticket == null) {
                ticket = new Building_Ticket__c();
            }
            return ticket;
        } set;
    }

    public Boolean forceUser {
        get {
            if (forceUser == null) {
                User user = [select Id, AccountId__c, Profile.Name from User where id =: UserInfo.getUserId()];
                if (user.Profile.Name == 'Bouwmanager' || user.Profile.Name == 'Bouwticket account') {
                    forceUser = true;
                    ticket.Account__c = user.AccountId__c;
                } else {
                    forceUser = false;
                }
            }
            return forceUser;
        } set;
    }

    @AuraEnabled
    public static String locationSelected {get; set;}
    public static String accountSelected {get; set;}
    @AuraEnabled
    public static String gateSelected {get; set;}
    @AuraEnabled
    public static String hubSelected {get; set;}
    @AuraEnabled
    public static String vTSelected {get; set;}
    @AuraEnabled
    public static String normalFormatDate {get; set;}
    @AuraEnabled
    public static String managerSelected {get; set;}
    public static String project {get; set;}
    @AuraEnabled
    public static String cloneFrom {get; set;}

    @AuraEnabled
    public static String dOfDelivery {get; set;}
    @AuraEnabled
    public static String dOfActivity {get; set;}
    

    public static Map<String, String> hubNameById {get; set;}

    public String errorMessageArrivTime {get; set;}
    public String errorMessageLAUTime {get; set;}
    public String errorMessageDelTime {get; set;}
    public String message {get; set;}
    public String lAuTimeHours {get; set;}
    public String lAuTime{get; set;}
    public String arrivalTimeHours{get; set;}
    public String arrivalTime{get; set;}
    public String destinatioId {get; set;}

    private ApexPages.StandardController contr;

    public CreateTicketExtension(ApexPages.StandardController controller) {
        this.contr = controller;
        compData = new ComponentData ();
        compData.hubSelected = hubSelected;
        hubSelected = ApexPages.currentPage().getParameters().get('hubSelected');

        cloneFrom = ApexPages.currentPage().getParameters().get('cloneFrom');
        compData.cloneFrom = cloneFrom;
    }

    public CreateTicketExtension() {
        compData = new ComponentData ();
        hubSelected = ApexPages.currentPage().getParameters().get('hubSelected');
        compData.hubSelected = hubSelected;
    }

    public PageReference step2() {
        return new PageReference('/apex/CreateTicket?hubSelected=' + hubSelected);
    }

    public void getComponentData() {
        compData = new ComponentData ();
        compData.hubSelected = hubSelected;
        compData.cloneFrom = cloneFrom;


        if (cloneFrom != null) {
            cloneTicket(cloneFrom);
        }
    }

    public void setInfo() {
        ticket.Hub_Building_Site__c = hubSelected;
        if (ApexPages.currentPage().getParameters().get('deliveryTime') != '') {
            ticket.Delivery_Date__c =  Date.valueOf(ApexPages.currentPage().getParameters().get('deliveryTime'));
            normalFormatDate = String.valueOf(ticket.Delivery_Date__c.year()+'-'+ticket.Delivery_Date__c.month()+'-'+ticket.Delivery_Date__c.day());
        }
        compData.dateSelected = normalFormatDate;
    }

    public PageReference customReturn() {
        PageReference cancel = contr.cancel();
        return cancel;
    }

    public PageReference saveTicket() {
        message = 'This field is required';

        ticket.Gate__c = gateSelected;
        ticket.Location__c = locationSelected;
        ticket.Hub_Building_Site__c = hubSelected;
        ticket.Vertical_transport__c = vTSelected;
        ticket.Projectmember__c = managerSelected;
        ticket.Project__c = project;
        ticket.Destination__c = destinatioId;

        if (ApexPages.currentPage().getParameters().get('deliveryTime') != '') {
            ticket.Delivery_Date__c =  Date.valueOf(ApexPages.currentPage().getParameters().get('deliveryTime'));
        } else {
            errorMessageDelTime = message;
            return null;
        }

        if (arrivalTime != null && arrivalTimeHours != null) {
            ticket.Arrival_Time__c = Datetime.newInstance(ticket.Delivery_Date__c.year(), ticket.Delivery_Date__c.month(),
                        ticket.Delivery_Date__c.day(), Integer.valueOf(arrivalTimeHours), Integer.valueOf(arrivalTime), 0);
        } else {
            errorMessageArrivTime = message;
            return null;
        }

        if (arrivalTime == '0' && arrivalTimeHours == '0') {
            errorMessageArrivTime = message;
            return null;
        }

        if (lAuTime != null) {
            Decimal hours = 0;
            if (lAuTimeHours  != null) {
                hours = Decimal.valueOf(lAuTimeHours);
            }

            Decimal minutes = 0;
            if (lAuTime != null) {
                minutes = Decimal.valueOf(lAuTime );
            }

            ticket.Loading_And_Unloading_Time__c = hours * 60 + minutes;
        } else {
            errorMessageLAUTime = message;
            return null;
        }

        if (lAuTime == '0' && lAuTimeHours == '0') {
            errorMessageLAUTime = message;
            return null;
        }

        ticket.End_Point__c = ApexPages.currentPage().getParameters().get('endPoint');
        ticket.Description_Of_Delivery__c =  ApexPages.currentPage().getParameters().get('descrOfDelivery');
        ticket.Description_Of_Activity__c =  ApexPages.currentPage().getParameters().get('descrOfActivity');

        try{
            insert ticket;
            return new PageReference('/' + ticket.id);
        } catch(Exception e) {
            System.debug(e.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error.'+e.getMessage() );
            ApexPages.addMessage(myMsg);
            return null;
        }

        return null;
    }

    public void cloneTicket(String clFrom){
        Set<Id> ticketId = new Set<Id>();
        ticketId.add(clFrom);

        Building_Ticket__c buildingTicketToClone = [SELECT Id, Account__c, Location__c, Hub_Building_Site__c, Gate__c, Vertical_transport__c, Projectmember__c, Destination__c,
                                                            Self_solving__c, Project__c, Delivery_Date__c, Arrival_Time__c, Loading_Unloading_Time_hours__c,
                                                            Loading_And_Unloading_Time__c, Transporteur__c, Description_Of_Activity__c, Description_Of_Delivery__c, End_Point__c
                                                        FROM Building_Ticket__c
                                                        WHERE Id IN: ticketId limit 1];

        if (null != buildingTicketToClone) {
            ticket = buildingTicketToClone.clone(false, true, false, false);

            getHubs();
            //getManagers();
            getGates();
            getDestinations();

            hubSelected = ticket.Hub_Building_Site__c;
            gateSelected = ticket.Gate__c;
            locationSelected = ticket.Location__c;
            vTSelected = ticket.Vertical_transport__c;
            managerSelected = ticket.Projectmember__c;
            destinatioId = ticket.Destination__c;
            System.debug('OBDEB managerSelected -->> ' + managerSelected);

            project = ticket.Project__c;

            dOfDelivery = ticket.Description_Of_Delivery__c;
            dOfActivity = ticket.Description_Of_Activity__c;

            /*was commented*/
            //Decimal tmpHours = ticket.Loading_And_Unloading_Time__c / 60;
            //lAuTimeHours = String.valueOf(tmpHours.intValue());

            //Decimal tmpMinutes = (tmpHours - tmpHours.round(System.RoundingMode.FLOOR)) * 60;
            //lAuTime = String.valueOf(tmpMinutes.intValue());
            /*was commented*/

            Datetime dt = ticket.Arrival_Time__c;
            arrivalTimeHours = String.valueOf(dt.hour());
            arrivalTime = String.valueOf(dt.minute());
        }
    }

    public static List<SelectOption> getLocations() {
        hubSelected = ApexPages.currentPage().getParameters().get('hubSelected');

        List<SelectOption> options = new List<SelectOption>();
        List<Location__c> locations = new List<Location__c>();

        locations = [SELECT Activity_Description__c, Box_Number__c, CreatedById, CreatedDate, IsDeleted, Depth__c,
                                M2_Height__c, Hub_Building_Site__c, LastActivityDate, LastModifiedById, LastModifiedDate,
                                Level__c, Name, Max_Weight_p_m2__c, OwnerId, Pallet_Place__c, Id, RecordTypeId, SF_ID__c,
                                Section__c, Shelving_Subdivision__c, SystemModstamp, Warehouse__c, Width__c
                            FROM Location__c
                            where RecordType.Name = 'Site Location' and Hub_Building_Site__c = :hubSelected];

        options.add(new SelectOption('', ''));
        for (Location__c loc : locations) {
            options.add(new SelectOption(loc.id, loc.Name));
        }

        return options;
    }

    public static List<SelectOption> getManagers() {
        //managerSelected = ApexPages.currentPage().getParameters().get('managerSelected');
        //System.debug('248 OBDEB managerSelected -->> ' + managerSelected);

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));

        Hub_Building_Site__c buildSite = [Select Project__c from Hub_Building_Site__c where id=: hubSelected];
        project = buildSite.Project__c;

        List <Projectmember__c> managers = [SELECT Id, Project_Member_Name__c
                                            FROM  Projectmember__c
                                            Where  Project__c =: buildSite.Project__c];

        for (Projectmember__c manager : managers) {
            options.add(new SelectOption(manager.id, manager.Project_Member_Name__c));
        }

        return options;
    }

    public static List<SelectOption> getAccounts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));

        List <Account> accounts = [select Id, Name from Account];
        for (Account acc : accounts) {
            options.add(new SelectOption(acc.id, acc.Name));
        }

        return options;
    }

    public static List<SelectOption> getGates() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));

        hubSelected = ApexPages.currentPage().getParameters().get('hubSelected');

        List <Location__c> locations = [SELECT Activity_Description__c, Box_Number__c, CreatedById, CreatedDate, IsDeleted, Depth__c,
                                            M2_Height__c, Hub_Building_Site__c, LastActivityDate, LastModifiedById, LastModifiedDate,
                                            Level__c, Name, Max_Weight_p_m2__c, OwnerId, Pallet_Place__c, Id, RecordTypeId, SF_ID__c,
                                            Section__c, Shelving_Subdivision__c, SystemModstamp, Warehouse__c, Width__c
                                        FROM Location__c
                                        where RecordType.Name = 'Gate' and Hub_Building_Site__c=:hubSelected];

        for (Location__c loc : locations) {
            options.add(new SelectOption(loc.id, loc.Name));
        }

        return options;
    }

    public static List<SelectOption> getHubs() {
        hubNameById = new Map<String, String>();
        hubSelected = ApexPages.currentPage().getParameters().get('hubSelected');

        List<SelectOption> options = new List<SelectOption>();

        List <Hub_Building_Site__c> hubs = [SELECT City__c, CreatedById, CreatedDate, IsDeleted, Description_Hub__c, Name, LastActivityDate,
                                                    LastModifiedById, LastModifiedDate, OwnerId, Postalcode__c, Id, RecordTypeId, SF_ID__c,
                                                    Street__c, SystemModstamp
                                            FROM Hub_Building_Site__c
                                            WHERE RecordType.Name = 'Building Site' ];
        for (Hub_Building_Site__c hub : hubs) {
            hubNameById.put(hub.id, hub.Name);
            options.add(new SelectOption(hub.id, hub.Name));
        }

        return options;
    }

    public static List<SelectOption> getVerticalTransports() {
        hubSelected = ApexPages.currentPage().getParameters().get('hubSelected');

        List<SelectOption> options = new List<SelectOption>();

        List <Location__c> locs = [SELECT Activity_Description__c, Box_Number__c, CreatedById, CreatedDate, IsDeleted, Depth__c,
                                            M2_Height__c, Hub_Building_Site__c, LastActivityDate, LastModifiedById, LastModifiedDate,
                                            Level__c, Name, Max_Weight_p_m2__c, OwnerId, Pallet_Place__c, Id, RecordTypeId, SF_ID__c,
                                            Section__c, Shelving_Subdivision__c, SystemModstamp, Warehouse__c, Width__c
                                        FROM Location__c
                                        where RecordType.Name = 'Vertical Transport' and Hub_Building_Site__c=:hubSelected];

        Map <Id, Location__c> locsById = new Map <Id, Location__c>(locs);
        // CHANGE BEFORE DEPLOY
        String parentId = ApexPages.currentPage().getParameters().get('CF00N8E000000HF5d_lkid');
        if ( parentId != null) {
            options.add(new SelectOption(parentId, locsById.get(parentId).Name));
        } else {
            options.add(new SelectOption('', ''));
        }

        for (Location__c loc : locs) {
            options.add(new SelectOption(loc.id, loc.Name));
        }

        return options;
    }

    public List<SelectOption> getMinutes() {
        List<SelectOption> options = new List<SelectOption>();

        for (Integer i =0; i< 60; i+=15) {
            if (i == 0) {
                options.add(new SelectOption(String.valueOf(i), '0' + String.valueOf(i)));
            } else {
                options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
            }
        }

        return options;
    }

    public List<SelectOption> getHours() {
        List<SelectOption> options = new List<SelectOption>();

        for (Integer i = 0; i < 24; i++) {
            String val = String.valueOf(i);
            if (String.valueOf(i).length() == 1) {
                val = '0' + String.valueOf(i);
            }

            options.add(new SelectOption(String.valueOf(i), val));
        }

        return options;
    }

    public List<SelectOption> getDestinations() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));

        List<Destination__c> destinationsList = [Select Id, Name from Destination__c where Hub_Building_Site__c = :hubSelected];
        if (destinationsList != null && !destinationsList.isEmpty()) {
            for(Destination__c dest : destinationsList) {
                options.add(new SelectOption(dest.Id, dest.Name));
            }
        }

        return options;
    }
}