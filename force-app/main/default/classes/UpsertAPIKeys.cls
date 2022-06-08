public with sharing class UpsertAPIKeys {
    @AuraEnabled    
    public static String upsertAPIKeysOnSave(String googleAPIKey, String  oneDegreeAPIKey) {
        String result = 'Submitted';

        List<One_Degree_API_Key__mdt> apiKeysList = new List<One_Degree_API_Key__mdt>();        
        
        String query = 'SELECT Id, MasterLabel, NamespacePrefix,DeveloperName,Google_API_Key__c, OneDegree_API_Key__c FROM One_Degree_API_Key__mdt';
        CustomMetadataDAO odAPI = new CustomMetadataDAO();
        List<One_Degree_API_Key__mdt> apiKeys = odAPI.getCustomMetadataRecords(query);            
        
        One_Degree_API_Key__mdt data = new One_Degree_API_Key__mdt();
        try{
            System.debug(' Id ' + apiKeys[0].Id);
            data.Id = apiKeys[0].Id;
            data.Google_API_Key__c = googleAPIKey;
            data.OneDegree_API_Key__c = oneDegreeAPIKey;
            data.DeveloperName = apiKeys[0].DeveloperName;
            data.MasterLabel = apiKeys[0].MasterLabel;
            
            apiKeysList.add(data);
            result = MetaDataUtility.upsertMetadata(apiKeysList);            
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Error Message : ' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, 'Error Cause : ' + ex.getCause());
        }
        return result;
    }
}