@isTest
private class ProjectItemsAfroepenControllerTest {

	@testSetup static void setup() {
		TestDataGenerator.fillTriggerSwitcherValues();

		Account account = TestDataGenerator.createBouwticketAccount('testAccount');
        Contact contact = TestDataGenerator.createTestContact(account);

        Projecten__c project = TestDataGenerator.createTestProject(account, 'testestest');
        Projectmember__c member = TestDataGenerator.createTestProjectMember(project, contact);
        Hub_Building_Site__c buldingSite = TestDataGenerator.createTestHub('Test Hub', project);

        Item__c item = TestDataGenerator.createTestItem('TestItem', 1);
        Item__c item2 = TestDataGenerator.createTestItem('TestItem2', 1);
        Location__c hublocationParent = TestDataGenerator.createTestHublocationParent('20C3', buldingSite);
        List<Location__c> hublocationChilds = TestDataGenerator.createTestHublocationChildren(buldingSite, hublocationParent);

        WWW__c www = TestDataGenerator.createTestWww(project, item, buldingSite);
        WWW__c www2 = TestDataGenerator.createTestWww(project, item2, buldingSite);
        TestDataGenerator.createTestWwwDetailOntvangen(www, hublocationParent, 50);
        //TestDataGenerator.createTestWwwDetailOntvangen(www2, hublocationParent, 50);
	}

	@isTest static void test_AfroepenItemsCycle() {
		Test.startTest();
			PageReference pageRef = Page.ProjectItemsAfroepen;
			Test.setCurrentPage(pageRef);

			ProjectItemsAfroepenController contr = new ProjectItemsAfroepenController();

			List<Projecten__c> prjcts = contr.projectsFound;
			Boolean showItems = contr.showItems;
			Boolean showItemsForAfroepen = contr.showItemsForAfroepen;

			contr.getTimes();

			contr.searchline = 'test';
			contr.searchProjects();
			System.assertNotEquals(0, contr.projectsFound.size(), 'Should be more than 0 projects');

			contr.projectId = contr.projectsFound[0].Id;
			contr.selectItems();
			System.assertNotEquals(0, contr.listOfItems.size(), 'Should be more than 0 possible items ready for afroepen');

			contr.listOfItems[0].isSelected = true;
			contr.afroepenItems();
			System.assertNotEquals(0, contr.listForAfroepen.size(), 'Should be more than 0 possible items selected for afroepen');

			contr.listForAfroepen[0].isSelected = true;
			contr.listForAfroepen[0].itemsToInvoke = 10;
			contr.deliveryDate = Date.today().addDays(3);

			PageReference pr = contr.finishAfroepenItems();
			System.assertEquals('', contr.fieldsValidationError, 'No errors should be, all data set correctly');
		Test.stopTest();
	}

	@isTest static void test_AfroepenItemsSorting() {
		Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];
		WWW__c www2 = [Select Id, Name from WWW__c where Item__r.Name = 'TestItem2' limit 1];

		Test.startTest();
			TestDataGenerator.createTestWwwDetailOntvangen(www2, hublocationParent, 50);
			PageReference pageRef = Page.ProjectItemsAfroepen;
			Test.setCurrentPage(pageRef);

			ProjectItemsAfroepenController contr = new ProjectItemsAfroepenController();

			List<Projecten__c> prjcts = contr.projectsFound;
			Boolean showItems = contr.showItems;
			Boolean showItemsForAfroepen = contr.showItemsForAfroepen;

			contr.getTimes();

			contr.searchline = 'test';
			contr.searchProjects();
			System.assertNotEquals(0, contr.projectsFound.size(), 'Should be more than 0 projects');

			contr.projectId = contr.projectsFound[0].Id;
			contr.selectItems();
			System.assertNotEquals(0, contr.listOfItems.size(), 'Should be more than 0 possible items ready for afroepen');
		//Test.startTest();

			PageReference srt = contr.sortByFiledItem();

			contr.sortDirection = 'DESCENDING';
			contr.sortField = 'Name';
			srt = contr.sortByFiledItem();

			Set<String> fields = new Set<String>{'Staat', 'Maten', 'Diameter', 'Merk', 'Material', 'Kleur', 'Type_verpakking', 'wat_nog_op_te_roepen_is', 'Loods/HUB'};

			for (String str : fields) {
				contr.sortDirection = 'ASCENDING';
				contr.sortField = str;
				srt = contr.sortByFiledItem();
				contr.sortDirection = 'DESCENDING';
				srt = contr.sortByFiledItem();
			}
		Test.stopTest();
	}

	@isTest static void test_AfroepenItemsFiltering() {
		Location__c hublocationParent = [Select Id, Name from Location__c where Name = '20C3' limit 1];
		WWW__c www2 = [Select Id, Name from WWW__c where Item__r.Name = 'TestItem2' limit 1];

		Test.startTest();
			TestDataGenerator.createTestWwwDetailOntvangen(www2, hublocationParent, 50);
			PageReference pageRef = Page.ProjectItemsAfroepen;
			Test.setCurrentPage(pageRef);

			ProjectItemsAfroepenController contr = new ProjectItemsAfroepenController();

			List<Projecten__c> prjcts = contr.projectsFound;
			Boolean showItems = contr.showItems;
			Boolean showItemsForAfroepen = contr.showItemsForAfroepen;

			contr.getTimes();

			contr.searchline = 'test';
			contr.searchProjects();
			System.assertNotEquals(0, contr.projectsFound.size(), 'Should be more than 0 projects');

			contr.projectId = contr.projectsFound[0].Id;
			contr.selectItems();
			System.assertNotEquals(0, contr.listOfItems.size(), 'Should be more than 0 possible items ready for afroepen');
		//Test.startTest();
			contr.getStaatPicklistValues();
			contr.getMaterialPicklistValues();
			contr.getKleurPicklistValues();
			contr.getKindOfPackagesPicklistValues();

			contr.addFiltersToItems();

			contr.seacrhByItemName = 'qwerty';
			contr.addFiltersToItems();
		Test.stopTest();
	}

	@isTest static void test_deliveryDateNotSet() {
		Test.startTest();
			PageReference pageRef = Page.ProjectItemsAfroepen;
			Test.setCurrentPage(pageRef);

			ProjectItemsAfroepenController contr = new ProjectItemsAfroepenController();

			contr.getTimes();

			contr.searchline = 'test';
			contr.searchProjects();
			System.assertNotEquals(0, contr.projectsFound.size(), 'Should be more than 0 projects');

			contr.projectId = contr.projectsFound[0].Id;
			contr.selectItems();
			System.assertNotEquals(0, contr.listOfItems.size(), 'Should be more than 0 possible items ready for afroepen');
		//Test.startTest();
			contr.listOfItems[0].isSelected = true;
			contr.afroepenItems();
			System.assertNotEquals(0, contr.listForAfroepen.size(), 'Should be more than 0 possible items selected for afroepen');

			contr.listForAfroepen[0].isSelected = true;
			contr.listForAfroepen[0].itemsToInvoke = 10;
			//contr.deliveryDate = Date.today().addDays(3);

			PageReference pr = contr.finishAfroepenItems();
			System.assertNotEquals('', contr.fieldsValidationError, 'Should be error that date not set');
		Test.stopTest();
	}

	@isTest static void test_numberOfItemsAfroepenBad() {
		Test.startTest();
			PageReference pageRef = Page.ProjectItemsAfroepen;
			Test.setCurrentPage(pageRef);

			ProjectItemsAfroepenController contr = new ProjectItemsAfroepenController();

			contr.getTimes();

			contr.searchline = 'test';
			contr.searchProjects();
			System.assertNotEquals(0, contr.projectsFound.size(), 'Should be more than 0 projects');

			contr.projectId = contr.projectsFound[0].Id;
			contr.selectItems();
			System.assertNotEquals(0, contr.listOfItems.size(), 'Should be more than 0 possible items ready for afroepen');

			contr.listOfItems[0].isSelected = true;
			contr.afroepenItems();
			System.assertNotEquals(0, contr.listForAfroepen.size(), 'Should be more than 0 possible items selected for afroepen');
		//Test.startTest();
			contr.listForAfroepen[0].isSelected = true;
			//contr.listForAfroepen[0].itemsToInvoke = 10;
			contr.deliveryDate = Date.today().addDays(3);

			PageReference pr = contr.finishAfroepenItems();
			System.assertNotEquals('', contr.fieldsValidationError, 'Should be error that number of items not set');

			contr.listForAfroepen[0].itemsToInvoke = 100;
			contr.deliveryDate = Date.today().addDays(3);

			pr = contr.finishAfroepenItems();
			System.assertNotEquals('', contr.fieldsValidationError, 'Error that number of items too big');
		Test.stopTest();
	}
}