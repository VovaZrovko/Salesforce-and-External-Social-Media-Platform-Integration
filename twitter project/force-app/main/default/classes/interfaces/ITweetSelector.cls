public interface ITweetSelector {
    List<Tweet__c> getTweetsByContactID(Id contactId);
    Tweet__c getTweetById(String tweetId);
}