@IsTest
private with sharing class TwitterAppConfigUtilsTest {
    private static final String TWITTER_APP_CONFIG = 'Twitter App Config';
    private static final String CALLBACK_URL = 'callback url';
    private static final String BASE_URL = 'base url';
    private static final String CLIENT_SECRET = 'client secret';
    private static final String CLIENT_KEY = 'client key';

    @TestSetup
    static void setup() {
        TwitterAppConfig__c twitterAppCofig = new TwitterAppConfig__c();
        twitterAppCofig.Name = TWITTER_APP_CONFIG;
        twitterAppCofig.Base_URL__c = BASE_URL;
        twitterAppCofig.Callback_URL__c = CALLBACK_URL;
        twitterAppCofig.Client_Secret__c = CLIENT_SECRET;
        twitterAppCofig.Client_Key__c = CLIENT_KEY;
        insert twitterAppCofig;
    }

    @IsTest
    static void testGetCallBackUrl() {
        String callbackUrl = TwitterAppConfigUtils.getCallBackUrl();

        Assert.areEqual(CALLBACK_URL, callbackUrl, 'Should be equal values. The actual result: ' + callbackUrl + ' expected result: ' + CALLBACK_URL);
    }

    @IsTest
    static void testGetClientSecret() {
        String clientSecret = TwitterAppConfigUtils.getClientSecret();

        Assert.areEqual(CLIENT_SECRET, clientSecret, 'Should be equal values. The actual result: ' + clientSecret + ' expected result: ' + CLIENT_SECRET);
    }


    @IsTest
    static void testGetClientKey() {
        String clientKey = TwitterAppConfigUtils.getClientKey();

        Assert.areEqual(CLIENT_KEY, clientKey, 'Should be equal values. The actual result: ' + clientKey + ' expected result: ' + CLIENT_KEY);
    }


    @IsTest
    static void testGetBaseUrl() {
        String baseUrl = TwitterAppConfigUtils.getBaseUrl();

        Assert.areEqual(BASE_URL, baseUrl, 'Should be equal values. The actual result: ' + baseUrl + ' expected result: ' + BASE_URL);
    }

    @IsTest
    static void testGetBase64EncodedCredentials() {
        String actualEncodedCreds = TwitterAppConfigUtils.getBase64EncodedCredentials();
        String creds = CLIENT_KEY + ':' + CLIENT_SECRET;
        String expectedEncodedCreds = EncodingUtil.base64Encode(Blob.valueOf(creds));

        Assert.areEqual(expectedEncodedCreds, actualEncodedCreds, 'Should be equal values. The actual result: ' + actualEncodedCreds + ' expected result: ' + expectedEncodedCreds);
    }

}