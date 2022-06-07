public class CustomMetadataCallback implements Metadata.DeployCallback {
    public void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
                             
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('success: '+ result);
        } else {
            // Deployment was not successful
            System.debug('fail: '+ result);
        }
        sendJobCompletionEmail(String.valueOf(result));   
    }

    private void sendJobCompletionEmail(String result) {
        String subject = 'API Keys Status Message';
        String body = result;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setSubject(subject);
        email.setToAddresses( new String[] {UserInfo.getUserEmail()} );
        email.setPlainTextBody( body );
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}