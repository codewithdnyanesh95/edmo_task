public class EnrollmentScoreHandler {

    public static void updateContactPriority(List<Enrollment_Score__c> newScores) {

        Map<Id, Enrollment_Score__c> latestScorePerContact = new Map<Id, Enrollment_Score__c>();

        for (Enrollment_Score__c esc : newScores) {
            if (esc.Contact__c == null) continue;

            if (!latestScorePerContact.containsKey(esc.Contact__c) ||
                esc.Scored_At__c > latestScorePerContact.get(esc.Contact__c).Scored_At__c) {

                latestScorePerContact.put(esc.Contact__c, esc);
            }
        }

        List<Contact> contactsToUpdate = new List<Contact>();

        for (Id contactId : latestScorePerContact.keySet()) {
            Enrollment_Score__c esc = latestScorePerContact.get(contactId);

            String priority;
            if (esc.Score__c >= 75) {
                priority = 'Hot';
            } else if (esc.Score__c >= 40) {
                priority = 'Warm';
            } else {
                priority = 'Cold';
            }

            contactsToUpdate.add(new Contact(
                Id = contactId,
                Enrollment_Priority__c = priority
            ));
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}