@isTest
public with sharing class TweetServiceMock implements System.StubProvider{
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
            List<Object> listOfArgs) {
        if (stubbedMethodName == 'createTweetRecord' || stubbedMethodName == 'deleteTweet' || stubbedMethodName == 'isUserAndUsernameSame' ) {
            return true; 
        } else if (stubbedMethodName == 'createTweet') {
            return 'tweetId'; 
        }
        return null;
    }
}