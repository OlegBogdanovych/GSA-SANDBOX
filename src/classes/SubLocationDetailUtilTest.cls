@isTest
private class SubLocationDetailUtilTest {

    @testSetup static void setup() {
        TestDataGenerator.fillTriggerSwitcherValues();
    }

    @isTest static void test_method_one() {

        Account account = TestDataGenerator.createBouwticketAccount('testAccountSublocation');
        Contact contact = TestDataGenerator.createTestContact(account);

        Projecten__c project = TestDataGenerator.createTestProject(account, 'testestest');
        Projectmember__c member = TestDataGenerator.createTestProjectMember(project, contact);
        Hub_Building_Site__c buldingSite = TestDataGenerator.createTestHub('Test Hub Subloc', project);

        Item__c item = TestDataGenerator.createTestItem('TestItem', 1);
        Location__c hublocationParent = TestDataGenerator.createTestHublocationParent('1Q2W', buldingSite);
        List<Location__c> hublocationChilds = TestDataGenerator.createTestHublocationChildren(buldingSite, hublocationParent);

        WWW__c www = TestDataGenerator.createTestWww(project, item, buldingSite);

        TestDataGenerator.createTestWwwDetailOntvangen(www, hublocationParent, 10);

        Test.startTest();
            Projecten__c project2 = TestDataGenerator.createTestProject(account, 'testestest2');
            WWW__c www2 = TestDataGenerator.createTestWww(project2, item, buldingSite);

            WWW_detail__c det2 = new WWW_detail__c(WWW__c = www2.id);
            insert det2;

            List<SublocationDetail__c> subDets = [Select Id, Name, WWW_detail__c from SublocationDetail__c where WWW_detail__r.WWW__c = :www.Id];
            for ( SublocationDetail__c sd : subDets ) {
                sd.WWW_detail__c = det2.id;
            }

            update subDets;
        Test.stopTest();

        delete subDets;

    }
}