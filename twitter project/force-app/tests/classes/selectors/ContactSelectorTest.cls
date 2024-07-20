@IsTest
private with sharing class ContactSelectorTest {
    private static final String TEST_TWITTER_HANDLE = 'test123';

    @TestSetup
    static void setup() {
        Contact testContact = new Contact(LastName = 'testUser', Twitter_Handle__c = TEST_TWITTER_HANDLE);
        insert testContact;
    }

    @IsTest
    static void testGetContactByIdPositive() {
        Contact retrivedContact = [SELECT Id FROM Contact LIMIT 1];

        Contact testContact = ContactSelector.newInstance().getContactById(retrivedContact.Id);

        Assert.isNotNull(testContact, 'Should not be null');
        Assert.areEqual(TEST_TWITTER_HANDLE, testContact.Twitter_Handle__c, 'Should be equal values. The actual result: ' + testContact.Twitter_Handle__c + ' expected result: ' + TEST_TWITTER_HANDLE);
    }

    @IsTest
    static void testGetContactByIdNegative() {
        Contact contactToDelete = [SELECT Id FROM Contact LIMIT 1];
        delete contactToDelete;

        Test.startTest();
        Contact testContact = ContactSelector.newInstance().getContactById(contactToDelete.Id);

        Assert.isNull(testContact, 'Should be null');
        Assert.isNotNull([SELECT Id FROM Log__c], 'Should create a log record');
    }
}