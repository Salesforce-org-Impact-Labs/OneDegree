public class SecurityWrapperController {
    // isAccessible
    // isUpdateable
    // isCreatable
    // isDeletable
    public static Boolean objectAccessible(Map<String, String> objectName, Map<String, String> fields) {
        String ISACCESSIBLE_TYPE = 'isAccessible';
        String ISUPDATEABLE_TYPE = 'isUpdateable';
        String ISCREATABLE_TYPE = 'isCreatable';
        String ISDELETEABLE_TYPE = 'isDeletable';
		Boolean result = true;
        String sObjectName;
        String permissionType;
        String fieldPermissionType;
        Map<String, String> npFields = new Map<String, String>();
        
        // Get the object name and permission type
        for(String sName : objectName.keySet()) {
            sObjectName = getOrgNamespace() + sName;
        }
        for(String sPermission : objectName.values()) {
            permissionType = sPermission;
        }
		Set<String> objectFieldNames = new Set<String>();        
        Map<String, Schema.SObjectType> genericObjectType = Schema.getGlobalDescribe();
        Schema.SObjectType objType = genericObjectType.get(sObjectName);
        Schema.DescribeSObjectResult dsr = objType.getDescribe();
        
        System.debug(dsr.isAccessible());        
        
        if(permissionType.equals(ISACCESSIBLE_TYPE)) {
            if(!dsr.isAccessible()) {
                return false;
            }            
        }
        
        if(permissionType.equals(ISUPDATEABLE_TYPE)) {
            if(!dsr.isUpdateable()) {
                return false;
            }            
        }

        if(permissionType.equals(ISCREATABLE_TYPE)) {
            if(!dsr.isCreateable()) {
                return false;
            }            
        }

        if(permissionType.equals(ISDELETEABLE_TYPE)) {
            if(!dsr.isDeletable()) {
                return false;
            }            
        }        
        
        //copy the map with namespace
        for(String fieldname : fields.keyset()) {
            String perm = fields.get(fieldname);
			npFields.put(getOrgNamespace() + fieldname, perm);
        }
        for(String fieldPermission : fields.values()) {
			fieldPermissionType = fieldPermission;
            //one loop is fine to the permission type
            break;
        }

		Map<String, Schema.SObjectField> objectFieldsMap = dsr.fields.getMap();
		// * Processing each account field one by one
		for(String objectFieldKey : objectFieldsMap.keySet()) {
		    // * Getting the current sobject field
		    Schema.SObjectField objectField = objectFieldsMap.get(objectFieldKey);
    		// * Getting the current sobject field description (field metadata) from sobject field
    		Schema.DescribeFieldResult objectFieldResult = objectField.getDescribe();
            if(npFields.containsKey(objectFieldResult.getName())) {
                
                if(fieldPermissionType.equals(ISACCESSIBLE_TYPE)) {
                    System.debug(objectFieldResult.isAccessible());
                    if(!objectFieldResult.isAccessible()) {
                        return false;
                    }
                }
                
                if(fieldPermissionType.equals(ISUPDATEABLE_TYPE)) {
                    System.debug(objectFieldResult.isUpdateable());
                    if(!objectFieldResult.isUpdateable()) {
                        return false;
                    }
                }


                if(fieldPermissionType.equals(ISCREATABLE_TYPE)) {
                    System.debug(objectFieldResult.isCreateable());
                    if(!objectFieldResult.isCreateable()) {
                        return false;
                    }
                }                

            }
		}            
        
        return result;
    }

    private static String getOrgNamespace() {
		String ORG_NAMESPACE = '';
        try{
            List<Organization> np = [SELECT NamespacePrefix FROM Organization];
            for(Organization org_np : np) {
                System.debug('---> np ' + org_np.NamespacePrefix);
                if(org_np.NamespacePrefix.equals('svc_onedegree')) {
                    ORG_NAMESPACE = org_np.NamespacePrefix + '__';
                    break;
                }
            }
        }catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, '---> Error getting namespace ' + ex.getMessage());
        }        
        
        return ORG_NAMESPACE;
        
    }
}