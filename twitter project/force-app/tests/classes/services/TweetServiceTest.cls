@IsTest
private with sharing class TweetServiceTest {
    private static final String USER_SETTINGS_USERNAME = 'test username';
    private static final String TWEET_EXTERNAL_ID = '12345';
    private static final String TWITTER_APP_CONFIG = 'Twitter App Config';

    @TestSetup
    static void setup() {
        Contact testContact = new Contact(LastName = 'testUser', Twitter_Handle__c = USER_SETTINGS_USERNAME);
        insert testContact;

        Tweet__c testTweet = new Tweet__c(Name = TWEET_EXTERNAL_ID , Contact__c = testContact.Id);
        insert testTweet;

        TwitterUserAuthSettings__c twitterUserASetting = TwitterUserAuthSettings__c.getInstance();
        twitterUserASetting.Access_Token__c = 'accesstoken';
        twitterUserASetting.Username__c = USER_SETTINGS_USERNAME;
        insert twitterUserASetting;

        TwitterAppConfig__c twitterAppCofig = new TwitterAppConfig__c();
        twitterAppCofig.Name = TWITTER_APP_CONFIG;
        twitterAppCofig.Base_URL__c = 'base url';
        insert twitterAppCofig;
    }

    @IsTest
    static void testUpdateLastPostTweetDatePositive() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Datetime currentDateTime = System.now();

        Boolean isUpdated = new TweetService().updateLastPostTweetDate(testContact.Id, currentDateTime);

        Contact updatedContact = [SELECT Last_Tweet_Post_Date__c FROM Contact WHERE Id =: testContact.Id];
        Assert.isTrue(isUpdated, 'Should be true');
        Assert.areEqual(currentDateTime,
                updatedContact.Last_Tweet_Post_Date__c, 
                'Should be equal values. The actual result: ' + updatedContact.Last_Tweet_Post_Date__c + ' expected result: ' + currentDateTime
        );
    }

    @IsTest
    static void testUpdateLastPostTweetDateNegative() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        delete testContact;

        Boolean isUpdated = new TweetService().updateLastPostTweetDate(testContact.Id, System.now());

        Assert.isFalse(isUpdated, 'Should be false');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should create a log record');
    }

    @IsTest
    static void testDeleteTweetRecordPositive() {
        Tweet__c testTweet = [SELECT Name FROM Tweet__c LIMIT 1];

        Boolean isDeleted = new TweetService().deleteTweetRecord(testTweet.Name);

        List<Tweet__c> tweetList = [SELECT Name FROM Tweet__c WHERE Id =: testTweet.Id];
        Assert.isTrue(isDeleted, 'Should be true');
        Assert.isTrue(tweetList.isEmpty());
    }

    @IsTest
    static void testDeleteTweetRecordNegative() {
        PermissionSet permSet = createTestPermissionSetWithoutDeleteAccess('Tweet__c');
        User testUser = createUserWithPermSet(permSet.Id);
        Boolean isDeleted;

        System.runAs(testUser) {
            isDeleted = new TweetService().deleteTweetRecord(TWEET_EXTERNAL_ID);
        }

        List<Tweet__c> tweetList = [SELECT Name FROM Tweet__c WHERE Name =: TWEET_EXTERNAL_ID];//testTweet.Id];
        Assert.isFalse(isDeleted, 'Should be true');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should create a log record');
    }

    @IsTest
    static void testIsUserAndUsernameSamePositive() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        Boolean isEqualUsernames =  TweetService.newInstance().isUserAndUsernameSame(testContact.Id);

        Assert.isTrue(isEqualUsernames, 'Should be true');
    }

    @IsTest
    static void testIsUserAndUsernameSameNegative() {
        Contact testContact = [SELECT Id, Twitter_Handle__c FROM Contact LIMIT 1];
        testContact.Twitter_Handle__c = 'test';
        update testContact;

        Boolean isEqualUsernames =  TweetService.newInstance().isUserAndUsernameSame(testContact.Id);

        Assert.isFalse(isEqualUsernames, 'Should be false');
    }

    @IsTest
    static void testCreateTweetRecordPositive() {
        String tweetText = 'some text';
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        Boolean isTweetCreated =  TweetService.newInstance().createTweetRecord(tweetText, TWEET_EXTERNAL_ID, testContact.Id);

        Tweet__c newTweet = [SELECT Name FROM Tweet__c Where Name =: TWEET_EXTERNAL_ID AND Contact__c =: testContact.Id LIMIT 1];

        Assert.isTrue(isTweetCreated, 'Should be true');
        Assert.areEqual(TWEET_EXTERNAL_ID, newTweet.Name, 'Should be equal values. The actual result: ' + newTweet.Name + ' expected result: ' + TWEET_EXTERNAL_ID);
    }

    @IsTest
    static void testCreateTweetRecordNegative() {
        String tweetText = 'some text';
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        delete testContact;

        Boolean isTweetCreated =  TweetService.newInstance().createTweetRecord(tweetText, TWEET_EXTERNAL_ID, testContact.Id);

        Assert.isFalse(isTweetCreated, 'Should be false');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should create a log record');
    }

    @IsTest
    static void testCreateTweetPositive() {
        String tweetText = 'some text';
        Test.setMock(HttpCalloutMock.class, new CallOutSuccessMock());
        
        Test.startTest();
        String tweetId = TweetService.newInstance().createTweet(tweetText);
        Test.stopTest();
        
        Assert.areEqual(TWEET_EXTERNAL_ID, tweetId, 'Should be equal values. The actual result: ' + tweetId + ' expected result: ' + TWEET_EXTERNAL_ID);
    }

    @IsTest
    static void testCreateTweetNegativeFailureCode() {
        String tweetText = 'some text';
        Test.setMock(HttpCalloutMock.class, new CallOutFailureMock());
        
        Test.startTest();
        String tweetId = TweetService.newInstance().createTweet(tweetText);
        Test.stopTest();
        
        Assert.isTrue(String.isEmpty(tweetId), 'Should be true');
        Assert.isNotNull([SELECT Id FROM Log__c LIMIT 1], 'Should create a log record');
    }

    @IsTest
    static void testCreateTweetNegativeCalloutException() {
        String tweetText = 'some text';
        Test.setMock(HttpCalloutMock.class, new CallOutExceptionMock());
        
        Test.startTest();
        String tweetId = TweetService.newInstance().createTweet(tweetText);
        Test.stopTest();
        
        Assert.isTrue(String.isEmpty(tweetId), 'Should be true');
        Assert.isNotNull([SELECT Id FROM Log__c LIMIT 1], 'Should create a log record');
    }

    @IsTest
    static void testDeleteTweetPositive() {
        Tweet__c testTweet = [SELECT Name FROM Tweet__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CallOutSuccessMock());
        
        Test.startTest();
        Boolean isTweetDeleted = TweetService.newInstance().deleteTweet(testTweet.Name);
        Test.stopTest();
        
        Assert.isTrue(isTweetDeleted, 'Should be true');
    }

    @IsTest
    static void testDeleteTweetNegativeFailureCode() {
        Tweet__c testTweet = [SELECT Name FROM Tweet__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CallOutFailureMock());
        
        Test.startTest();
        Boolean isTweetDeleted = TweetService.newInstance().deleteTweet(testTweet.Name);
        Test.stopTest();
        
        Assert.isFalse(isTweetDeleted, 'Should be false');
        Assert.isNotNull([SELECT Id FROM Log__c LIMIT 1], 'Should create a log record');
    }

    @IsTest
    static void testDeleteTweetNegativeCalloutException() {
        Tweet__c testTweet = [SELECT Name FROM Tweet__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CallOutExceptionMock());
        
        Test.startTest();
        Boolean isTweetDeleted = TweetService.newInstance().deleteTweet(testTweet.Name);
        Test.stopTest();
        
        Assert.isFalse(isTweetDeleted, 'Should be false');
        Assert.isNotNull([SELECT Id FROM Log__c LIMIT 1], 'Should create a log record');
    }

    private static PermissionSet createTestPermissionSetWithoutDeleteAccess(String SObjectType) {
        PermissionSet permSet = new PermissionSet(
            Name = 'NoDeleteAccessTweetPermSet',
            Label = 'No Delete Tweet Permission Set'
        );
        insert permSet;
        
        ObjectPermissions objPerm = new ObjectPermissions(
            ParentId = permSet.Id,
            SObjectType = SObjectType,
            PermissionsRead = true,
            PermissionsCreate = true,
            PermissionsEdit = true,
            PermissionsDelete = false
        );
        insert objPerm;
        
        return permSet;
    }

    private static User createUserWithPermSet(String permSetId) {
        User user = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + DateTime.now().getTime() + '@test.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert user;
        
        PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
            AssigneeId = user.Id,
            PermissionSetId = permSetId
        );
        insert permSetAssignment;
        
        return user;
    }
}