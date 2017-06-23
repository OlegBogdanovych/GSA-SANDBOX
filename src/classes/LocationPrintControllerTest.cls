@isTest
private class LocationPrintControllerTest {

	@isTest static void test_method_one() {
		TestDataGenerator.fillTriggerSwitcherValues();

		Hub_Building_Site__c hub = TestDataGenerator.createTestHubBuildingSite('Test Building Site', null);
		Hub_Building_Site__c hub1 = TestDataGenerator.createTestHubBuildingSite('Test Building Site2', null);

		List<Location__c> locs = TestDataGenerator.createTestMassGateLocationWithHub('TestGate', 600, hub);

		locs = TestDataGenerator.createTestMassSiteLocationWithHub('Test Site Location', 600, hub);

		locs = TestDataGenerator.createTestMassVerticalTransportWithHub('Test Vertical Transport', 600, hub1);


		LocationsPrintController ctrl = new LocationsPrintController();
		LocationsPrintController.getHubs();
		LocationsPrintController.loadData();
		ctrl.init();

		System.assertEquals(999, LocationsPrintController.locations.size());

		LocationsPrintController.hubSelected = hub.id;
		LocationsPrintController.loadData();

		System.assertEquals(999, LocationsPrintController.locations.size());
	}
}