public class ServiceProviderClient {

    private static void oneDegreeServiceController(Map<String, String> authParams, Map<string, string> queryParams) {

        List<Account> acctRecords = new List<Account>();
        List<refrec__Service__c> serviceRecords = new List<refrec__Service__c>();
        List<refrec__Open_Hours__c> openhourRecords = new List<refrec__Open_Hours__c>();  
        //this will be used for update
        Map<Id, refrec__Service__c> updateServiceRecords = new Map<Id, refrec__Service__c>();        
        // this will verify existing service duplicate records in the call
        Map<String, String> dedupSvcRecords = new Map<String, String>();              

        ServiceProviderAbstractFactory spFactory = ServiceProviderFactoryCreator.getFactory('ServiceProvider');  
        ServiceProviderAbstractFactory spFactoryResults = ServiceProviderFactoryCreator.getFactory('ServiceProviderResults');          
        ServiceProvider spOneDegree = spFactory.getServiceProvider('OneDegree');        
        ServiceResults oneDegreeResults = spFactoryResults.getServiceProviderResults('OnedegreeResults');

        for(String s : authParams.keySet()) {
            System.debug(LoggingLevel.DEBUG, '---> key ' + s + ', value ' + authParams.get(s));
        }
        for(String s : queryParams.keySet()) {
            System.debug(LoggingLevel.DEBUG,  'value ' + s);
			string provider_type = queryParams.get(s);

            String method = 'GET';
            // string odQuery = EncodingUtil.urlEncode('health clinic', 'UTF-8');
            String api_key = authParams.get('API_Key__c');
            String url = s;
            String authString = null;
            String authHeader = null;
            String username = null;
            string pwd = null;
            oneDegreeResults.setServiceParams(api_key, username, pwd, url, method, authString, authHeader);        
            string odQueryResult = oneDegreeResults.getResults('testing od degree');
            //system.debug(LoggingLevel.DEBUG, '---> od query results : ' + odQueryResult); 
            
            try{
                String serviceExtId;
                String accountExtId;
                Integer counter = 0;
                OneDegreeDataWrapper odObject = OneDegreeDataWrapper.parse(odQueryResult);
                List<OneDegreeDataWrapper.Opportunities> opportunities = odObject.opportunities;
                System.debug(LoggingLevel.DEBUG, 'total # of opptys ' + opportunities.size());
                for(OneDegreeDataWrapper.Opportunities oppty : opportunities) {
                    //System.debug(LoggingLevel.DEBUG, '---> oppty id ' + oppty.id);
                    OneDegreeDataWrapper.Organization org = oppty.organization;
                    //System.debug(LoggingLevel.DEBUG, '---> org id ' + org.id);
                    // service locations
                    List<OneDegreeDataWrapper.Locations> locations = oppty.locations;
                    for(OneDegreeDataWrapper.Locations loc : locations) {
    
                        //get the phone $
                        List<OneDegreeDataWrapper.phones> phones = new List<OneDegreeDataWrapper.phones>();
                        if(oppty.phones.size() > 0 && oppty.phones != null) {
                            phones = oppty.phones;
                        }

                        //get the website URL
                        OneDegreeDataWrapper.Properties website = oppty.properties;
                        string location_url;
                        if(website.action_signup_url != null) {
                            location_url = website.action_signup_url;
                        }else{
                            location_url = '';
                        }
                        serviceExtId = String.valueOf(oppty.id + '-' + org.id+'-'+loc.id);
                        accountExtId = String.valueOf(oppty.id + '-' + org.id);
                        System.debug(LoggingLevel.DEBUG, counter++ + '.)' + serviceExtId);
                        
                        string service_tags = ServiceProviderHelper.getStringValues(oppty.tags);
                        string situation_tags = ServiceProviderHelper.getStringValues(oppty.categories);
                        


                        refrec__Service__c  serviceReference = new refrec__Service__c(refrec__External_ID__c = serviceExtId);
                        refrec__Service__c newService = new refrec__Service__c();
                        newService.Name = loc.Name;
                        newService.refrec__Street__c = loc.address;
                        newService.refrec__City__c = loc.city;
                        newService.refrec__Phone__c = phones.size() > 0 ? phones[0].digits : '';
                        newService.refrec__Zip_Code__c = loc.zip_code;
                        newService.refrec__External_ID__c = serviceExtId;
                        newService.refrec__Description__c = oppty.description;
                        newService.refrec__Type__c = provider_type;
                        newService.refrec__All_Types__c = provider_type;
                        newService.refrec__State__c = loc.state.length() > 2 ? '' : OneDegreeHelper.checkNull(loc.state);
                        newService.refrec__service_tags__c = service_tags;
                        newService.refrec__situation_tags__c = situation_tags;
                        newService.refrec__Location__latitude__s = loc.lat;
                        newService.refrec__Location__longitude__s = loc.long_z;
                        newService.refrec__Website__c = location_url;
                        //pass the areas, categories, tags
                        Set<String> ODFields = OneDegreeHelper.mapSMOneDegreeFields(serviceExtId, oppty.areas, oppty.categories, oppty.tags);
                        if(ODFields.size() > 0) {
                            for(String ODField : ODFields) {
                                System.debug(LoggingLevel.DEBUG, '---> serviceExtId, field ' + serviceExtId+','+ODField);
                                if(ODField.equals('Home Owner')) {
                                    newService.refrec__Home_Owner__c = true;
                                }else if(ODField.equals('Home Renter')) {
                                    newService.refrec__Home_Renter__c = true;
                                }else if(ODField.equals('Homeless')) {
                                    newService.refrec__Homeless__c = true;
                                }else if(ODField.equals('Near Homeless')) {
                                    newService.refrec__Near_Homeless__c = true;
                                }else if(ODField.equals('Runaway')) {
                                    newService.refrec__Runaway__c = true;
                                }  else if(ODField.equals('Employed full-time')) {
                                    newService.refrec__Employed_full_time__c = true;
                                }else if(ODField.equals('Retired')) {
                                    newService.refrec__Retired__c = true;
                                }else if(ODField.equals('Employed part-time')) {
                                    newService.refrec__Employed_part_time__c = true;
                                }else if(ODField.equals('Unemployed')) {
                                    newService.refrec__Unemployed__c = true;
                                }
                            }
                        }
                        List<Integer> minMaxAge = OneDegreeHelper.getMinMaxAge(serviceExtId, oppty.properties);
                        System.debug(LoggingLevel.DEBUG, '---> Age recvd - ' + minMaxAge);
                        if(minMaxAge.size() > 0) {
                            if(minMaxAge[0] > 0 && minMaxAge[1] > 0) {
                                //elig-age-or-over
                                newService.refrec__Minimum_Age__c = minMaxAge[0];
                                //elig-age-or-under
                                newService.refrec__Maximum_Age__c = minMaxAge[1];                                
                            }
                        }

                        //create account reference using account number
                        Account acctReference = new Account(External_ID__c = accountExtId);
                        newService.refrec__Account__r = acctReference;
                        List<refrec__Service__c> newServiceRecord = new List<refrec__Service__c>();
                        // dedup if the same service location record is part of the JSON payload
                        if( ! ServiceProviderHelper.dedupServiceRecordsFromService(serviceExtId, dedupSvcRecords)) {
                            newServiceRecord.add(newService);
                            dedupSvcRecords.put(serviceExtId, loc.name);                            
                        }else {
                            continue;
                        }

                        if(loc.schedule != null) {
                            OneDegreeDataWrapper.Schedule sched = loc.schedule;
                            openhourRecords.addAll( OneDegreeHelper.oneDegreeGetOpenHours(sched, serviceExtId));                        
                        }
                        Map<Id, refrec__Service__c> updServiceRecords = ServiceProviderHelper.dedupServiceRecords(newServiceRecord);
                        if(updServiceRecords.size() < 1){
                            serviceRecords.add(newService);
                        }else {
                            updateServiceRecords.putAll(updServiceRecords);
                        }                        

                    }// end of locations
                    //create the account record.
                    Account newAcct = new Account(name = org.name, 
                                            External_ID__c = accountExtId,
                                            description = oppty.description);
                    acctRecords.add(newAcct);
                }// end of oppty loop
    
    

            }catch(Exception ex) {
                System.debug(LoggingLevel.ERROR, '---> Exception ' + ex.getMessage() + ', line #' + ex.getLineNumber());
            }
        } //end of main query loop
        System.debug(LoggingLevel.DEBUG, '---> account records ' + acctRecords.size());
        System.debug(LoggingLevel.DEBUG, '---> service records ' + serviceRecords.size());
        System.debug(LoggingLevel.DEBUG, '---> open hours records ' + openhourRecords.size());
        // update strategy
        if(updateServiceRecords.size() > 0) {
            // delete all open hours child records and reinsert them
            ServiceProviderHelper.deleteOpenHourRecords(updateServiceRecords);
            // update service records
            ServiceProviderHelper.updateServiceProviderRecords(updateServiceRecords);
        }
        List<SObject> sobjList = new List<SObject>();
        sobjList.addAll(acctRecords);
        sobjList.addAll(serviceRecords);
        sobjList.addAll(openhourRecords);
        // insert service records
        ServiceProviderHelper.insertSObjectRecords(sobjList);        
    }

    @future(callout=true)
    public static void processOneDegreeService(Map<String, String> authParams, Map<string, string> queryParams) {
        oneDegreeServiceController(authParams, queryParams);
    }      
}