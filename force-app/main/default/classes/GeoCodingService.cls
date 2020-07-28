public class GeoCodingService {

    
    private static void geoCodingServiceController(Map<String, String> authParams, String[] queryParams) {
     
        ServiceProviderAbstractFactory spFactory = ServiceProviderFactoryCreator.getFactory('ServiceProvider');  
        ServiceProviderAbstractFactory spFactoryResults = ServiceProviderFactoryCreator.getFactory('ServiceProviderResults');          
        ServiceProvider spGeoCoding = spFactory.getServiceProvider('GeoCoding');        
        ServiceResults geoCodingResults = spFactoryResults.getServiceProviderResults('GeoCodingResults');
	    
        Map<String, One_Degree_Zipcode_Search__mdt> zipcodes = new Map<String, One_Degree_Zipcode_Search__mdt>();
        List<One_Degree_Zipcode_Search__mdt> zipCodesUpdated = new List<One_Degree_Zipcode_Search__mdt>();
        
		string queryserviceZipCodes = 'SELECT Id, MasterLabel, DeveloperName, Zipcode__c, lat__c, long__c ' +
											'FROM One_Degree_Zipcode_Search__mdt ' +
            								'ORDER BY Zipcode__c';
		List<One_Degree_Zipcode_Search__mdt> serviceZipCodes = new CustomMetadataDAO().getCustomMetadataRecords(queryserviceZipCodes);
		for(One_Degree_Zipcode_Search__mdt serviceZipCode : serviceZipCodes) { 
            System.debug(LoggingLevel.DEBUG, '---> zipcode ' + serviceZipCode);
            zipcodes.put(serviceZipCode.Zipcode__c, serviceZipCode);
        }
        
        for(String s : authParams.keySet()) {
            System.debug(LoggingLevel.DEBUG, '---> key ' + s + ', value ' + authParams.get(s));
        }        
		for(String s : queryParams) {        
            String method = 'GET';
            String api_key = authParams.get('API_Key__c');
            String url = s;
            String authString = null;
            String authHeader = null;
            String username = null;
            string pwd = null;
            geoCodingResults.setServiceParams(api_key, username, pwd, url, method, authString, authHeader);        
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
									One_Degree_Zipcode_Search__mdt zipcodeObject = zipcodes.get(addrComponent.long_name);
                                    zipcodeObject.lat__c = String.valueOf(loc.lat);
									zipcodeObject.long__c = String.valueOf(loc.lng);
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
        	String jobId2 = MetaDataUtility.upsertMetadata(zipCodesUpdated);                    
        }        
    }
    
    @future(callout=true)
    // cannot pass map params in future method
    public static void processGeoCodingService(Map<String, String> authParams, String[] queryParams) {
        geoCodingServiceController(authParams, queryParams);
    }    
}