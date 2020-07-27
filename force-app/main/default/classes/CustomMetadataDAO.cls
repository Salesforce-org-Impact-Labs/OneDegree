//Description: This class is required if any org 
 //deletes the custom metadata, then code coverage and asserts 
 //will fail, which will result in future deployment problems
 //for the customer.

public class CustomMetadataDAO {
	@testVisible static private Map<String, List<SObject>> customMetadataRecordsMap = new Map<String, List<SObject>>();
    
    public List<SObject> getCustomMetadataRecords(string query) {
        if(! customMetadataRecordsMap.containsKey(query)) {
            customMetadataRecordsMap.put(query, Database.query(query));
        }
        return customMetadataRecordsMap.get(query);
    }
}