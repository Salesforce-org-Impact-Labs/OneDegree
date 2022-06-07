@IsTest
public class Test_UpsertAPIKeys {

    @IsTest
    static void testupsertAPIKeysOnSave() {    
        Test.startTest();
        String status = UpsertAPIKeys.upsertAPIKeysOnSave('googleAPIkey', 'oneDegreeAPIKey');
        Test.stopTest();
        System.assert(status.length() > 0, 'Job Id cannot be blank');

    }
}
