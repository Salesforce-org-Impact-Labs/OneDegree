@IsTest
public class Test_GeoCodingMockService implements HttpCalloutMock {

    string dataJSON = '{' + 
'"results":[{"address_components":[{"long_name":"94043","short_name":"94043","types":["postal_code"]},{"long_name":"Mountain View","short_name":"Mountain View","types":["locality","political"]},{"long_name":"Santa Clara County","short_name":"Santa Clara County","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]}],' +
        '"formatted_address":"Mountain View, CA 94043, USA",'+
        '"geometry":{"bounds":{"northeast":{"lat":37.45209210000001,"lng":-122.0359899},"southwest":{"lat":37.3857439,"lng":-122.10842}},"location":{"lat":37.4062237,"lng":-122.0781663},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":37.45209210000001,"lng":-122.0359899},"southwest":{"lat":37.3857439,"lng":-122.10842}}},"place_id":"ChIJoQmen1G3j4ARbhoe7nVBEoQ","types":["postal_code"]}],"status":"OK"' +        
        '}';
    
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(dataJSON);
        return res;
    }     
}