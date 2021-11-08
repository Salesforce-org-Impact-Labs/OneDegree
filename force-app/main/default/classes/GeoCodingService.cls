public With Sharing class GeoCodingService {

    
    private static void geoCodingServiceController(Map<String, String> authParams, String[] queryParams) {
     
        ServiceProviderAbstractFactory spFactory = ServiceProviderFactoryCreator.getFactory('ServiceProvider');  
        ServiceProviderAbstractFactory spFactoryResults = ServiceProviderFactoryCreator.getFactory('ServiceProviderResults');          
        ServiceProvider spGeoCoding = spFactory.getServiceProvider('GeoCoding');        
        ServiceResults geoCodingResults = spFactoryResults.getServiceProviderResults('GeoCodingResults');
	    
        Map<String, OD_Zipcode__c> zipcodes = new Map<String, OD_Zipcode__c>();
        List<OD_Zipcode__c> zipCodesUpdated = new List<OD_Zipcode__c>();
        
        if (Schema.sObjectType.OD_Zipcode__c.isAccessible()) {
            List<OD_Zipcode__c> serviceZipCodes = [SELECT Id, Zipcode__c, Latitude__c , Longitude__c
            FROM OD_Zipcode__c
            ORDER BY Zipcode__c];
            for(OD_Zipcode__c serviceZipCode : serviceZipCodes) { 
                System.debug(LoggingLevel.DEBUG, '---> zipcode ' + serviceZipCode);
                zipcodes.put(serviceZipCode.Zipcode__c, serviceZipCode);
            }            
        }        

        
        for(String s : authParams.keySet()) {
            System.debug(LoggingLevel.DEBUG, '---> key ' + s + ', value ' + authParams.get(s));
        }        
		for(String s : queryParams) {        
            String method = 'GET';
            String apiKey = authParams.get('API_Key__c');
            String url = s;
            String authString = null;
            String authHeader = null;
            String username = null;
            string pwd = null;
            geoCodingResults.setServiceParams(apiKey, username, pwd, url, method, authString, authHeader);        
            string result = geoCodingResults.getResults('GeoCoding Service'); 
        	System.debug(LoggingLevel.DEBUG, '---> results ' + result);
            
            try{
				GeoCodingDataWrapper geoCodeObject = GeoCodingDataWrapper.parse(result);  
                List<GeoCodingDataWrapper.results> geoResults =  geoCodeObject.results;
                for(GeoCodingDataWrapper.results geoResult : geoResults) {
                    GeoCodingDataWrapper.Northeast loc = geoResult.geometry.location;
                    System.debug('geoResult.geometry location : ' + geoResult.geometry.location);
                    System.debug('geoResult.geometry lat : ' + loc.lat);
                    System.debug('geoResult.geometry long : ' + loc.lng);
                    List<GeoCodingDataWrapper.Address_components> addrComponents = geoResult.address_components;
                    for(GeoCodingDataWrapper.Address_components addrComponent : addrComponents) {
						List<String> types = addrComponent.types;
                        for(String type : types) {
                            System.debug(LoggingLevel.DEBUG, '---> type ' + type);
                            if(type.equals('postal_code')) {
                                System.debug(LoggingLevel.DEBUG, '---> postal code ' + addrComponent.long_name);
                                
                                if(zipcodes.containsKey(addrComponent.long_name)) {
									OD_Zipcode__c zipcodeObject = zipcodes.get(addrComponent.long_name);
                                    zipcodeObject.Id = zipcodeObject.Id;
                                    zipcodeObject.Latitude__c  = loc.lat;
									zipcodeObject.Longitude__c  = loc.lng;
                                    zipCodesUpdated.add(zipcodeObject);
                                }
                            }
                        }
                        
                    }
                }
            }catch(Exception ex) {
                System.debug(LoggingLevel.ERROR, '---> Exception ' + ex.getMessage() + ', Line # ' + ex.getLineNumber());
            }
        }
        
        //update metadata now
        if(!Test.isRunningTest()) {
        	// update metadata with latitude and longitude
            if(zipCodesUpdated.size() > 0) {
                if (Schema.sObjectType.OD_Zipcode__c.isUpdateable()) {
                    update zipCodesUpdated;
                }
                
            }
        }        
    }
    
    @future(callout=true)
    // cannot pass map params in future method
    public static void processGeoCodingService(Map<String, String> authParams, String[] queryParams) {
        geoCodingServiceController(authParams, queryParams);
    }    
}