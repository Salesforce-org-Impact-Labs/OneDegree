public class GeoCodingServiceProvider implements ServiceProvider {
    private final String SVC_NAME;
    public GeoCodingServiceProvider() {
        SVC_NAME = 'GeoCoding';
    }

    public String getServiceProviderName() {
        return SVC_NAME;
    }
}