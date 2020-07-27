global class OneDegreeServiceQueueable implements Queueable, Database.AllowsCallouts {

    Set<String> querySet = new Set<String>();
    Map<String, String> authSet = new Map<String, String>();

    global OneDegreeServiceQueueable() {
        One_Degree_Auth_Setting__mdt odSetting = [SELECT MasterLabel, DeveloperName, 
                                                    API_Key__c ,Hostname__c
                                                    FROM One_Degree_Auth_Setting__mdt LIMIT 1];
        authSet.put('API_Key__c', odSetting.API_Key__c);
        authSet.put('Hostname__c', odSetting.Hostname__c);        

    }

    global void execute(QueueableContext context) {

        //get all attribute tags
        string queryAttributeTags = 'SELECT Id, MasterLabel, DeveloperName, Attribute_Tag__c, Last_Run_Datetime__c ' +
            							'FROM One_Degree_Attribute_Setting__mdt WHERE Active__c = true ' +
            							'LIMIT 1';
		One_Degree_Attribute_Setting__mdt[] attributeTags = new CustomMetadataDAO().getCustomMetadataRecords(queryAttributeTags);	        
		// get service zipcodes from metadata 
		string queryserviceZipCodes = 'SELECT Zipcode__c, lat__c, long__c ' +
											'FROM One_Degree_Zipcode_Search__mdt ' +
											'WHERE lat__c != null ' +
            								'AND long__c != null';
		List<One_Degree_Zipcode_Search__mdt> serviceZipCodes = new CustomMetadataDAO().getCustomMetadataRecords(queryserviceZipCodes);        

        for(One_Degree_Zipcode_Search__mdt serviceZipCode : serviceZipCodes) {
            String query = authSet.get('Hostname__c') + '/opportunities?api_key='+ authSet.get('API_Key__c') +
                                '&query[lat]='+serviceZipCode.lat__c + '&query[long]='+serviceZipCode.long__c + '&query[distance]=10&per_page=100';
            querySet.add(query);
        }
        List<String> queryParams = new List<String>();
        for(String s : querySet) {
            System.debug(LoggingLevel.DEBUG, '---> query url ' + s);
            queryParams.add(s);
        }                
        if(!System.isFuture()) {
            System.debug(LoggingLevel.DEBUG, '---> processing One Degree service - start.');
            ServiceProviderClient.processOneDegreeService(authSet, queryParams);
            System.debug(LoggingLevel.DEBUG, '---> processing One Degree service - end.');            
        }
        if(!Test.isRunningTest()) {
        	// update metadata with last run date time stamp
        	attributeTags[0].Last_Run_Datetime__c = System.datetime.now();
        	String jobId2 = MetaDataUtility.upsertMetadata(attributeTags);                    
        }        

    }
}