public class GeoCodingService {

    
    private static void geoCodingServiceController(Map<String, String> authParams, String[] queryParams) {
     
        ServiceProviderAbstractFactory spFactory = ServiceProviderFactoryCreator.getFactory('ServiceProvider');  
        ServiceProviderAbstractFactory spFactoryResults = ServiceProviderFactoryCreator.getFactory('ServiceProviderResults');          
        ServiceProvider spGeoCoding = spFactory.getServiceProvider('GeoCoding');        
        ServiceResults geoCodingResults = spFactoryResults.getServiceProviderResults('GeoCodingResults');
        
		for(String s : queryParams) {        
			System.debug(LoggingLevel.DEBUG, '---> query ' + s);
        }
    }
}