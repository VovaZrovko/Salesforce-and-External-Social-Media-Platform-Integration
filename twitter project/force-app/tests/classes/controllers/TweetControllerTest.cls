@IsTest
private with sharing class TweetControllerTest {
    private final static String TWEET_ID = 'tweetId';

    @IsTest
    static void testCreateTweetRecord() {
        Contact testContact = new Contact(LastName = 'test');
        insert testContact;
        String tweetText = 'some text';
        TweetService serviceMock = (TweetService) Test.createStub(TweetService.class, new TweetServiceMock());
        TweetController.tweetServiceInstance = serviceMock;

        Test.startTest();
        Boolean isTweetRecordCreated = TweetController.createTweetRecord(tweetText, TWEET_ID, testContact.Id);
        Test.stopTest();

        Assert.isTrue(isTweetRecordCreated, 'Should be true');
    }

    @IsTest
    static void testDeleteTweet() {
        ITweetService serviceMock = (ITweetService) Test.createStub(ITweetService.class, new TweetServiceMock());
        TweetController.tweetServiceInstance = serviceMock;
        
        Test.startTest();
        Boolean isDeleted = TweetController.deleteTweet(TWEET_ID);
        Test.stopTest();

        Assert.isTrue(isDeleted, 'Should be true');
    }

    @IsTest
    static void testIsUserAndUsernameSame() {
        Contact testContact = new Contact(LastName = 'test');
        insert testContact;
        TweetService serviceMock = (TweetService) Test.createStub(TweetService.class, new TweetServiceMock());
        TweetController.tweetServiceInstance = serviceMock;

        Test.startTest();
        Boolean isEqual = TweetController.isUserAndUsernameSame(testContact.Id);
        Test.stopTest();

        Assert.isTrue(isEqual, 'Should be true');
    }

    @IsTest
    static void testCreateTweet() {
        ITweetService serviceMock = (ITweetService) Test.createStub(ITweetService.class, new TweetServiceMock());
        TweetController.tweetServiceInstance = serviceMock;

        Test.startTest();
        String tweetExternalId = TweetController.createTweet(TWEET_ID);
        Test.stopTest();

        Assert.areEqual(TWEET_ID, tweetExternalId, 'Should be equal values. The actual result: ' + tweetExternalId + ' expected result: ' + TWEET_ID);
    }

    @IsTest
    static void testGetTweetsByContactID() {
        Contact testContact = new Contact(LastName = 'test');
        insert testContact;
        ITweetSelector selectorMock = (ITweetSelector) Test.createStub(ITweetSelector.class, new TweetSelectorMock());
        TweetController.tweetSelectorInstance = selectorMock;

        Test.startTest();
        List<Tweet__c> tweetList = TweetController.getTweetsByContactID(testContact.Id);
        Test.stopTest();

        Assert.areEqual(TWEET_ID, tweetList[0].Name, 'Should be equal values. The actual result: ' + tweetList[0].Name + ' expected result: ' + TWEET_ID);
    }
}