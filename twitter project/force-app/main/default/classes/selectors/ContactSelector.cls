public with sharing class ContactSelector implements IContactSelector {
    public static IContactSelector newInstance() {
        return new ContactSelector();
    }

    public Contact getContactById(Id contactId) {
        try{
            return [SELECT Twitter_Handle__c FROM Contact WHERE Id =: contactId];
        } catch (QueryException e) {
            ApexLogUtils.createLog(e.getMessage(), e.getStackTraceString(), 'Something happend with retriving a contact. Please ask administrator for help', ContactSelector.class.getName());
        }
        
        return null;
    }
}