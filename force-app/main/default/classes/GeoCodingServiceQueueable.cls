global class GeoCodingServiceQueueable implements Queueable, Database.AllowsCallouts {

    Set<String> querySet = new Set<String>();
    Map<String, String> authSet = new Map<String, String>();
    
    global GeoCodingServiceQueueable() {
        Geo_Coding_Auth_Setting__mdt geoSetting = [SELECT MasterLabel, DeveloperName, 
                                                    API_Key__c ,Hostname__c
                                                    FROM Geo_Coding_Auth_Setting__mdt LIMIT 1];
        authSet.put('API_Key__c', geoSetting.API_Key__c);
        authSet.put('Hostname__c', geoSetting.Hostname__c);                
    }
    
    global void execute(QueueableContext context) {
		string queryserviceZipCodes = 'SELECT Id, Zipcode__c, Latitude__c , Longitude__c  FROM OD_Zipcode__c';
		List<OD_Zipcode__c> serviceZipCodes = [SELECT Id, Zipcode__c, Latitude__c , Longitude__c  FROM OD_Zipcode__c];

        for(OD_Zipcode__c serviceZipCode : serviceZipCodes) {
            String query = authSet.get('Hostname__c') + '?address=' + serviceZipCode.Zipcode__c + '&key=' + authSet.get('API_Key__c');
            querySet.add(query);
        }
        List<String> queryParams = new List<String>();
        for(String s : querySet) {
            System.debug(LoggingLevel.DEBUG, '---> query url ' + s);
            queryParams.add(s);
        }                
        if(!System.isFuture()) {
            System.debug(LoggingLevel.DEBUG, '---> processing Geo Coding service - start.');
            GeoCodingService.processGeoCodingService(authSet, queryParams);
            System.debug(LoggingLevel.DEBUG, '---> processing Geo Coding service - end.');            
        }        
    }
}