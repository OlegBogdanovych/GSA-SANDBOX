@IsTest public with sharing class ProductUtilTest {
     @IsTest public static void uniqueProd() {
     	TestDataGenerator.fillTriggerSwitcherValues();
         Product2 pr = new Product2(Name = 'Test');
         insert pr;
         
     }
}