public with sharing class TwitterAuthController {
    @AuraEnabled(cacheable=false)
    public static void getAccessToken() {
        String authcode = ApexPages.currentPage().getParameters().get('code');

        if (String.isNotBlank(authcode)) {
            TwitterAuthService.newInstance().getAccessToken(authcode);
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getTwitterUserSettings() {
        try {
            TwitterUserAuthSettings__c twitterUserSetting = TwitterUserAuthSettings__c.getInstance();
            return twitterUserSetting.Username__c + '~' + twitterUserSetting.Expiration_Date__c.format('yyyy-MM-dd HH:mm:ss');
        } catch (NullPointerException e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Could not get your twitter authentication settings. Please authenticate to twitter on Auth Twitter tab', TwitterAuthController.class.getName());
            return '';
        }
    }
}