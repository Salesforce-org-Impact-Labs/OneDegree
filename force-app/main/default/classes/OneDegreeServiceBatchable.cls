global with sharing class OneDegreeServiceBatchable implements 
            Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0; 
    public Integer totalBatchProcessed = 0; 
    public Map<Id, List<Datetime>> logJobTimes = new Map<Id, List<Datetime>>();
    Map<String, String> querySet = new Map<String, String>();
    Map<String, String> authSet = new Map<String, String>();

    global OneDegreeServiceBatchable() {
        One_Degree_Auth_Setting__mdt odSetting = [SELECT MasterLabel, DeveloperName, 
                                                    API_Key__c ,Hostname__c
                                                    FROM One_Degree_Auth_Setting__mdt LIMIT 1];
        authSet.put('API_Key__c', odSetting.API_Key__c);
        authSet.put('Hostname__c', odSetting.Hostname__c);        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String dateTimeFormat = DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        System.debug(LoggingLevel.DEBUG, 'Date Criteria : ' + dateTimeFormat);
        return Database.getQueryLocator(
            'SELECT Id, Name, Area__c, Program_Area__c, Job_StartDate__c, OD_Zipcode__c, ' +
            'OD_Zipcode__r.Id, OD_Zipcode__r.Results__c, OD_Zipcode__r.Zipcode__c, ' +
            'OD_Zipcode__r.Latitude__c, OD_Zipcode__r.Longitude__c, OD_Zipcode__r.Distance__c, ' +
            'Job_EndDate__c FROM OD_Search_Area__c WHERE (Job_StartDate__c <= ' + dateTimeFormat + 
            ' OR Job_StartDate__c = null) ' +
            'ORDER BY Job_StartDate__c ASC'
        );
    }
    
    global void execute(Database.BatchableContext bc, List<OD_Search_Area__c> scope){

        Integer totalCallouts = Limits.getLimitCallouts();
        List<Datetime> jobTimes = new List<Datetime>();
        for(OD_Search_Area__c area : scope) {
            Datetime startDateTime = Datetime.now(); // returns date time value in GMT time zone.
            //Integer offsetStart = UserInfo.getTimezone().getOffset(startDateTime);
            //Datetime startTime = startDateTime.addSeconds(offsetStart/1000);

            jobTimes.add(startDateTime);
            recordsProcessed++;
            System.debug(Logginglevel.DEBUG, '---> lat ' + area.OD_Zipcode__r.Latitude__c);
            System.debug(Logginglevel.DEBUG, '---> zipcode ' + area.OD_Zipcode__r.Zipcode__c);
            Map<string, SearchParams> searchParamsList = getQueryString(area.OD_Zipcode__r, area);
            System.debug(Logginglevel.DEBUG, searchParamsList);

            for(SearchParams val : searchParamsList.values()) {
                System.debug(LoggingLevel.DEBUG, '---> val ' + val.zipcode + ',' + val.area + ',' + 
                                            val.latitude + ',' + val.longitude);
                if(searchParamsList.size() > 0) {
                    for(SearchParams s : searchParamsList.values()) {
                            String query = authSet.get('Hostname__c') + 
                                            'opportunities?api_key='+ authSet.get('API_Key__c') +
                                            '&query[lat]='+s.latitude + 
                                            '&query[long]='+s.longitude + 
                                            '&query[text]='+s.area + 
                                            '&query[distance]=' + s.distance + 
                                            '&per_page=' + s.results;
                            querySet.put(query, s.program_area); 
                    } //end of for statement
                } //end of if statement
                Map<String, String> queryParams = new Map<String, String>();
                for(String s : querySet.keySet()) {
                    string program_area = querySet.get(s);
                    System.debug(LoggingLevel.DEBUG, '---> query url ' + s + ', program area ' + program_area);
                    queryParams.put(s, program_area);
                }
                System.debug(LoggingLevel.DEBUG, '---> processing One Degree service - start.');
                ServiceProviderClient.processOneDegreeService(authSet, queryParams);
                Datetime endDateTime = System.Datetime.now(); // returns date time value in GMT time zone.
                jobTimes.add(endDateTime);
                logJobTimes.put(area.Id, jobTimes);
                System.debug(LoggingLevel.DEBUG, '---> processing One Degree service - end.');                                            
            } // end of for statement
        }
        totalBatchProcessed++;
    }
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        System.debug(totalBatchProcessed + ' batch processed. Shazam!');
        List<OD_Search_Area__c> records = new List<OD_Search_Area__c>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        for(Id recordId : logJobTimes.keySet()) {
            List<Datetime> jobTimes = logJobTimes.get(recordId);
            System.debug(LoggingLevel.DEBUG, '---> Id ' + recordId);
            System.debug(LoggingLevel.DEBUG, '---> startTime ' + jobTimes[0]);
            System.debug(LoggingLevel.DEBUG, '---> endTime ' + jobTimes[1]);
            OD_Search_Area__c record = new OD_Search_Area__c();
            record.Id = recordId;
            record.Job_StartDate__c = jobTimes[0].addHours(2); //adding or subtracting to datetime is N/24
            record.Job_EndDate__c = jobTimes[1].addHours(2);
            records.add(record);
        }
        Database.SaveResult[] srList = Database.update(records, false);
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully update. ID: ' + sr.getId());
            }else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
        //check for records that need to be processed.
        //Database.executeBatch(new OneDegreeServiceBatchable(),1);
        // call some utility to send email
        //EmailUtils.sendMessage(job, recordsProcessed);
    } 
    
    private Map<string, SearchParams> getQueryString(OD_Zipcode__c zipcode, OD_Search_Area__c area) {
	    Set<String> querySet = new Set<String>();
		Set<Id> zipcodeIds = new Set<Id>();
        Map<string, SearchParams> zipcodeList = new Map<string, SearchParams>();
        Map<string, SearchParams> searchParamsList = new Map<string, SearchParams>();
        
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
        if(searchParamsList.size() > 0) {
            System.debug(LoggingLevel.DEBUG, '---> search params size ' + searchParamsList.size());
            return searchParamsList;
        }
        return null;
    }    
}