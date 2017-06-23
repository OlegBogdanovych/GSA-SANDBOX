@isTest
private class WWWDetailExtensionTest {

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
        System.debug('hublocationChilds -->> ' + hublocationChilds);

        WWW__c www = TestDataGenerator.createTestWww(project, item, buldingSite);
	}

	@isTest static void test_createOntvangen() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(www);
        	WWWDetailExtension ctrl = new WWWDetailExtension(sc);

        	/** CREATE TEST ONTVANGEN **/
	        	PageReference tpageRef = ctrl.redirectDelToHub();
	        	Test.setCurrentPage(tpageRef);
	        	ctrl = new WWWDetailExtension(sc);
	        	System.assertEquals(true, ctrl.delToHub);

	        	ctrl.getTimes();

	        	ctrl.detail.Location__c = hublocationParent.Id;
	        	ctrl.detail.Number_Of_Items__c = 10;
	        	ctrl.detail.Damage_Package__c = 'No';

				System.currentPageReference().getParameters().put('Arrival_Truck_On_Hub__c','25.04.2017');
	        	System.currentPageReference().getParameters().put('Einddatum_opslag__c','29.04.2017');

	        	ctrl.getSubs();
	        	System.assertNotEquals(0, ctrl.sublocations1.size());

	        	for(SubLocation subLoc : ctrl.sublocations1) {
	        		subLoc.isChecked = true;
	        	}

	        	ctrl.saveDetail();
	        	WWW_Detail__c toCheck = [Select Id, RecordType.Name, Number_Of_Items__c from WWW_Detail__c where RecordType.DeveloperName = 'Delivered_2_Hub' limit 1];
	        	System.assertEquals(toCheck.Id, ctrl.detail.Id);
        	/** END CREATE TEST ONTVANGEN **/

        Test.stopTest();

        toCheck.Number_Of_Items__c = 100;
        update toCheck;

        delete toCheck;
	}

	@isTest static void test_createOntvangenNegative() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(www);
        	WWWDetailExtension ctrl = new WWWDetailExtension(sc);

        	/** CREATE TEST ONTVANGEN **/
	        	PageReference tpageRef = ctrl.redirectDelToHub();
	        	Test.setCurrentPage(tpageRef);
	        	ctrl = new WWWDetailExtension(sc);
	        	System.assertEquals(true, ctrl.delToHub);

	        	ctrl.getTimes();

	        	ctrl.detail.Location__c = hublocationParent.Id;
	        	ctrl.detail.Damage_Package__c = 'No';

				System.currentPageReference().getParameters().put('Arrival_Truck_On_Hub__c','25.04.2017');
	        	System.currentPageReference().getParameters().put('Einddatum_opslag__c','29.04.2017');

	        	ctrl.getSubs();
	        	System.assertNotEquals(0, ctrl.sublocations1.size());

	        	for(SubLocation subLoc : ctrl.sublocations1) {
	        		subLoc.isChecked = true;
	        	}

	        	ctrl.saveDetail();
	        	System.assertNotEquals(0, ctrl.fieldsValidationError.length());
        	/** END CREATE TEST ONTVANGEN **/

        Test.stopTest();
	}

	@isTest static void test_createAfleveren() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

    	/** CREATE TEST ONTVANGEN **/
    	TestDataGenerator.createTestWwwDetailOntvangen(www, hublocationParent, 10);
    	/** END CREATE TEST ONTVANGEN **/

        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(www);
    		WWWDetailExtension ctrl = new WWWDetailExtension(sc);
        	/** CREATE TEST AFLEVEREN **/
	        	PageReference tpageRef = ctrl.redirectDelToProj();
	        	Test.setCurrentPage(tpageRef);
	        	ctrl = new WWWDetailExtension(sc);
	        	System.assertEquals(true, ctrl.delToProj);

	        	ctrl.detail.Number_Of_Items__c = 5;
	        	ctrl.detail.Compleet_klaargezet__c = 'Ja';

	        	List<SelectOption> locsForAfleveren = ctrl.getLocationsForDelToPr();
	        	System.assert(!locsForAfleveren.isEmpty());

	        	ctrl.detail.Location__c = locsForAfleveren.get(1).getValue();

	        	ctrl.getOccupiedSubs();
	        	for (AfleverenSublocs subLoc : ctrl.occupiedSublocs) {
	        		subLoc.isChecked = true;
	        	}

	        	System.currentPageReference().getParameters().put('Arrival_Truck_On_Project__c', '27.04.2017');

	        	ctrl.saveDetail();

	        	/*----------------------------------------------------------------*/

	        	tpageRef = ctrl.redirectDelToProj();
	        	Test.setCurrentPage(tpageRef);
	        	ctrl = new WWWDetailExtension(sc);
	        	System.assertEquals(true, ctrl.delToProj);

	        	ctrl.detail.Number_Of_Items__c = 5;
	        	ctrl.detail.Compleet_klaargezet__c = 'Nee';
	        	ctrl.detail.Reden_niet_compleet_uigevoerd__c = 'Stuk';
	        	ctrl.detail.Toelichting__c = 'Test decription';

	        	locsForAfleveren = ctrl.getLocationsForDelToPr();
	        	System.assert(!locsForAfleveren.isEmpty());

	        	ctrl.detail.Location__c = locsForAfleveren.get(1).getValue();

	        	ctrl.getOccupiedSubs();
	        	for (AfleverenSublocs subLoc : ctrl.occupiedSublocs) {
	        		subLoc.isChecked = true;
	        	}

	        	System.currentPageReference().getParameters().put('Arrival_Truck_On_Project__c', '29.04.2017');

	        	ctrl.saveDetail();
        	/** CREATE TEST AFLEVEREN **/

        Test.stopTest();
	}

	@isTest static void test_createVerwachten() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

    	/** CREATE TEST ONTVANGEN **/
    	TestDataGenerator.createTestWwwDetailOntvangen(www, hublocationParent, 10);
    	/** END CREATE TEST ONTVANGEN **/

        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(www);
    		WWWDetailExtension ctrl = new WWWDetailExtension(sc);

    		/** CREATE TEST VERWACHTEN  **/
    			PageReference tpageRef = ctrl.redirectReserved();
    			Test.setCurrentPage(tpageRef);
	        	ctrl = new WWWDetailExtension(sc);
	        	System.assertEquals(true, ctrl.reserved);

	        	//List<SelectOption> projectsList = ctrl.getProjects();
	        	//ctrl.detail.Project__c = projectsList.get(0).getValue();

	        	ctrl.detail.Grootte_verpakking__c = 'Balen';
	        	ctrl.detail.Number_Of_Items__c = 5;
	        	ctrl.detail.Afroepeenheid__c = 'Balen';

	        	System.currentPageReference().getParameters().put('Date_Of_Delivery', '29.04.2017');
	        	System.currentPageReference().getParameters().put('Opslagduur__c', '29.04.2017');

	        	ctrl.saveDetail();
    		/** END CREATE TEST VERWACHTEN  **/
        Test.stopTest();
    }

    @isTest static void test_createAfroepen() {
		WWW__c www = [Select Id, Name from WWW__c limit 1];
        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

    	/** CREATE TEST ONTVANGEN **/
    	TestDataGenerator.createTestWwwDetailOntvangen(www, hublocationParent, 10);
    	/** END CREATE TEST ONTVANGEN **/

        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(www);
    		WWWDetailExtension ctrl = new WWWDetailExtension(sc);

    		/** CREATE TEST AFROEPEN  **/
    			PageReference tpageRef = Page.New_Invoked;
    			ApexPages.currentPage().getParameters().put('id', www.Id);

    			Test.setCurrentPage(tpageRef);
	        	System.assertEquals(true, ctrl.invoked);

	        	ctrl.detail.Number_Of_Items__c = 5;
	        	System.currentPageReference().getParameters().put('Preferred_Delivery_Time__c', '29.04.2017');

	        	ctrl.saveDetail();
    		/** END CREATE TEST AFROEPEN  **/
        Test.stopTest();
    }

    @istest static void test_failCreateRecvords() {
    	Item__c item = TestDataGenerator.createTestItem('TestItem2', 1);
    	Hub_Building_Site__c buldingSite = [Select Id from Hub_Building_Site__c where Name = 'Test Hub' limit 1];
    	Projecten__c project = [Select Id from Projecten__c where Name = 'testestest' limit 1];
        WWW__c www = TestDataGenerator.createTestWww(project, item, buldingSite);

        Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];

        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(www);
        	WWWDetailExtension ctrl = new WWWDetailExtension(sc);

        	/** CREATE TEST ONTVANGEN **/
	        	PageReference tpageRef = ctrl.redirectDelToHub();
	        	Test.setCurrentPage(tpageRef);
	        	ctrl = new WWWDetailExtension(sc);
	        	System.assertEquals(true, ctrl.delToHub);

	        	ctrl.getTimes();

	        	ctrl.detail.Location__c = hublocationParent.Id;
	        	ctrl.detail.Number_Of_Items__c = 10;
	        	ctrl.detail.Damage_Package__c = 'No';

				System.currentPageReference().getParameters().put('Arrival_Truck_On_Hub__c','25.04.2017');
	        	System.currentPageReference().getParameters().put('Einddatum_opslag__c','29.04.2017');

	        	ctrl.getSubs();
	        	System.assertNotEquals(0, ctrl.sublocations1.size());

	        	for(SubLocation subLoc : ctrl.sublocations1) {
	        		subLoc.isChecked = true;
	        	}

	        	delete www;

	        	ctrl.saveDetail();
        	/** END CREATE TEST ONTVANGEN **/

        Test.stopTest();
    }
}