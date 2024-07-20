@IsTest
private with sharing class ApexLogUtilsTest {
    private static final String CLASS_NAME = 'TestClassName';
    private static final String USER_MESSAGE = 'Test user message';
    @IsTest
    static void testCreateLog() {
        String stackTrace = 'Test stack trace';
        String message = 'Test message';

        ApexLogUtils.createLog(message, stackTrace, USER_MESSAGE, CLASS_NAME);

        Log__c log = getLog();
        Assert.areEqual(message, log.Message__c, 'Should be equal values. The actual result: ' + log.Message__c + ' expected result: ' + message);
        Assert.areEqual(stackTrace, log.StackTrace__c, 'Should be equal values. The actual result: ' + log.StackTrace__c + ' expected result: ' + stackTrace);
        Assert.areEqual(USER_MESSAGE, log.User_Friendly_Message__c, 'Should be equal values. The actual result: ' + log.User_Friendly_Message__c + ' expected result: ' + USER_MESSAGE);
        Assert.areEqual(CLASS_NAME, log.Class_Name__c, 'Should be equal values. The actual result: ' + log.Class_Name__c + ' expected result: ' + CLASS_NAME);
    }

    @IsTest
    static void testCreateLogsWithDatabaseErrors() {
        Contact testContact = new Contact();
        Database.SaveResult sr = Database.Insert(testContact, false);

        ApexLogUtils.createLogs(sr.getErrors(), USER_MESSAGE, CLASS_NAME);

        Log__c log = getLog();
        Assert.isNotNull(log.Message__c, 'Should not be null');
        Assert.areEqual(USER_MESSAGE, log.User_Friendly_Message__c, 'Should be equal values. The actual result: ' + log.User_Friendly_Message__c + ' expected result: ' + USER_MESSAGE);
        Assert.areEqual(CLASS_NAME, log.Class_Name__c, 'Should be equal values. The actual result: ' + log.Class_Name__c + ' expected result: ' + CLASS_NAME);
    }

    static Log__c getLog() {
        return [SELECT Message__c, StackTrace__c, User_Friendly_Message__c, Class_Name__c FROM Log__c LIMIT 1];
    }
}