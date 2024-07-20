@IsTest
private with sharing class TwitterAuthServiceTest {
    private static final String USERNAME = 'test username';
    private static final String ACCESS_TOKEN = 'accesstoken';
    @IsTest
    static void testSaveUserAuthSettingPositive() {
        TwitterAuthService tas = new TwitterAuthService();
        tas.saveUserAuthSetting('123', System.now(), USERNAME);

        TwitterUserAuthSettings__c userAuthSetting = TwitterUserAuthSettings__c.getInstance();
        Assert.areEqual(USERNAME, userAuthSetting.Username__c, 'Should be equal values. The actual result: ' + userAuthSetting.Username__c + ' expected result: ' + USERNAME);
    }

    @IsTest
    static void testGetUserInfoPositive() {
        Test.setMock(HttpCalloutMock.class, new CallOutSuccessMock());

        Test.startTest();
        TwitterAuthService tas = new TwitterAuthService();
        tas.getUserInfo(ACCESS_TOKEN, System.now());
        Test.stopTest();

        TwitterUserAuthSettings__c userAuthSetting = TwitterUserAuthSettings__c.getInstance();
        Assert.areEqual(USERNAME, userAuthSetting.Username__c, 'Should be equal values. The actual result: ' + userAuthSetting.Username__c + ' expected result: ' + USERNAME);
    }

    @IsTest
    static void testGetUserInfoNegativeFailureCode() {
        Test.setMock(HttpCalloutMock.class, new CallOutFailureMock());

        Test.startTest();
        TwitterAuthService tas = new TwitterAuthService();
        tas.getUserInfo(ACCESS_TOKEN, System.now());
        Test.stopTest();

        TwitterUserAuthSettings__c userAuthSetting = TwitterUserAuthSettings__c.getInstance();
        Assert.isNull(userAuthSetting.Username__c, 'Should be null');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should create a log record');
    }

    @IsTest
    static void testGetUserInfoNegativeCalloutException() {
        Test.setMock(HttpCalloutMock.class, new CallOutExceptionMock());

        Test.startTest();
        TwitterAuthService tas = new TwitterAuthService();
        tas.getUserInfo(ACCESS_TOKEN, System.now());
        Test.stopTest();

        TwitterUserAuthSettings__c userAuthSetting = TwitterUserAuthSettings__c.getInstance();
        Assert.isNull(userAuthSetting.Username__c, 'Should be null');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should create a log record');
    }

    @IsTest
    static void testGetAccessTokenPositive() {
        Test.setMock(HttpCalloutMock.class, new CallOutSuccessMock());

        Test.startTest();
        TwitterAuthService.newInstance().getAccessToken('authToken');
        Test.stopTest();

        TwitterUserAuthSettings__c userAuthSetting = TwitterUserAuthSettings__c.getInstance();
        Assert.areEqual(ACCESS_TOKEN, userAuthSetting.Access_Token__c, 'Should be equal values. The actual result: ' + userAuthSetting.Access_Token__c + ' expected result: ' + ACCESS_TOKEN);
    }

    @IsTest
    static void testGetAccessTokenNegativeCalloutException() {
        Test.setMock(HttpCalloutMock.class, new CallOutFailureMock());

        Test.startTest();
        TwitterAuthService.newInstance().getAccessToken('authToken');
        Test.stopTest();

        TwitterUserAuthSettings__c userAuthSetting = TwitterUserAuthSettings__c.getInstance();
        Assert.isNull(userAuthSetting.Access_Token__c, 'Should be null');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should create a log record');
    }

    @IsTest
    static void testGetAccessTokenNegativeFailureCode() {
        Test.setMock(HttpCalloutMock.class, new CallOutExceptionMock());

        Test.startTest();
        TwitterAuthService.newInstance().getAccessToken('authToken');
        Test.stopTest();

        TwitterUserAuthSettings__c userAuthSetting = TwitterUserAuthSettings__c.getInstance();
        Assert.isNull(userAuthSetting.Access_Token__c, 'Should be null');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should create a log record');
    }
}