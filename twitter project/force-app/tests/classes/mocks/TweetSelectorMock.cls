@isTest
public with sharing class TweetSelectorMock implements System.StubProvider{
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
            List<Object> listOfArgs) {
        if (stubbedMethodName == 'getTweetsByContactID') {
            List<Tweet__c> tweetList = new List<Tweet__c>();
            tweetList.add(new Tweet__c(Name = 'tweetId'));
            return tweetList; 
        } 
        return null;
    }
}