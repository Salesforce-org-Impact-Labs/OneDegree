@IsTest
public class Test_ServiceProvider {

    
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
        // Create test services
        List<refrec__Service__c> testServices = new List<refrec__Service__c>();
        
        refrec__Service__c testService1 = new refrec__Service__c();
        testService1.Name = 'Kaiser Hospital, French Campus ';
        testService1.refrec__External_ID__c = '4889-1502-2849';
        testService1.refrec__Account__c = testAccts[0].Id;
        testServices.add(testService1);
        
        refrec__Service__c testService2 = new refrec__Service__c();
        testService2.Name = 'Test Service 2';
        testService2.refrec__Account__c = testAccts[1].Id;
        testService2.refrec__External_ID__c = 'TEST-2-SVC-2';
        testServices.add(testService2);

        insert testServices;
        // Create open hours
        List<refrec__Open_Hours__c> testOpenHours = new List<refrec__Open_Hours__c>();
        
        refrec__Open_Hours__c openHours1 = new refrec__Open_Hours__c();
        openHours1.refrec__Day__c = 'Monday';
        openHours1.refrec__Service__c = testServices[0].Id;
        openHours1.refrec__Start_Time__c = Time.newInstance(Integer.valueOf('8'), Integer.valueOf('00'), 0, 0);
        openHours1.refrec__End_Time__c = Time.newInstance(Integer.valueOf('17'), Integer.valueOf('00'), 0, 0);
        testOpenHours.add(openHours1);
        
        refrec__Open_Hours__c openHours2 = new refrec__Open_Hours__c();
        openHours2.refrec__Day__c = 'Monday';
        openHours2.refrec__Service__c = testServices[1].Id;
        openHours2.refrec__Start_Time__c = Time.newInstance(Integer.valueOf('8'), Integer.valueOf('00'), 0, 0);
        openHours2.refrec__End_Time__c = Time.newInstance(Integer.valueOf('17'), Integer.valueOf('00'), 0, 0);        
        testOpenHours.add(openHours2);

        insert testOpenHours;
    }    
    
    @IsTest
    static void testAuthParams() {
        AuthParams ap = new AuthParams();
        ap.api_key = 'api_key';
        ap.password = 'user name';
        ap.username = 'password';        
    }
    
    @IsTest
    static void testOneDegreeServiceFactoryCallout() {
        ServiceProviderAbstractFactory spFactory = ServiceProviderFactoryCreator.getFactory('ServiceProvider');  
        ServiceProviderAbstractFactory spFactoryResults = ServiceProviderFactoryCreator.getFactory('ServiceProviderResults');    
        //Check you are getting null back
        ServiceProviderAbstractFactory spFactoryNull = ServiceProviderFactoryCreator.getFactory('');
        System.assertEquals(null, spFactoryNull);

        // check for OneDegree
        ServiceProvider spOneDegree = spFactory.getServiceProvider('OneDegree');
        System.assertEquals('OneDegree', spOneDegree.getServiceProviderName(), 'Service name should be One Degree');        
        
        ServiceProvider spGeoCoding = spFactory.getServiceProvider('GeoCoding');
        System.assertEquals('GeoCoding', spGeoCoding.getServiceProviderName(), 'Service name should be Geo Coding');                
        //service that do not exist
        ServiceProvider spfooService = spFactory.getServiceProvider('fooService');
        System.assertEquals(null, spFactory.getServiceProvider('fooService'), 'Service should not exist.');
        System.assertEquals(null, spFactory.getServiceProvider(null), 'Service should return null.');
        //Service provider factory getServiceProviderResults should; return null
        ServiceResults spNullFactoryResults = spFactory.getServiceProviderResults('some query');
        System.assertEquals(null, spNullFactoryResults, 'Service results should return null.');
        
        //checking service results factory
        String api_key = 'api_key';
        String username = '';
        String pwd = '';
        String url = 'https://api.serviceprovider.com/authenticate';
        String method = 'GET';
        String body = 'req body';
        String authHeader = 'token';
        //check for null, when passed null
        System.assertEquals(null, spFactoryResults.getServiceProviderResults(null), 'Service results should return null.');
        //if it does not match results name it will return null
        System.assertEquals(null, spFactoryResults.getServiceProviderResults('fooResults'), 'Service results should return null.');
        //service provider should return null
        System.assertEquals(null, spFactoryResults.getServiceProvider('AuntBertha'), 'Service provider should return null.');

        //one degree results
        ServiceResults onedegreeResults = spFactoryResults.getServiceProviderResults('OneDegreeResults');
        onedegreeResults.setServiceParams(api_key, username, pwd, url, method, body, authHeader);    
		Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.stopTest();
        // This causes a fake response to be sent
        String res = onedegreeResults.getResults('testing mock service');
        system.debug(LoggingLevel.DEBUG, '---> res' + res);        
    }
    
    @IsTest
    static void testOneDegreeDataCallOut() {
        
        
        Map<String, String> authSet = new Map<String, String>();
        List<String> queryParams = new List<String>();
        string queryAuth = 'SELECT MasterLabel, DeveloperName, API_Key__c , ' +
            					'Hostname__c ' +
            					'FROM One_Degree_Auth_Setting__mdt LIMIT 1';
        string jsonAuth = '[{"API_Key__c":"some_api_key","Hostname__c":"https://data.1degree.org/v1/" }]';
		Test_CustomMetadataDAO.setMetadata(queryAuth, 
											(List<One_Degree_Auth_Setting__mdt>) JSON.deserialize(jsonAuth, List<One_Degree_Auth_Setting__mdt>.class)
                                          );        
        List<One_Degree_Auth_Setting__mdt> abSetting = new CustomMetaDataDAO().getCustomMetadataRecords(queryAuth);


        authSet.put('API_Key__c', abSetting[0].API_Key__c);
        authSet.put('Hostname__c', abSetting[0].Hostname__c);
        authSet.put('MethodType', 'POST');        
        
		Set<String> querySet = new Set<String>();
        //get all attribute tags
        string queryAttributeTag = 'SELECT Id, MasterLabel, DeveloperName, Attribute_Tag__c, Last_Run_Datetime__c ' +
            						'FROM One_Degree_Attribute_Setting__mdt WHERE Active__c = true LIMIT 1' ;
        string jsonAttribute = '[{"Attribute_Tag__c":"health clinic", "Active__c":true}]';

        Test_CustomMetadataDAO.setMetadata(queryAttributeTag, 
                                           (List<One_Degree_Attribute_Setting__mdt>) JSON.deserialize(jsonAttribute, List<One_Degree_Attribute_Setting__mdt>.class)
                                          );
        One_Degree_Attribute_Setting__mdt[] attributeTags = new CustomMetaDataDAO().getCustomMetadataRecords(queryAttributeTag);
        
        // get all zipcodes
        string queryZipcode = 'SELECT Zipcode__c from One_Degree_Zipcode_Search__mdt';
        string jsonZipcode = '[{"Zipcode__c":"94105"}]';
        Test_CustomMetadataDAO.setMetadata(queryZipcode, 
                                           (List<One_Degree_Zipcode_Search__mdt>) JSON.deserialize(jsonZipcode, List<One_Degree_Zipcode_Search__mdt>.class)
                                          );        
        List<One_Degree_Zipcode_Search__mdt> serviceZipCodes = new CustomMetaDataDAO().getCustomMetadataRecords(queryZipcode);

        for(One_Degree_Zipcode_Search__mdt serviceZipCode : serviceZipCodes) {
            System.debug(LoggingLevel.DEBUG, '---> zip code ' + serviceZipCode.Zipcode__c);
            for (One_Degree_Attribute_Setting__mdt attributeTag : attributeTags) {
                System.debug(LoggingLevel.DEBUG, '---> attribute tag ' + attributeTag.Attribute_Tag__c);
                System.debug(LoggingLevel.DEBUG, '---> active flag ' + attributeTag.Active__c);
                String query = authSet.get('Hostname__c') + '/opportunities?api_key='+ authSet.get('API_Key__c') +
                                '&query[lat]='+serviceZipCode.lat__c + '&query[long]='+serviceZipCode.long__c + '&query[distance]=10&per_page=10';
                querySet.add(query);
            }
        }
        for(String s : querySet) {
            System.debug(LoggingLevel.DEBUG, '---> query url ' + s);
            queryParams.add(s);

        }         
        
        
        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new Test_OneDegreeMockService());
			ServiceProviderClient.processOneDegreeService(authSet, queryParams);        
        Test.stopTest();
        
        //provider/account asserts
		Integer counter = 0;
        Map<String, String> acctMap = new Map<String, String>();
		List<Account> accts = [SELECT Id, Name, External_Id__c FROM Account ORDER BY External_Id__c];
        System.debug(LoggingLevel.DEBUG, '---> Account size ' + accts.size());
        System.assertEquals(4, accts.size(), 'There should be 4 accounts');
        for(Account acct : accts) {
            acctMap.put(acct.External_ID__c, acct.name);
        }
        System.assertEquals(true, acctMap.containsKey(accts[0].External_Id__c), 'Account External Id ' + accts[0].External_Id__c + ' should exist.');
        //service provider asserts
        Map<String, String> servicesMap = new Map<String, String>();
		List<refrec__Service__c> services = [SELECT Id, Name, refrec__External_Id__c 
                                             FROM refrec__Service__c ORDER BY refrec__External_Id__c];
        System.debug(LoggingLevel.DEBUG, '---> services size ' + services.size());
		System.assertEquals(5, services.size(), 'There should be 5 service records');
        for(refrec__Service__c svc : services) {
            servicesMap.put(svc.refrec__External_Id__c, svc.name);
        }        
        System.assertEquals(true, servicesMap.containsKey(services[0].refrec__External_Id__c), 'Service External Id ' + services[0].refrec__External_Id__c + ' should exist.');
        counter = 0;
        //open hours asserts
        counter = 0;
		List<refrec__open_hours__c> openhours = [SELECT id, name, refrec__day__c, 
                                                     	refrec__service__c, refrec__service__r.name 
                                                     from refrec__open_hours__c ORDER BY refrec__service__r.name, refrec__day__c];
        System.debug(Logginglevel.DEBUG, '---> # of open hour records ' + openhours.size());
		System.assertEquals(8, openhours.size(), 'There should be 8 open hour records');        
    }

    
    @IsTest
    static void testMetadataUtility() {
        Test.startTest();        
        	string queryAttributeTag = 'SELECT Id, MasterLabel, DeveloperName, Attribute_Tag__c, Last_Run_Datetime__c, Active__c ' +
            						'FROM One_Degree_Attribute_Setting__mdt LIMIT 1 ' ;
        	string jsonAttribute = '[{"DeveloperName":"health clinic","Attribute_Tag__c":"health clinic", "Active__c":"true"}]';

        	Test_CustomMetadataDAO.setMetadata(queryAttributeTag, 
                                           (List<One_Degree_Attribute_Setting__mdt>) JSON.deserialize(jsonAttribute, List<One_Degree_Attribute_Setting__mdt>.class)
                                          );
        	One_Degree_Attribute_Setting__mdt[] attributeTags = new CustomMetaDataDAO().getCustomMetadataRecords(queryAttributeTag);        
			System.debug(LoggingLevel.DEBUG, '---> attributeTags ' + attributeTags[0]);
			attributeTags[0].Active__c = true;
        	attributeTags[0].Last_Run_Datetime__c = System.datetime.now();
        	String jobId = MetaDataUtility.upsertMetadata(attributeTags[0]);        
        Test.stopTest();
    }
    
    @IsTest
    static void testQueueable() {
        OneDegreeServiceQueueable odQueueable = new OneDegreeServiceQueueable();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_OneDegreeMockService());
        System.enqueueJob(odQueueable);
        Test.stopTest();
    }
    
    @IsTest
    static void testMetadataCallback() {
        // Instantiate the callback.
        Metadata.DeployCallback callback = new CustomMetadataCallback();        
        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.numberComponentErrors = 1;
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        // Invoke the callback's handleResult method.
        callback.handleResult(result, context);        
    }    
    
}