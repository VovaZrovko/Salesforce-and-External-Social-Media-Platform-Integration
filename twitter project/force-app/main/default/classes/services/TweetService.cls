public with sharing class TweetService implements ITweetService {
    private final String DATA = 'data';
    private final String DELETED = 'deleted';
    public  final String ID = 'id';

    public static ITweetService newInstance() {
        return new TweetService();
    }

    public Boolean deleteTweet(String tweetId) {
        TwitterUserAuthSettings__c twitterUserASetting = TwitterUserAuthSettings__c.getInstance();
        String baseUrl = 'https://api.twitter.com/2/tweets/';
        String endpoint = baseUrl + tweetId;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + twitterUserASetting.Access_Token__c);
        req.setMethod('DELETE');
		Http http = new Http();
        
        try {
            //req.setTimeout(200000); //for error testing timeout exception
            HttpResponse res = http.send(req);
    
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> dataMap = (Map<String, Object>) responseMap.get(this.DATA);
                Boolean isDeleted = (Boolean) dataMap.get(this.DELETED);
                Boolean isRecordDeleted = this.deleteTweetRecord(tweetId);
                
                return isDeleted && isRecordDeleted;
            } else {
                ApexLogUtils.createLog('Non-valid response code received status code ' + res.getStatusCode(), '', 'Something happend with getting access token. Please ask administrator for help', TweetService.class.getName());
            }
        } catch (CalloutException e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Something happend with deleting Tweets. Please ask administrator for help', TweetService.class.getName());
        } catch (Exception e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Generic exception. Please ask administrator for help', TweetService.class.getName());
        }
        
        return false;
    }

    public String createTweet(String tweetText) {
        TwitterUserAuthSettings__c twitterUserASetting = TwitterUserAuthSettings__c.getInstance();
        String baseUrl = 'https://api.twitter.com/2/tweets';
        String requestBody = '{"text": "' + tweetText + '"}';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(baseUrl);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + twitterUserASetting.Access_Token__c);
        req.setMethod('POST');
        req.setBody(requestBody);
        
		Http http = new Http();
        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 201) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> dataMap = (Map<String, Object>) responseMap.get(this.DATA);
                String tweetId = (String) dataMap.get(this.ID);
    
                return tweetId;
            } else {
                ApexLogUtils.createLog('Non-valid response code received status code ' + res.getStatusCode(), '', 'Something happend with getting access token. Please ask administrator for help', TweetService.class.getName());
            }
        } catch (CalloutException e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Something happend with posting a tweet. Please ask administrator for help', TweetService.class.getName());
        } catch (Exception e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Something happend with posting a tweet. Please ask administrator for help', TweetService.class.getName());
        }

        return '';
    }

    public Boolean createTweetRecord(String tweetText, String tweetId, ID contactId) {
        Tweet__c newTweet = new Tweet__c();
        newTweet.Name = tweetId;
        newTweet.Contact__c = contactId;
        newTweet.Tweet_Date__c = System.now();
        newTweet.Tweet_Text__c = tweetText;

        Database.SaveResult sr = Database.Insert(newTweet, false);

        if (!sr.isSuccess()) {
            ApexLogUtils.createLogs(sr.getErrors(), 'Something happend with creating of Tweet object. Please ask administrator for help' , TweetService.class.getName());
            return false;
        }

        Boolean isContactUpdated = this.updateLastPostTweetDate(contactId, newTweet.Tweet_Date__c);
        return sr.isSuccess() && isContactUpdated;
    }

    public  Boolean isUserAndUsernameSame(Id contactId) {
        String contactUsername = ContactSelector.newInstance().getContactById(contactId).Twitter_Handle__c;
        TwitterUserAuthSettings__c twitterUserASetting = TwitterUserAuthSettings__c.getInstance();
        Boolean isUsernamesEqual = contactUsername == twitterUserASetting.Username__c;
        return isUsernamesEqual;
    }

    @TestVisible
    private Boolean deleteTweetRecord(String tweetId) {
        Tweet__c tweetToDelete = TweetSelector.newInstance().getTweetById(tweetId);
        Database.DeleteResult dr = Database.delete(tweetToDelete, false);

        if (!dr.isSuccess()) {
            ApexLogUtils.createLogs(dr.getErrors(), 'Something happend with creating of Tweet object. Please ask administrator for help' , TweetService.class.getName());
        }
        
        return dr.isSuccess();
    }
    
    @TestVisible
    private Boolean updateLastPostTweetDate(ID contactId, DateTime lastPostDate) {
        Contact con = new Contact(Id = contactId);
        con.Last_Tweet_Post_Date__c = lastPostDate;

        Database.SaveResult sr = Database.update(con, false);
        if (!sr.isSuccess()) {
            ApexLogUtils.createLogs(sr.getErrors(), 'Something happend with updating Contact. Please ask administrator for help' , TweetService.class.getName());
            return false;
        }

        return sr.isSuccess();
    }
}