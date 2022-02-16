@IsTest
public class Test_SecurityWrapperController {

    @testSetup static void setup() {
        // Create test accounts
        List<Account> testAccts = new List<Account>();
        
        Account testAcct1 = new Account();
        testAcct1.Name = 'Kaiser Hospital, French Campus ';
        testAcct1.External_ID__c = '4889-1502';
        testAccts.add(testAcct1);
        
        Account testAcct2 = new Account();
        testAcct2.Name = 'Test Account 2';
        testAcct2.External_ID__c = 'TEST-2';        
        testAccts.add(testAcct2);
        
        insert testAccts;        
    }
    
    @IsTest
    static void checkObjectAndFieldPermissionisAccessible() {
        Map<String, String> objectName = new Map<String, String>();
		Map<String, String> fields = new Map<String, String>();
        fields.put('Name', 'isAccessible');
        fields.put('External_ID__c', 'isAccessible');
        objectName.put('Account', 'isAccessible');
        Boolean result = SecurityWrapperController.objectAccessible(objectName, fields);
        if(result) {
        	List<Account> accts = [SELECT Name, External_ID__c FROM Account];            
        }
    }
    
   
    
    @IsTest
    static void checkObjectAndFieldPermissionisUpdateable() {
        Map<String, String> objectName = new Map<String, String>();
		Map<String, String> fields = new Map<String, String>();
        fields.put('Name', 'isUpdateable');
        fields.put('External_ID__c', 'isUpdateable');
        objectName.put('Account', 'isUpdateable');
        Boolean result = SecurityWrapperController.objectAccessible(objectName, fields);
        List<Account> accts = [SELECT Id, Name, External_ID__c FROM Account ORDER BY Name];            
        List<Account> updateAccounts = new List<Account>();
        
        if(result) {
        	Account acct1 = accts[0];
            acct1.External_ID__c = accts[0].External_ID__c + ' - Modified';
            updateAccounts.add(acct1);

        	Account acct2 = accts[1];
            acct2.External_ID__c = accts[1].External_ID__c + ' - Modified';
            updateAccounts.add(acct2);  
            
            update updateAccounts;
        }
        Test.startTest();
        List<Account> modifiedAccts = [SELECT Id, Name, External_ID__c FROM Account ORDER BY Name];
		System.assertEquals('4889-1502 - Modified', modifiedAccts[0].External_ID__c, 'Mismatch in external id values');        
        System.assertEquals('TEST-2 - Modified', modifiedAccts[1].External_ID__c, 'Mismatch in external id values');        
        Test.stopTest();
    }    
    
    @IsTest
    static void checkObjectAndFieldPermissionisCreatable() {
        Map<String, String> objectName = new Map<String, String>();
		Map<String, String> fields = new Map<String, String>();
        fields.put('Name', 'isCreatable');
        fields.put('External_ID__c', 'isCreatable');
        objectName.put('Account', 'isCreatable');
        Boolean result = SecurityWrapperController.objectAccessible(objectName, fields);  
        if(result) {
            List<Account> newAccts = new List<Account>();
            Account acct1 = new Account();
            acct1.Name = 'New Account 1';
            acct1.External_ID__c = 'Id - 1';
            acct1.Site = 'San Francisco';
            newAccts.add(acct1);
            
            Account acct2 = new Account();
            acct2.Name = 'New Account 2';
            acct2.External_ID__c = 'Id - 2';
            acct2.Site = 'San Francisco';            
            newAccts.add(acct2);
            
            insert newAccts; 
            
        }
		Test.startTest();
        List<Account> modifiedAccts = [SELECT Id, Name, External_ID__c, Site FROM Account WHERE Site = 'San Francisco' ORDER BY Name];
		System.assertEquals('Id - 1', modifiedAccts[0].External_ID__c, 'Mismatch in external id values');        
        System.assertEquals('Id - 2', modifiedAccts[1].External_ID__c, 'Mismatch in external id values');        
        Test.stopTest();
        
    }
    
    @IsTest
    static void checkObjectAndFieldPermissionisDeleteable() {
        Map<String, String> objectName = new Map<String, String>();
		Map<String, String> fields = new Map<String, String>();
        objectName.put('Account', 'isDeletable');

        Test.startTest();
        Boolean result = SecurityWrapperController.objectAccessible(objectName, fields);
        if(result) {
        	List<Account> accts = [SELECT Name, External_ID__c FROM Account];
			delete accts;                        
        }
        List<Account> deletedaccts = [SELECT Id FROM Account];
        System.assertEquals(0, deletedaccts.size(), 'There should not be any account records');
        Test.stopTest();
    }     
    
    
}