public with sharing class TwitterAuthService implements ITwitterAuthService{
    private String baseUrl;
    private final String ACCESS_TOKEN = 'access_token';
    private final String EXPIRES_IN = 'expires_in';
    private final String USERNAME = 'username';
    private final String DATA = 'data';

    public static ITwitterAuthService newInstance() {
        return new TwitterAuthService();
    }
    public TwitterAuthService() {
        this.baseUrl = TwitterAppConfigUtils.getBaseUrl(); //for future need check on null
    }

    public void getAccessToken(String authcode) {
        String endpoint = this.baseUrl + '/2/oauth2/token';
        String callbackUrl = TwitterAppConfigUtils.getCallBackUrl();
        String clientId = TwitterAppConfigUtils.getClientKey();
        String authorizationCode = TwitterAppConfigUtils.getBase64EncodedCredentials();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Basic ' + authorizationCode);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=authorization_code&code=' + EncodingUtil.urlEncode(authcode, 'UTF-8') + '&client_id= ' + clientId + '&code_verifier=challenge&redirect_uri=' + callbackUrl);
        Http http = new Http();

        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String accessToken = (String) responseMap.get(this.ACCESS_TOKEN);
                Integer lifeTimeOfAccessToken = (Integer) responseMap.get(this.EXPIRES_IN);
                DateTime currentDatetime = Datetime.now();
                DateTime expirationDate = currentDatetime.addSeconds(lifeTimeOfAccessToken);

                this.getUserInfo(accessToken, expirationDate);
            } else {
                ApexLogUtils.createLog('Non-valid response code received status code ' + res.getStatusCode(), '', 'Something happend with getting access token. Please ask administrator for help', TwitterAuthService.class.getName());
            }
        } catch (CalloutException e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Something happend with getting access token. Please ask administrator for help', TwitterAuthService.class.getName());
        } catch (Exception e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Generic exception. Please ask administrator for help', TwitterAuthService.class.getName());
        }
    }
    
    public void getUserInfo(String accessToken, DateTime expirationDate) {
        String endpoint = this.baseUrl + '/2/users/me';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('GET');
        Http http = new Http();

        try {
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> dataMap = (Map<String, Object>) responseMap.get(this.DATA);
                String username = (String) dataMap.get(this.USERNAME);

                this.saveUserAuthSetting(accessToken, expirationDate, username);
            } else {
                ApexLogUtils.createLog('Non-valid response code received status code ' + res.getStatusCode(), '', 'Something happend with getting access token. Please ask administrator for help', TwitterAuthService.class.getName());
            }
        } catch (CalloutException e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Something happend with getting username. Please ask administrator for help', TwitterAuthService.class.getName());
        }
    }
    @TestVisible
    private void saveUserAuthSetting(String accessToken, DateTime lifeTimeOfAccessToken, String username) {
        TwitterUserAuthSettings__c userAuthSetting = TwitterUserAuthSettings__c.getInstance();
        userAuthSetting.Access_Token__c = accessToken; // need to look at Crypto class to make it more secure
        userAuthSetting.Expiration_Date__c = lifeTimeOfAccessToken;
        userAuthSetting.Username__c = username;
        
        Database.UpsertResult ur = Database.upsert(userAuthSetting, false);
        if (!ur.isSuccess()) { // I'm not sure it is needed here
            ApexLogUtils.createLogs(ur.getErrors(), 'Something happend with updating Auth data for user. Please ask administrator for help' , TwitterAuthService.class.getName());
        }
    }

}