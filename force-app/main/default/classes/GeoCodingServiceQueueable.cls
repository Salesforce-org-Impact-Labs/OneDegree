global with sharing class GeoCodingServiceQueueable implements Queueable, Database.AllowsCallouts {

    Set<String> querySet = new Set<String>();
    Map<String, String> authSet = new Map<String, String>();
    String encryptedApiKey = '';
    
    global GeoCodingServiceQueueable() {
        One_Degree_API_Key__mdt geoSetting = [SELECT MasterLabel, DeveloperName, 
                                                    Google_API_Key__c, OneDegree_API_Key__c
                                                    FROM One_Degree_API_Key__mdt LIMIT 1];
        
        Geo_Coding_Auth_Setting__mdt geoSetting2 = [SELECT MasterLabel, DeveloperName, 
                                                    API_Key__c ,Hostname__c
                                                    FROM Geo_Coding_Auth_Setting__mdt LIMIT 1];        
        
        encryptedApiKey = OneDegreeHelper.oneDegreeEncrypt(geoSetting.Google_API_Key__c);
        authSet.put('API_Key__c', encryptedApiKey);
        authSet.put('Hostname__c', geoSetting2.Hostname__c);                
    }
    
    global void execute(QueueableContext context) {
		string queryserviceZipCodes = 'SELECT Id, Zipcode__c, Latitude__c , Longitude__c  FROM OD_Zipcode__c LIMIT 50000';
		List<OD_Zipcode__c> serviceZipCodes = [SELECT Id, Zipcode__c, Latitude__c , Longitude__c  FROM OD_Zipcode__c];

        for(OD_Zipcode__c serviceZipCode : serviceZipCodes) {
            String query = authSet.get('Hostname__c') + '?address=' + serviceZipCode.Zipcode__c + '&key=' + encryptedApiKey;
            querySet.add(query);
        }
        List<String> queryParams = new List<String>();
        for(String s : querySet) {
            //System.debug(LoggingLevel.DEBUG, '---> query url ' + s);
            queryParams.add(s);
        }                
        if(!System.isFuture()) {
            //System.debug(LoggingLevel.DEBUG, '---> processing Geo Coding service - start.');
            GeoCodingService.processGeoCodingService(authSet, queryParams);
            //System.debug(LoggingLevel.DEBUG, '---> processing Geo Coding service - end.');            
        }        
    }
}