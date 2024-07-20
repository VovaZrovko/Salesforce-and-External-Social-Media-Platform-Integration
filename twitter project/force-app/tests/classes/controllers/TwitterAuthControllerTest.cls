@IsTest
private with sharing class TwitterAuthControllerTest {
    private static final String USERNAME = 'test username';
    private static final String DELIMITER = '~';

    @IsTest
    static void testGetTwitterUserSettingsPositive() {
        TwitterUserAuthSettings__c twitterUserSetting = new TwitterUserAuthSettings__c();
        twitterUserSetting.Username__c = USERNAME;
        twitterUserSetting.Expiration_Date__c = System.now();
        insert twitterUserSetting;

        Test.startTest();
        String result = TwitterAuthController.getTwitterUserSettings();
        
        Assert.isFalse(String.isEmpty(result), 'Should be true');
        Assert.areEqual(USERNAME, result.split(DELIMITER)[0], 'Should be equal values. The actual result: ' + result.split(DELIMITER)[0] + ' expected result: ' + USERNAME);
    }

    @IsTest
    static void testGetTwitterUserSettingsNegative() {
        String result = TwitterAuthController.getTwitterUserSettings();

        Assert.isTrue(String.isEmpty(result), 'Should be true');
    }
}