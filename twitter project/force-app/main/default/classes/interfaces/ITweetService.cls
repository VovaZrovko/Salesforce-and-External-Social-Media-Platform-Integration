public interface ITweetService {
    Boolean deleteTweet(String tweetId);
    String createTweet(String tweetText);
    Boolean createTweetRecord(String tweetText, String tweetId, ID contactId);
    Boolean isUserAndUsernameSame(Id contactId);
}