public class ServiceProviderHelper {
    public ServiceProviderHelper() {

    }

    public static void insertSObjectRecords(List<SObject> sobjList) {
        System.debug(LoggingLevel.DEBUG, '---> Starting insert');

        try{
            Database.SaveResult[] results = Database.insert(sobjList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted record. ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
            System.debug(LoggingLevel.DEBUG, '---> Completed insert');
        }catch(exception ex) {
            System.debug(LoggingLevel.ERROR, '---> Error ' + ex.getMessage());
        }
    }

    public static void updateServiceProviderRecords(Map<Id, refrec__Service__c> updateServiceRecords) {
        List<refrec__Service__c> updatedSvcrecords = new List<refrec__Service__c>();
        //check for object and FLS permission
        Map<String, String> objectName = new Map<String, String>();
		Map<String, String> fields = new Map<String, String>();
        fields.put('Id', 'isUpdateable');
        objectName.put('refrec__Service__c', 'isUpdateable');
        Boolean securityResult = SecurityWrapperController.objectAccessible(objectName, fields); 
        if(!securityResult) {
			System.debug(LoggingLevel.ERROR, '---> Error in object and FLS in refrec__Service__c');
			return;            
        }
        
        for(Id svcId : updateServiceRecords.keySet()) {
            refrec__Service__c svc = updateServiceRecords.get(svcId);
            svc.Id = svcId;
            updatedSvcrecords.add(svc);
        }
        try{
            Database.SaveResult[] results = Database.update(updatedSvcrecords, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated record. ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
            System.debug(LoggingLevel.DEBUG, '---> Completed insert');
        }catch(exception ex) {
            System.debug(LoggingLevel.ERROR, '---> Error ' + ex.getMessage());
        }

    }

    public static void deleteOpenHourRecords(Map<Id, refrec__Service__c> serviceRecords) {
        Set<Id> serviceIds = new Set<Id>();
        for(Id svcId : serviceRecords.keySet()) {
            serviceIds.add(svcId);
        }
        List<refrec__Open_Hours__c> openHourRecords = [SELECT Id 
                                                       	FROM refrec__Open_Hours__c 
                                                       	WHERE refrec__Service__c IN :serviceIds];
        

        //check for object and FLS permission
        Map<String, String> objectName = new Map<String, String>();
        Map<String, String> fields = new Map<String, String>();
        objectName.put('refrec__Open_Hours__c', 'isDeletable');
        Boolean securityResult = SecurityWrapperController.objectAccessible(objectName, fields);        

        if(!securityResult) {
			System.debug(LoggingLevel.ERROR, '---> Error in object and FLS in refrec__Open_Hours__c');
            return;
        }
        
        if(openHourRecords.size() > 0) {
            delete openHourRecords;
        }
    }

    public static boolean dedupServiceRecordsFromService(String externalId, Map<String, String> serviceRecords) {
        System.debug(LoggingLevel.DEBUG, '---> external Id ' +  externalId);
        if(serviceRecords.size() > 0 && externalId.length() > 0 && serviceRecords.containsKey(externalId)){
            System.debug(LoggingLevel.DEBUG, '---> found ' +  serviceRecords.containsKey(externalId));
            return true;
        }else {
            return false;
        }
    }

    public static Map<Id, refrec__Service__c> dedupServiceRecords(List<refrec__Service__c> serviceRecord) {
        // dedup matching for service records - start
        Map<Id, refrec__Service__c> updateServiceRecords = new Map<Id, refrec__Service__c>();
        //get the ids of the service records.
        DataCloud.FindDuplicatesResult[] dups;
        dups = DataCloud.FindDuplicates.findDuplicates(serviceRecord);
        //List<Service__c> dedupedServiceRecords = new List<Service__c>();
        //dedupedServiceRecords.addAll(serviceRecords);
        for (Integer i = (serviceRecord.size()-1); i>=0 ; i--) {
            refrec__Service__c svc = null;
            for (Datacloud.DuplicateResult dr : dups[i].getDuplicateResults()) {    
                if (dr.matchResults.size() > 0 && dr.getMatchResults()[0].matchRecords.size() > 0) {
                    svc = (refrec__Service__c) dr.getMatchResults()[0].getMatchRecords()[0].getRecord();
                    System.debug(LoggingLevel.DEBUG, i + ') ---> matched record ' + svc.Id + ', ' + svc.name);
                    System.debug(LoggingLevel.DEBUG, ' removing ' + serviceRecord[i].name + ' from list.' );
                    updateServiceRecords.put(svc.Id, serviceRecord[i]);
                }
            }        
        }
        // dedup matching for service records - end
        return updateServiceRecords;
    }

    public static String getStringValues(List<String> values ) {
        string result = '';
        integer counter = 0;
        for(string s : values) {
            if(counter == 0) {
                result = s;
            }else {
            	result = result + ',' + s;                
            }

            counter++;
        }
        return result;
    }    
}