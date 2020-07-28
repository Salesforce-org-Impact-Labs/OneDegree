@IsTest
public class Test_GeoCodingService {
    
    
    @IsTest
    static void testGeoCodingService() {
        
        Map<String, String> authSet = new Map<String, String>();
        List<String> queryParams = new List<String>();
		Set<String> querySet = new Set<String>();
		Test.startTest();        
        string queryAuth = 'SELECT MasterLabel, DeveloperName, API_Key__c , ' +
            					'Hostname__c ' +
            					'FROM One_Degree_Auth_Setting__mdt LIMIT 1';
        string jsonAuth = '[{"API_Key__c":"some_api_key","Hostname__c":"https://maps.googleapis.com/maps/api/geocode/json" }]';
		Test_CustomMetadataDAO.setMetadata(queryAuth, 
											(List<One_Degree_Auth_Setting__mdt>) JSON.deserialize(jsonAuth, List<One_Degree_Auth_Setting__mdt>.class)
                                          );        
        List<One_Degree_Auth_Setting__mdt> abSetting = new CustomMetaDataDAO().getCustomMetadataRecords(queryAuth);


        authSet.put('API_Key__c', abSetting[0].API_Key__c);
        authSet.put('Hostname__c', abSetting[0].Hostname__c);
        

        string queryZipcode = 'SELECT Id, MasterLabel, DeveloperName, Zipcode__c, Lat__c, Long__c from One_Degree_Zipcode_Search__mdt';
        string jsonZipcode = '[{"DeveloperName": "94043", "Zipcode__c":"94043", "Lat__c" : "37.4062237", "Long__c": "-122.0781663"}]';
        Test_CustomMetadataDAO.setMetadata(queryZipcode, 
                                           (List<One_Degree_Zipcode_Search__mdt>) JSON.deserialize(jsonZipcode, List<One_Degree_Zipcode_Search__mdt>.class)
                                          );                        
        
		List<One_Degree_Zipcode_Search__mdt> serviceZipCodes = new CustomMetaDataDAO().getCustomMetadataRecords(queryZipcode);        
        for(One_Degree_Zipcode_Search__mdt serviceZipCode : serviceZipCodes) {
            String query = authSet.get('Hostname__c') + '?address=' + serviceZipCode.Zipcode__c + '&key=' + authSet.get('API_Key__c');
            querySet.add(query);
        }
        for(String s : querySet) {
            System.debug(LoggingLevel.DEBUG, '---> query url ' + s);
            queryParams.add(s);
        }
        

		Test.setMock(HttpCalloutMock.class, new Test_GeoCodingMockService()); 
        GeoCodingService.processGeoCodingService(authSet, queryParams);
        Test.stopTest();

        System.assertEquals('94043', serviceZipCodes[0].Zipcode__c, 'Zipcode should be 94043');
        System.assertEquals('37.4062237', serviceZipCodes[0].lat__c, 'Latitude should be 37.4062237');        
		System.assertEquals('-122.0781663', serviceZipCodes[0].long__c, 'Longitude should be -122.0781663');                
    }

}