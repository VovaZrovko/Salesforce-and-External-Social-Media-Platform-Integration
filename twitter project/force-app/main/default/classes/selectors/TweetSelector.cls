public with sharing class TweetSelector implements ITweetSelector {

    public static ITweetSelector newInstance() {
        return new TweetSelector();
    }

    public List<Tweet__c> getTweetsByContactID(Id contactId) {
        return [SELECT Name, Tweet_Text__c, Tweet_Date__c FROM Tweet__c WHERE Contact__c =: contactId ORDER BY Tweet_Date__c DESC LIMIT 50000];
    }

    public Tweet__c getTweetById(String tweetId) {
        try {
            return [SELECT Name FROM Tweet__c WHERE Name =: tweetId];
        } catch (QueryException e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Something happend with retriving Tweets. Please ask administrator for help', TweetSelector.class.getName());
        }
        
        return null;
    }
}