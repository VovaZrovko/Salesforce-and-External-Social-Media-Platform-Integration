@IsTest
private with sharing class TweetSelectorTest {
    private static final String TEST_TWITTER_NAME = 'test';
    
    @TestSetup
    static void setup() {
        Contact testContact = new Contact(LastName = 'testUser', Twitter_Handle__c = 'testHandle');
        insert testContact;

        Tweet__c testTweet = new Tweet__c(Name = TEST_TWITTER_NAME, Contact__c = testContact.Id);
        insert testTweet;
    }

    @IsTest
    static void testGetTweetsByContactIDPositive() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        List<Tweet__c> tweetList = TweetSelector.newInstance().getTweetsByContactID(testContact.Id);

        Assert.isNotNull(tweetList[0], 'Should not be null');
        Assert.areEqual(TEST_TWITTER_NAME, tweetList[0].Name, 'Should be equal values. The actual result: ' + tweetList[0].Name + ' expected result: ' + TEST_TWITTER_NAME);
    }

    @IsTest
    static void testGetTweetsByContactIDNegative() {
        Contact testContact = new Contact(LastName = 'testUser');
        insert testContact;

        Test.startTest();
            List<Tweet__c> tweetList = TweetSelector.newInstance().getTweetsByContactID(testContact.Id);

        Assert.isTrue(tweetList.isEmpty(), 'Should be empty');

    }

    @IsTest
    static void testGetTweetByIdPositive() {
        Tweet__c tweet = TweetSelector.newInstance().getTweetById(TEST_TWITTER_NAME);

        Assert.isNotNull(tweet, 'Should not be null');
        Assert.areEqual(TEST_TWITTER_NAME, tweet.Name, 'Should be equal values. The actual result: ' + tweet.Name + ' expected result: ' + TEST_TWITTER_NAME);
    }
    
    @IsTest
    static void testGetTweetByIdNegative() {
        Tweet__c testTweet = [SELECT Id FROM Tweet__c WHERE Name =: TEST_TWITTER_NAME LIMIT 1];
        delete testTweet;

        Test.startTest();
            Tweet__c tweet = TweetSelector.newInstance().getTweetById(TEST_TWITTER_NAME);

        Assert.isNull(tweet, 'Should be null');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should create a log record');
    }
}