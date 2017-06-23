@isTest
public  class UserUtilTest {
    @isTest public static void test_method_one() {
        TestDataGenerator.fillTriggerSwitcherValues();

        Account accId = new Account(Name = 'Test1');
        insert accId;
        Account accId1 = new Account(Name = 'Test2');
        insert accId1;
        Profile profile = [select Id from Profile where Name='Bouwticket account'];
        User user = new User();
        user.Username = 'contact@ukr.net';
        user.Email = 'contact@ukr.net';
        user.FirstName = 'contact';
        user.CommunityNickname = 'test65454';
        user.LastName = 'contact';
        user.ProfileId = profile.Id;
        user.isActive = true;
        user.Alias = 'contact' ;
        user.EmailEncodingKey='UTF-8'; 
        user.languageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.isActive = true;
        user.AccountId__c = accId1.id;
        user.TimeZoneSidKey='Europe/Amsterdam';
        Test.startTest();
        insert user;
        
        Test.stopTest();
        List <AccountShare> sharingAccount = [SELECT  AccountId, Id, UserOrGroupId 
                                                FROM AccountShare where UserOrGroupId =: user.id];
        System.debug(sharingAccount);
        System.assertEquals(1, sharingAccount.size());
        ComponentData cc = new ComponentData();
    cc.runScript();
    }
    
    
}