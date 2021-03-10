@IsTest
public class Test_CustomMetadataDAO {
    static testMethod void getTestMetadata() {
        List<SObject> customMetadataRecords;
        string query = 'SELECT Id, MasterLabel, DeveloperName, OD_Mapped_Values__c, SM_Field__c  ' +
							'FROM One_Degree__mdt ' +
							'LIMIT 1';
        Test.startTest();
        customMetadataRecords = new CustomMetadataDAO().getCustomMetadataRecords(query);
        Test.stopTest();
        System.assertEquals([SELECT Id, MasterLabel FROM One_Degree__mdt LIMIT 1].size(), 
                           customMetadataRecords.size(), 'Size should be equal');
    }    
    public static void setMetadata(string query, List<SObject> records) {
        CustomMetadataDAO.customMetadataRecordsMap.put(query, records);
    }    
}