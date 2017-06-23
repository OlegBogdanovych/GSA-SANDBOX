@isTest
private class CreateTicketAndCallendarTest {
    @isTest static void test_createTicket(){
        TestDataGenerator.fillTriggerSwitcherValues();

        Account account = TestDataGenerator.createBouwticketAccount('testAccount');
        Contact contact = TestDataGenerator.createTestContact(account);

        User user;
        Test.startTest();
            user = TestDataGenerator.createTestBouwticketUser(account);
        Test.stopTest();

        Projecten__c project = TestDataGenerator.createTestProject(account, 'testestest');
        Projectmember__c member = TestDataGenerator.createTestProjectMember(project, contact);
        Hub_Building_Site__c buldingSite = TestDataGenerator.createTestHubBuildingSite('Test Building Site', project);
        Location__c gate = TestDataGenerator.createTestGateLocation('TestGate');
        Location__c siteL = TestDataGenerator.createTestSiteLocation(buldingSite, 'Test Site Location');
        Location__c verTr = TestDataGenerator.createTestVerticalTransport('Test Vertical Transport');

        ApexPages.StandardController st = new ApexPages.StandardController (new Building_Ticket__c());
        CreateTicketExtension ct = new CreateTicketExtension();
        CreateTicketExtension ctrl = new CreateTicketExtension(st);

        CreateTicketExtension.getGates();
        CreateTicketExtension.getHubs();
        CreateTicketExtension.getLocations();

        List<SelectOption> minutes = ct.getMinutes();
        List<SelectOption> hours = ct.getHours();
        List<SelectOption> accs = CreateTicketExtension.getAccounts();
        System.runAs(user) {
            Boolean forceUser = ct.forceUser;
        }

        ctrl.getComponentData();

        CreateTicketExtension.getVerticalTransports();
        CreateTicketExtension.gateSelected = gate.id;
        CreateTicketExtension.hubSelected = buldingSite.id;
        CreateTicketExtension.getManagers() ;
        CreateTicketExtension.locationSelected = siteL.id;
        CreateTicketExtension.vTSelected = verTr.id;
        CalendarComponentController calendatCtrl = new CalendarComponentController();
        calendatCtrl.componentData = new ComponentData();
        calendatCtrl.componentData.hubSelected = buldingSite.id;
        calendatCtrl.componentData.dateSelected = '2015-12-25';
        calendatCtrl.getJsonForCalendar();

        Test.setCurrentPageReference(Page.CreateTicket);
        System.currentPageReference().getParameters().put('deliveryTime', '2015-12-25');
        System.currentPageReference().getParameters().put('arrivalTime', '30');
        System.currentPageReference().getParameters().put('lAuTime', '45');
        System.currentPageReference().getParameters().put('arrivalTimeHours', '1');
        System.currentPageReference().getParameters().put('lAuTimeHours', '0');
        System.currentPageReference().getParameters().put('managerSelected', member.id);

        ctrl.lAuTimeHours = '1';
        ctrl.lAuTime = '15';
        ctrl.arrivalTimeHours = '1';
        ctrl.arrivalTime = '15';
        ctrl.setInfo();
        ctrl.saveTicket();

        Test.setCurrentPageReference(Page.Calendar);
        Building_Ticket__c t = new Building_Ticket__c(Gate__c = gate.id , Hub_Building_Site__c = buldingSite.id, Location__c = siteL.id, Projectmember__c = member.id,
                        Vertical_Transport__c = verTr.id, Project__c = project.id, Arrival_Time__c = datetime.now(), Delivery_Date__c = Date.today(), Loading_And_Unloading_Time__c = 45,  Account__c = account.id );
        insert t;

        List<Building_Ticket__c> tickets = [select Id from Building_Ticket__c limit 1];
        System.assertEquals(1, tickets.size());

        st = new ApexPages.StandardController(tickets.get(0));

        CalendarExtension ctrl1 = new CalendarExtension(st);
        CalendarComponentController ctrl2 = new CalendarComponentController();

        ctrl2.componentData = new ComponentData();
        ctrl2.componentData.hubSelected = buldingSite.id;
        ctrl2.componentData.dateSelected = '2015-12-25';
        ctrl2.getJsonForCalendar();
        ctrl2.leftIds.add(verTr.id);
        ctrl2.getJsonForCalendar();
        ctrl2.change();
        ctrl2.getbodyForTable();

        /**/
        String count = ctrl2.count;
        /**/
        tickets.get(0).Status__c = 'Assigned';
        update tickets;

        tickets = [select Id, UserId__c from Building_Ticket__c];
        System.assertNotEquals(null, tickets.get(0).UserId__c);

        TicketPDFExtension pdfCtrl = new TicketPDFExtension();
        pdfCtrl.ticketRecord = tickets.get(0);
        pdfCtrl.showPrintButton = '1';

        Boolean init = pdfCtrl.getInit();

        Hub_Building_Site__c buldingSite1 = TestDataGenerator.createTestHubBuildingSite('Test Building Site', null);

        AccountHub__c acH = new AccountHub__c(Account__c = account.id, Hub_Building_Site__c = buldingSite1.Id );
        insert acH;

        System.assertEquals(1, [SELECT  AccountId, Id, UserOrGroupId 
                                                FROM AccountShare where UserOrGroupId =: user.id].size());
        System.assertEquals(2, [SELECT   UserOrGroupId 
                                                FROM Hub_Building_site__Share where UserOrGroupId =: user.id].size());
        System.assertEquals(1, [SELECT   UserOrGroupId 
                                                FROM Location__Share where UserOrGroupId =: user.id].size());
        System.assertEquals(2, [SELECT   UserOrGroupId 
                                                FROM Building_Ticket__Share where UserOrGroupId =: user.id].size());
    }

    @isTest static void test_cloneTicket() {
        TestDataGenerator.fillTriggerSwitcherValues();

        Account account = TestDataGenerator.createBouwticketAccount('testAccount');
        Contact contact = TestDataGenerator.createTestContact(account);

        User user;
        Test.startTest();
            user = TestDataGenerator.createTestBouwticketUser(account);
        Test.stopTest();

        Projecten__c project = TestDataGenerator.createTestProject(account, 'testestest');
        Projectmember__c member = TestDataGenerator.createTestProjectMember(project, contact);
        Hub_Building_Site__c buldingSite = TestDataGenerator.createTestHubBuildingSite('Test Building Site', project);
        Location__c gate = TestDataGenerator.createTestGateLocation('TestGate');
        Location__c siteL = TestDataGenerator.createTestSiteLocation(buldingSite, 'Test Site Location');
        Location__c verTr = TestDataGenerator.createTestVerticalTransport('Test Vertical Transport');

        Building_Ticket__c t = new Building_Ticket__c(Gate__c = gate.id , Hub_Building_Site__c = buldingSite.id, Location__c = siteL.id, Projectmember__c = member.id,
                        Vertical_Transport__c = verTr.id, Project__c = project.id, Arrival_Time__c = datetime.now(), Delivery_Date__c = Date.today(), Loading_And_Unloading_Time__c = 45,  Account__c = account.id );
        insert t;

        PageReference pageRef = Page.CreateTicket;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('hubSelected', buldingSite.id);
        ApexPages.currentPage().getParameters().put('cloneFrom', t.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(new Building_Ticket__c());
        CreateTicketExtension ctrl = new CreateTicketExtension(sc);

        ctrl.getComponentData();

        ctrl.customReturn();
    }

    @isTest static void test_negativeDeliveryTime(){
        TestDataGenerator.fillTriggerSwitcherValues();

        Account account = TestDataGenerator.createBouwticketAccount('testAccount');
        Contact contact = TestDataGenerator.createTestContact(account);

        User user;
        Test.startTest();
            user = TestDataGenerator.createTestBouwticketUser(account);
        Test.stopTest();

        Projecten__c project = TestDataGenerator.createTestProject(account, 'testestest');
        Projectmember__c member = TestDataGenerator.createTestProjectMember(project, contact);
        Hub_Building_Site__c buldingSite = TestDataGenerator.createTestHubBuildingSite('Test Building Site', project);
        Location__c gate = TestDataGenerator.createTestGateLocation('TestGate');
        Location__c siteL = TestDataGenerator.createTestSiteLocation(buldingSite, 'Test Site Location');
        Location__c verTr = TestDataGenerator.createTestVerticalTransport('Test Vertical Transport');

        ApexPages.StandardController st = new ApexPages.StandardController (new Building_Ticket__c());
        CreateTicketExtension ct = new CreateTicketExtension();
        CreateTicketExtension ctrl = new CreateTicketExtension(st);

        CreateTicketExtension.getGates();
        CreateTicketExtension.getHubs();
        CreateTicketExtension.getLocations();

        List<SelectOption> minutes = ct.getMinutes();
        List<SelectOption> hours = ct.getHours();
        List<SelectOption> accs = CreateTicketExtension.getAccounts();
        System.runAs(user) {
            Boolean forceUser = ct.forceUser;
        }

        ctrl.getComponentData();

        CreateTicketExtension.getVerticalTransports();
        CreateTicketExtension.gateSelected = gate.id;
        CreateTicketExtension.hubSelected = buldingSite.id;
        CreateTicketExtension.getManagers() ;
        CreateTicketExtension.locationSelected = siteL.id;
        CreateTicketExtension.vTSelected = verTr.id;
        CalendarComponentController calendatCtrl = new CalendarComponentController();
        calendatCtrl.componentData = new ComponentData();
        calendatCtrl.componentData.hubSelected = buldingSite.id;
        calendatCtrl.componentData.dateSelected = '2015-12-25';
        calendatCtrl.getJsonForCalendar();

        Test.setCurrentPageReference(Page.CreateTicket);
        System.currentPageReference().getParameters().put('deliveryTime', '');
        System.currentPageReference().getParameters().put('hubSelected', buldingSite.id);
        System.currentPageReference().getParameters().put('arrivalTime', '30');
        System.currentPageReference().getParameters().put('lAuTime', '45');
        System.currentPageReference().getParameters().put('arrivalTimeHours', '1');
        System.currentPageReference().getParameters().put('lAuTimeHours', '0');
        System.currentPageReference().getParameters().put('managerSelected', member.id);

        ctrl.lAuTimeHours = '1';
        ctrl.lAuTime = '15';
        ctrl.arrivalTimeHours = '1';
        ctrl.arrivalTime = '15';
        ctrl.setInfo();
        ctrl.saveTicket();
    }

    @isTest static void test_negativeArrivalTime(){
        TestDataGenerator.fillTriggerSwitcherValues();

        Account account = TestDataGenerator.createBouwticketAccount('testAccount');
        Contact contact = TestDataGenerator.createTestContact(account);

        User user;
        Test.startTest();
            user = TestDataGenerator.createTestBouwticketUser(account);
        Test.stopTest();

        Projecten__c project = TestDataGenerator.createTestProject(account, 'testestest');
        Projectmember__c member = TestDataGenerator.createTestProjectMember(project, contact);
        Hub_Building_Site__c buldingSite = TestDataGenerator.createTestHubBuildingSite('Test Building Site', project);
        Location__c gate = TestDataGenerator.createTestGateLocation('TestGate');
        Location__c siteL = TestDataGenerator.createTestSiteLocation(buldingSite, 'Test Site Location');
        Location__c verTr = TestDataGenerator.createTestVerticalTransport('Test Vertical Transport');

        ApexPages.StandardController st = new ApexPages.StandardController (new Building_Ticket__c());
        CreateTicketExtension ct = new CreateTicketExtension();
        CreateTicketExtension ctrl = new CreateTicketExtension(st);

        CreateTicketExtension.getGates();
        CreateTicketExtension.getHubs();
        CreateTicketExtension.getLocations();

        List<SelectOption> minutes = ct.getMinutes();
        List<SelectOption> hours = ct.getHours();
        List<SelectOption> accs = CreateTicketExtension.getAccounts();
        System.runAs(user) {
            Boolean forceUser = ct.forceUser;
        }

        ctrl.getComponentData();

        CreateTicketExtension.getVerticalTransports();
        CreateTicketExtension.gateSelected = gate.id;
        CreateTicketExtension.hubSelected = buldingSite.id;
        CreateTicketExtension.getManagers() ;
        CreateTicketExtension.locationSelected = siteL.id;
        CreateTicketExtension.vTSelected = verTr.id;
        CalendarComponentController calendatCtrl = new CalendarComponentController();
        calendatCtrl.componentData = new ComponentData();
        calendatCtrl.componentData.hubSelected = buldingSite.id;
        calendatCtrl.componentData.dateSelected = '2015-12-25';
        calendatCtrl.getJsonForCalendar();

        Test.setCurrentPageReference(Page.CreateTicket);
        System.currentPageReference().getParameters().put('deliveryTime', '2015-12-25');
        System.currentPageReference().getParameters().put('hubSelected', buldingSite.id);
        System.currentPageReference().getParameters().put('arrivalTime', '');
        System.currentPageReference().getParameters().put('lAuTime', '45');
        System.currentPageReference().getParameters().put('arrivalTimeHours', '1');
        System.currentPageReference().getParameters().put('lAuTimeHours', '0');
        System.currentPageReference().getParameters().put('managerSelected', member.id);

        ctrl.lAuTimeHours = '1';
        ctrl.lAuTime = '15';
        ctrl.arrivalTimeHours = '1';
        ctrl.arrivalTime = null;
        ctrl.setInfo();
        ctrl.saveTicket();

        ctrl.lAuTimeHours = '1';
        ctrl.lAuTime = '15';
        ctrl.arrivalTimeHours = '0';
        ctrl.arrivalTime = '0';
        ctrl.setInfo();
        ctrl.saveTicket();
    }

    @isTest static void test_negativeDurationTime(){
        TestDataGenerator.fillTriggerSwitcherValues();

        Account account = TestDataGenerator.createBouwticketAccount('testAccount');
        Contact contact = TestDataGenerator.createTestContact(account);

        User user;
        Test.startTest();
            user = TestDataGenerator.createTestBouwticketUser(account);
        Test.stopTest();

        Projecten__c project = TestDataGenerator.createTestProject(account, 'testestest');
        Projectmember__c member = TestDataGenerator.createTestProjectMember(project, contact);
        Hub_Building_Site__c buldingSite = TestDataGenerator.createTestHubBuildingSite('Test Building Site', project);
        Location__c gate = TestDataGenerator.createTestGateLocation('TestGate');
        Location__c siteL = TestDataGenerator.createTestSiteLocation(buldingSite, 'Test Site Location');
        Location__c verTr = TestDataGenerator.createTestVerticalTransport('Test Vertical Transport');

        ApexPages.StandardController st = new ApexPages.StandardController (new Building_Ticket__c());
        CreateTicketExtension ct = new CreateTicketExtension();
        CreateTicketExtension ctrl = new CreateTicketExtension(st);

        CreateTicketExtension.getGates();
        CreateTicketExtension.getHubs();
        CreateTicketExtension.getLocations();

        List<SelectOption> minutes = ct.getMinutes();
        List<SelectOption> hours = ct.getHours();
        List<SelectOption> accs = CreateTicketExtension.getAccounts();
        System.runAs(user) {
            Boolean forceUser = ct.forceUser;
        }

        ctrl.getComponentData();

        CreateTicketExtension.getVerticalTransports();
        CreateTicketExtension.gateSelected = gate.id;
        CreateTicketExtension.hubSelected = buldingSite.id;
        CreateTicketExtension.getManagers() ;
        CreateTicketExtension.locationSelected = siteL.id;
        CreateTicketExtension.vTSelected = verTr.id;
        CalendarComponentController calendatCtrl = new CalendarComponentController();
        calendatCtrl.componentData = new ComponentData();
        calendatCtrl.componentData.hubSelected = buldingSite.id;
        calendatCtrl.componentData.dateSelected = '2015-12-25';
        calendatCtrl.getJsonForCalendar();

        Test.setCurrentPageReference(Page.CreateTicket);
        System.currentPageReference().getParameters().put('deliveryTime', '2015-12-25');
        System.currentPageReference().getParameters().put('hubSelected', buldingSite.id);
        System.currentPageReference().getParameters().put('arrivalTime', '');
        System.currentPageReference().getParameters().put('lAuTime', '45');
        System.currentPageReference().getParameters().put('arrivalTimeHours', '1');
        System.currentPageReference().getParameters().put('lAuTimeHours', '0');
        System.currentPageReference().getParameters().put('managerSelected', member.id);

        ctrl.lAuTimeHours = '1';
        ctrl.lAuTime = null;
        ctrl.arrivalTimeHours = '1';
        ctrl.arrivalTime = '15';
        ctrl.setInfo();
        ctrl.saveTicket();

        ctrl.lAuTimeHours = '0';
        ctrl.lAuTime = '0';
        ctrl.arrivalTimeHours = '1';
        ctrl.arrivalTime = '15';
        ctrl.setInfo();
        ctrl.saveTicket();

        ctrl.step2();
    }
}