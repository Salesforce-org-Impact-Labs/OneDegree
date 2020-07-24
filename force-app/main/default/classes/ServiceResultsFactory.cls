public class ServiceResultsFactory extends ServiceProviderAbstractFactory {

	public override ServiceProvider getServiceProvider (string svc_name) {
        return null;
    }

    public override ServiceResults getServiceProviderResults(string query) {
        if(query == null) {
            return null;
        }
        if(query.equalsIgnoreCase('OneDegreeResults')) {
            return new OneDegreeServiceProviderResults();
        }
        return null;
    }    
}