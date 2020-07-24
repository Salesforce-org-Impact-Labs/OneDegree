@IsTest
public class Test_ServiceProvider {

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

}