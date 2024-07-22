@IsTest
private with sharing class TwitterAuthControllerTest {
    private static final String USERNAME = 'test username';
    private static final String DELIMITER = '~';
    private static final String TESTSTRING = 'Test';
    private static final String TWITTER_APP_CONFIG = 'Twitter App Config';

    @IsTest
    static void testGetTwitterUserSettingsPositive() {
        TwitterUserAuthSettings__c twitterUserSetting = new TwitterUserAuthSettings__c();
        twitterUserSetting.Username__c = USERNAME;
        twitterUserSetting.Expiration_Date__c = System.now();
        insert twitterUserSetting;

        Test.startTest();
        String result = TwitterAuthController.getTwitterUserSettings();
        Test.stopTest();
        
        Assert.isFalse(String.isEmpty(result), 'Should be true');
        Assert.areEqual(USERNAME, result.split(DELIMITER)[0], 'Should be equal values. The actual result: ' + result.split(DELIMITER)[0] + ' expected result: ' + USERNAME);
    }

    @IsTest
    static void testGetTwitterUserSettingsNegative() {
        String result = TwitterAuthController.getTwitterUserSettings();

        Assert.isTrue(String.isEmpty(result), 'Should be true');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should be not null');
    }

    @IsTest
    static void testGetTwitterAppConfigPositive() {
        TwitterAppConfig__c twitterAppConfig = new TwitterAppConfig__c();
        twitterAppConfig.Client_Key__c = TESTSTRING;
        twitterAppConfig.Callback_URL__c = TESTSTRING;
        twitterAppConfig.Name = TWITTER_APP_CONFIG;
        insert twitterAppConfig;

        Test.startTest();
        String result = TwitterAuthController.getTwitterAppConfig();
        Test.stopTest();

        Assert.areEqual(TESTSTRING, result.split(DELIMITER)[0], 'Should be equal values. The actual result: ' + result.split(DELIMITER)[0] + ' expected result: ' + TESTSTRING);
        Assert.areEqual(TESTSTRING, result.split(DELIMITER)[1], 'Should be equal values. The actual result: ' + result.split(DELIMITER)[1] + ' expected result: ' + TESTSTRING);
    }

    @IsTest
    static void testGetTwitterAppConfigNegative() {
        String result = TwitterAuthController.getTwitterAppConfig();

        Assert.isTrue(String.isEmpty(result), 'Should be true');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should be not null');
    }

    @IsTest
    static void testGetAccessToken() { // better was to mock TwitterAuthService
        TwitterAppConfig__c twitterAppCofig = new TwitterAppConfig__c();
        twitterAppCofig.Name = 'Twitter App Config';
        twitterAppCofig.Base_URL__c = 'base url';
        insert twitterAppCofig;
    
        Test.setMock(HttpCalloutMock.class, new CallOutSuccessMock());
        PageReference pageRef = Page.intermidiateIntegrationVFPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('code', TESTSTRING);

        Test.startTest();
        TwitterAuthController.getAccessToken();
        Test.stopTest();

        TwitterUserAuthSettings__c userAuthSetting = TwitterUserAuthSettings__c.getInstance();
        Assert.isNotNull(userAuthSetting.Access_Token__c, 'Should be not null');
    }
}