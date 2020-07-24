public class ServiceProviderFactory extends ServiceProviderAbstractFactory{

	public override ServiceProvider getServiceProvider (string svc_name) {
        if(svc_name == null) {
            return null;
        }
        if(svc_name.equalsIgnoreCase('OneDegree')) {
            return new OneDegreeServiceProvider();
        }
        return null;        
    }
    
    public override ServiceResults getServiceProviderResults(string query) {
        return null;
    }
}