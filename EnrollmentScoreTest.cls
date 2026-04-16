@isTest
public class EnrollmentScoreTest {

    @isTest
    static void testRestAPI() {

        Contact c = new Contact(LastName='Test', Email='test@example.com');
        insert c;

        String body = JSON.serialize(new Map<String, Object>{
            'scores' => new List<Object>{
                new Map<String, Object>{
                    'contactEmail' => 'test@example.com',
                    'score' => 80,
                    'recommendedAction' => 'Schedule Call',
                    'sourceSystem' => 'EDMO',
                    'scoredAt' => System.now()
                },
                new Map<String, Object>{
                    'contactEmail' => 'missing@example.com',
                    'score' => 20,
                    'recommendedAction' => 'Send Info Pack',
                    'sourceSystem' => 'EDMO',
                    'scoredAt' => System.now()
                }
            }
        });

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;

        Test.startTest();
        EnrollmentScoreRestController.ResponseWrapper res =
            EnrollmentScoreRestController.createScores();
        Test.stopTest();

        System.assertEquals(2, res.results.size());
        System.assert(res.results[0].success);
        System.assert(!res.results[1].success);
    }

    @isTest
    static void testTriggerPriority() {

        Contact c = new Contact(LastName='Priority', Email='priority@test.com');
        insert c;

        List<Enrollment_Score__c> scores = new List<Enrollment_Score__c>{
            new Enrollment_Score__c(
                Contact__c = c.Id,
                Score__c = 30,
                Scored_At__c = System.now().addMinutes(-10)
            ),
            new Enrollment_Score__c(
                Contact__c = c.Id,
                Score__c = 90,
                Scored_At__c = System.now()
            )
        };

        insert scores;

        Contact updated = [SELECT Enrollment_Priority__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('Hot', updated.Enrollment_Priority__c);
    }

    @isTest
    static void testBulkAPI() {

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(LastName='Bulk'+i, Email='bulk'+i+'@test.com'));
        }
        insert contacts;

        List<Object> scoreList = new List<Object>();
        for (Contact c : contacts) {
            scoreList.add(new Map<String, Object>{
                'contactEmail' => c.Email,
                'score' => 50,
                'recommendedAction' => 'Assign Counselor',
                'sourceSystem' => 'EDMO',
                'scoredAt' => System.now()
            });
        }

        String body = JSON.serialize(new Map<String, Object>{
            'scores' => scoreList
        });

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;

        Test.startTest();
        EnrollmentScoreRestController.createScores();
        Test.stopTest();

        System.assertEquals(5, [SELECT COUNT() FROM Enrollment_Score__c]);
    }
}