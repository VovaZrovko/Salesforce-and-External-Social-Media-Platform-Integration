public with sharing class TweetController {
    @TestVisible
    private static ITweetService tweetServiceInstance;
    @TestVisible
    private static ITweetSelector tweetSelectorInstance;

    @TestVisible
    private static ITweetService getTweetService() {
        if (tweetServiceInstance == null) {
            tweetServiceInstance = TweetService.newInstance();
        }
        return tweetServiceInstance;
    }

    @TestVisible
    private static ITweetSelector getTweetSelector() {
        if (tweetSelectorInstance == null) {
            tweetSelectorInstance = TweetSelector.newInstance();
        }
        return tweetSelectorInstance;
    }

    @AuraEnabled(cacheable=false)
    public static Boolean createTweetRecord(String tweetText, String tweetId, Id contactId) {
        return getTweetService().createTweetRecord(tweetText, tweetId, contactId);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Tweet__c> getTweetsByContactID(Id contactId) {
        return getTweetSelector().getTweetsByContactID(contactId);
    }

    @AuraEnabled(cacheable=false)
    public static Boolean deleteTweet(String tweetId) {
        return getTweetService().deleteTweet(tweetId);
    }

    @AuraEnabled(cacheable=false)
    public static Boolean isUserAndUsernameSame(Id contactId) {
        return getTweetService().isUserAndUsernameSame(contactId);
    }

    @AuraEnabled(cacheable=true)
    public static String createTweet(String tweetText) {
        return getTweetService().createTweet(tweetText);
    }
}