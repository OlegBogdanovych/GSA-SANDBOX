@isTest
private class NewDeliveredExtensionTest {

	@testSetup static void setup() {
		TestDataGenerator.fillTriggerSwitcherValues();

		Account account = TestDataGenerator.createBouwticketAccount('testAccount');
        Contact contact = TestDataGenerator.createTestContact(account);

        Projecten__c project = TestDataGenerator.createTestProject(account, 'testestest');
        Projectmember__c member = TestDataGenerator.createTestProjectMember(project, contact);
        Hub_Building_Site__c buldingSite = TestDataGenerator.createTestHub('Test Hub', project);

        Item__c item = TestDataGenerator.createTestItem('TestItem', 1);
        Location__c hublocationParent = TestDataGenerator.createTestHublocationParent('20C3', buldingSite);
        List<Location__c> hublocationChilds = TestDataGenerator.createTestHublocationChildren(buldingSite, hublocationParent);

        WWW__c www = TestDataGenerator.createTestWww(project, item, buldingSite);
	}

	@isTest static void test_createOntvangen() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

        Test.startTest();
        	WWW_Detail__c det = new WWW_Detail__c();

        	ApexPages.StandardController sc = new ApexPages.StandardController(det);
        	NewDeliveredExtension ctrl = new NewDeliveredExtension(sc);

        	PageReference tpageRef = Page.ChoseRecordType;
	        Test.setCurrentPage(tpageRef);

	        List<SelectOption> recTypes = ctrl.getrecordTypes();
	        ctrl.isChecked = recTypes.get(3).getValue();
	        System.assertNotEquals(null, ctrl.isChecked, 'Record Type for WWW Detail is not selected. Should be selected Ontvangen record type');

	        tpageRef = ctrl.goToNewView();
	        Test.setCurrentPage(tpageRef);
	        ctrl = new NewDeliveredExtension(sc);
	        System.assertNotEquals(false, ctrl.delToHub, 'Error in constructor. Not Ontvangen record type selected');

	        ctrl.detail.WWW__c = www.Id;
	        ctrl.setWWW();

	        ctrl.detail.Location__c = hublocationParent.Id;
	        ctrl.detail.Number_Of_Items__c = 10;
	        ctrl.detail.Damage_Package__c = 'No';

	        ctrl.getTimes();

	        System.currentPageReference().getParameters().put('Arrival_Truck_On_Hub__c','25.04.2017');
	        System.currentPageReference().getParameters().put('Einddatum_opslag__c','29.04.2017');

	        ctrl.getSubs();

	        System.assertNotEquals(0, ctrl.sublocations1.size(), 'No sublocations for use');

        	for(SubLocation subLoc : ctrl.sublocations1) {
        		subLoc.isChecked = true;
        	}

        	ctrl.saveDetail();
        	WWW_Detail__c toCheck = [Select Id, RecordType.Name from WWW_Detail__c where RecordType.DeveloperName = 'Delivered_2_Hub' limit 1];
        	System.assertEquals(toCheck.Id, ctrl.detail.Id, 'Detail record was not created');
        Test.stopTest();
	}

	@isTest static void test_createOntvangenNegative() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

        Test.startTest();
        	WWW_Detail__c det = new WWW_Detail__c();

        	ApexPages.StandardController sc = new ApexPages.StandardController(det);
        	NewDeliveredExtension ctrl = new NewDeliveredExtension(sc);

        	PageReference tpageRef = Page.ChoseRecordType;
	        Test.setCurrentPage(tpageRef);

	        List<SelectOption> recTypes = ctrl.getrecordTypes();
	        ctrl.isChecked = recTypes.get(3).getValue();
	        System.assertNotEquals(null, ctrl.isChecked, 'Record Type for WWW Detail is not selected. Should be selected Ontvangen record type');

	        tpageRef = ctrl.goToNewView();
	        Test.setCurrentPage(tpageRef);
	        ctrl = new NewDeliveredExtension(sc);
	        System.assertNotEquals(false, ctrl.delToHub, 'Error in constructor. Not Ontvangen record type selected');

	        ctrl.detail.WWW__c = www.Id;
	        ctrl.setWWW();

	        ctrl.detail.Location__c = hublocationParent.Id;
	        ctrl.detail.Damage_Package__c = 'No';

	        System.currentPageReference().getParameters().put('Arrival_Truck_On_Hub__c','25.04.2017');
	        System.currentPageReference().getParameters().put('Einddatum_opslag__c','29.04.2017');

	        ctrl.getSubs();

	        System.assertNotEquals(0, ctrl.sublocations1.size(), 'No sublocations for use');

        	ctrl.saveDetail();
        Test.stopTest();
	}

	@isTest static void test_createAfleveren() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

    	/** CREATE TEST ONTVANGEN **/
    	TestDataGenerator.createTestWwwDetailOntvangen(www, hublocationParent, 10);
    	/** END CREATE TEST ONTVANGEN **/

    	WWW_Detail__c det = new WWW_Detail__c();

    	ApexPages.StandardController sc = new ApexPages.StandardController(det);
    	NewDeliveredExtension ctrl = new NewDeliveredExtension(sc);

    	PageReference tpageRef = Page.ChoseRecordType;
        Test.setCurrentPage(tpageRef);

        List<SelectOption> recTypes = ctrl.getrecordTypes();
        ctrl.isChecked = recTypes.get(0).getValue();
        System.assertNotEquals(null, ctrl.isChecked, 'Record Type for WWW Detail is not selected. Should be selected Afleveren record type');

	    Test.startTest();
	        tpageRef = ctrl.goToNewView();
	        Test.setCurrentPage(tpageRef);
	        ctrl = new NewDeliveredExtension(sc);
	        System.assertNotEquals(false, ctrl.delToProj, 'Error in constructor. Not Afleveren record type selected');

	        ctrl.detail.WWW__c = www.Id;
	        ctrl.setWWW();

	        ctrl.detail.Number_Of_Items__c = 5;
        	ctrl.detail.Compleet_klaargezet__c = 'Ja';

        	List<SelectOption> locsForAfleveren = ctrl.getLocationsForDelToPr();

        	ctrl.detail.Location__c = locsForAfleveren.get(1).getValue();

        	ctrl.getOccupiedSubs();
        	for (AfleverenSublocs subLoc : ctrl.occupiedSublocs) {
        		subLoc.isChecked = true;
        	}

        	System.currentPageReference().getParameters().put('Arrival_Truck_On_Project__c', '27.04.2017');

        	ctrl.saveDetail();

        	/********************************************/
        	WWW_Detail__c det2 = new WWW_Detail__c();

	        ctrl.isChecked = recTypes.get(0).getValue();
        	tpageRef = ctrl.goToNewView();
	        Test.setCurrentPage(tpageRef);
	        sc = new ApexPages.StandardController(det2);
	        ctrl = new NewDeliveredExtension(sc);
	        System.assertNotEquals(false, ctrl.delToProj, 'Error in constructor. Not Afleveren record type selected second type');

	        ctrl.detail.WWW__c = www.Id;
	        ctrl.setWWW();

	        ctrl.detail.Number_Of_Items__c = 5;
        	ctrl.detail.Compleet_klaargezet__c = 'Nee';
        	ctrl.detail.Reden_niet_compleet_uigevoerd__c = 'Stuk';
        	ctrl.detail.Toelichting__c = 'Test decription';

        	locsForAfleveren = ctrl.getLocationsForDelToPr();

        	ctrl.detail.Location__c = locsForAfleveren.get(1).getValue();

        	ctrl.getOccupiedSubs();
        	for (AfleverenSublocs subLoc : ctrl.occupiedSublocs) {
        		subLoc.isChecked = true;
        	}

        	System.currentPageReference().getParameters().put('Arrival_Truck_On_Project__c', '29.04.2017');

        	ctrl.saveDetail();
        Test.stopTest();
    }

    @isTest static void test_failCreateRecvords() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

        Test.startTest();
        	WWW_Detail__c det = new WWW_Detail__c();

        	ApexPages.StandardController sc = new ApexPages.StandardController(det);
        	NewDeliveredExtension ctrl = new NewDeliveredExtension(sc);

        	PageReference tpageRef = Page.ChoseRecordType;
	        Test.setCurrentPage(tpageRef);

	        List<SelectOption> recTypes = ctrl.getrecordTypes();
	        ctrl.isChecked = recTypes.get(3).getValue();
	        System.assertNotEquals(null, ctrl.isChecked, 'Record Type for WWW Detail is not selected. Should be selected Ontvangen record type');

	        tpageRef = ctrl.goToNewView();
	        Test.setCurrentPage(tpageRef);
	        ctrl = new NewDeliveredExtension(sc);
	        System.assertNotEquals(false, ctrl.delToHub, 'Error in constructor. Not Ontvangen record type selected');

	        ctrl.detail.WWW__c = www.Id;
	        ctrl.setWWW();

	        ctrl.detail.Location__c = hublocationParent.Id;
	        ctrl.detail.Number_Of_Items__c = 10;
	        ctrl.detail.Damage_Package__c = 'No';

	        ctrl.getTimes();

	        System.currentPageReference().getParameters().put('Arrival_Truck_On_Hub__c','25.04.2017');
	        System.currentPageReference().getParameters().put('Einddatum_opslag__c','29.04.2017');

	        ctrl.getSubs();

	        System.assertNotEquals(0, ctrl.sublocations1.size(), 'No sublocations for use');

        	for(SubLocation subLoc : ctrl.sublocations1) {
        		subLoc.isChecked = true;
        	}

        	delete www;

        	ctrl.saveDetail();
        Test.stopTest();
	}

	@isTest static void test_returnBackToSelectRecordType() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

        Test.startTest();
        	WWW_Detail__c det = new WWW_Detail__c();

        	ApexPages.StandardController sc = new ApexPages.StandardController(det);
        	NewDeliveredExtension ctrl = new NewDeliveredExtension(sc);

        	PageReference tpageRef = Page.ChoseRecordType;
	        Test.setCurrentPage(tpageRef);

	        List<SelectOption> recTypes = ctrl.getrecordTypes();
	        ctrl.isChecked = recTypes.get(3).getValue();
	        System.assertNotEquals(null, ctrl.isChecked, 'Record Type for WWW Detail is not selected. Should be selected Ontvangen record type');

	        tpageRef = ctrl.goToNewView();
	        Test.setCurrentPage(tpageRef);
	        ctrl = new NewDeliveredExtension(sc);
	        System.assertNotEquals(false, ctrl.delToHub, 'Error in constructor. Not Ontvangen record type selected');

        	ctrl.redBack();
        Test.stopTest();
	}

}