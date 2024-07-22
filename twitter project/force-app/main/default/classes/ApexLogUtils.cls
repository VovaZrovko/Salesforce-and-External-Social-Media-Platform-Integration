public without sharing class ApexLogUtils {
    @future
    public static void createLog(String message, String stackTrace, String userMessage, String className) {
        Log__c newLog = new Log__c();
        newLog.Message__c = message;
        newLog.StackTrace__c = stackTrace;
        newLog.User_Friendly_Message__c = userMessage;
        newLog.Class_Name__c = className;

        insert newLog;
    }

    public static void createLogs(Database.Error[] errors, String userMessage, String className) {
        List<Log__c> logList = new List<Log__c>();
        for (Database.Error error : errors) {
            Log__c newLog = new Log__c();
            newLog.Message__c = error.getMessage();
            newLog.StackTrace__c = error.getStatusCode() + ': ' + error.getFields();
            newLog.User_Friendly_Message__c = userMessage;
            newLog.Class_Name__c = className;
            logList.add(newLog);
        }

        insert logList;
    }
}