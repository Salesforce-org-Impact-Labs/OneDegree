global class OneDegreeServiceQueueable implements Queueable, Database.AllowsCallouts {

    Map<String, String> querySet = new Map<String, String>();
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

		Map<string, SearchParams> searchParamsList = getQueryString();
        if(searchParamsList.size() > 0) {
            for(SearchParams s : searchParamsList.values()) {
                String query = authSet.get('Hostname__c') + 'opportunities?api_key='+ authSet.get('API_Key__c') +
                                    '&query[lat]='+s.latitude + 
                    				'&query[long]='+s.longitude + 
                    				'&query[text]='+s.area + 
                    				'&query[distance]=' + s.distance + 
                    				'&per_page=' + s.results;
                querySet.put(query, s.program_area);                
            }            
        }
        Map<String, String> queryParams = new Map<String, String>();
        for(String s : querySet.keySet()) {
            string program_area = querySet.get(s);
            System.debug(LoggingLevel.DEBUG, '---> query url ' + s + ', program area ' + program_area);
            queryParams.put(s, program_area);
        }
        if(!System.isFuture()) {
            System.debug(LoggingLevel.DEBUG, '---> processing One Degree service - start.');
            ServiceProviderClient.processOneDegreeService(authSet, queryParams);
            System.debug(LoggingLevel.DEBUG, '---> processing One Degree service - end.');            
        }

    }
    
    private Map<string, SearchParams> getQueryString() {
	    Set<String> querySet = new Set<String>();
		Set<Id> zipcodeIds = new Set<Id>();
        Map<string, SearchParams> zipcodeList = new Map<string, SearchParams>();
        Map<string, SearchParams> searchParamsList = new Map<string, SearchParams>();
        
        List<OD_Zipcode__c> zipcodes = [SELECT Id, Zipcode__c, Latitude__c, Longitude__c, Distance__c, Results__c
                                         FROM OD_Zipcode__c];
        for(OD_Zipcode__c zipcode : zipcodes) {
            zipcodeIds.add(zipcode.Id);
			SearchParams zipcodeParams = new SearchParams();
            zipcodeParams.guid = zipcode.Id;
            zipcodeParams.zipcode = zipcode.Zipcode__c;
            zipcodeParams.latitude = zipcode.Latitude__c;
            zipcodeParams.longitude = zipcode.Longitude__c;
            zipcodeParams.distance = zipcode.Distance__c;
            zipcodeParams.results = zipcode.Results__c;
            zipcodeList.put(zipcode.Id, zipcodeParams);
           System.debug(zipcode.Zipcode__c);
        }
    	List<OD_Search_Area__c> areas = [SELECT OD_Zipcode__c, Area__c, Program_Area__c
                                     FROM OD_Search_Area__c 
                                     WHERE OD_Zipcode__c = :zipcodeIds];
        for(OD_Search_Area__c area : areas) {
            // search the previous search param set
            // get the zipcode values
            SearchParams s = zipcodeList.get(area.OD_Zipcode__c);
            if(s.guid != null) {
				SearchParams areaSearchParams = new SearchParams();
                areaSearchParams.guid = area.Id;
            	areaSearchParams.zipcode = s.zipcode;
            	areaSearchParams.latitude = s.latitude;
            	areaSearchParams.longitude = s.longitude;
            	areaSearchParams.distance = s.distance;
            	areaSearchParams.results = s.results;
                areaSearchParams.area = area.Area__c;
                areaSearchParams.program_area = area.Program_Area__c;
                searchParamsList.put(area.Id, areaSearchParams);
            }else {
                System.debug(LoggingLevel.DEBUG, '---> Error : No Zipcode');
            }
        }
        if(searchParamsList.size() > 0) {
            System.debug(LoggingLevel.DEBUG, '---> search params size ' + searchParamsList.size());
            return searchParamsList;
        }
        return null;
    }
}