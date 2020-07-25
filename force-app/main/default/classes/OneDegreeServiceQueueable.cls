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

        List<One_Degree_Zipcode_Search__mdt> serviceZipCodes = [SELECT Zipcode__c, lat__c, long__c
                                                            FROM One_Degree_Zipcode_Search__mdt
                                                            WHERE (lat__c != null AND long__c != null)];
        for(One_Degree_Zipcode_Search__mdt serviceZipCode : serviceZipCodes) {
            String query = authSet.get('Hostname__c') + '/opportunities?api_key='+ authSet.get('API_Key__c') +
                                '&query[lat]='+serviceZipCode.lat__c + '&query[long]='+serviceZipCode.long__c + '&query[distance]=10&per_page=100';
            querySet.add(query);
        }
        List<String> queryParams = new List<String>();
        for(String s : querySet) {
            System.debug(LoggingLevel.DEBUG, '---> query url ' + s);
            queryParams.add(s);
            // https://data.1degree.org/v1/opportunities?api_key=be9a3c70842d0138f4d20614a1d2fcd4&query[lat]=37.7822891&query[long]=-122.463708&query[distance]=10&per_page=100
            // https://data.1degree.org/v1/opportunities?api_key=be9a3c70842d0138f4d20614a1d2fcd4&query[lat]=37.7822891&query[long]=-122.463708&query[distance]=10&per_page=100
        }                
        if(!System.isFuture()) {
            ServiceProviderClient.processOneDegreeService(authSet, queryParams);
        }          

    }
}