public with sharing class TwitterAppConfigUtils {
    public static final String TWITTER_APP_CONFIG = 'Twitter App Config';

    public static TwitterAppConfig__c getInstance() {
        TwitterAppConfig__c twitterAppCofig = TwitterAppConfig__c.getInstance(TWITTER_APP_CONFIG);
        return twitterAppCofig;
    }

    public static String getCallBackUrl() {
        return getInstance().Callback_URL__c;
    }

    public static String getClientSecret() {
        return getInstance().Client_Secret__c;
    }

    public static String getClientKey() {
        return getInstance().Client_Key__c;
    }

    public static String getBaseUrl() {
        return getInstance().Base_URL__c;
    }

    public static String getBase64EncodedCredentials() {
        String credentials = getClientKey() + ':' + getClientSecret();
        String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));

        return encodedCredentials;
    }
}