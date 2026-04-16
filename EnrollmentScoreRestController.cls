@RestResource(urlMapping='/enrollment-scores/*')
global with sharing class EnrollmentScoreRestController {

    global class ScoreRequest {
        public String contactEmail;
        public Integer score;
        public String recommendedAction;
        public String sourceSystem;
        public Datetime scoredAt;
    }

    global class RequestWrapper {
        public List<ScoreRequest> scores;
    }

    global class Result {
        public String email;
        public Boolean success;
        public String message;
    }

    global class ResponseWrapper {
        public List<Result> results = new List<Result>();
    }

    @HttpPost
    global static ResponseWrapper createScores() {
        RestRequest req = RestContext.request;
        ResponseWrapper response = new ResponseWrapper();

        RequestWrapper wrapper = (RequestWrapper) JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);

        Set<String> emails = new Set<String>();
        for (ScoreRequest s : wrapper.scores) {
            if (s.contactEmail != null) {
                emails.add(s.contactEmail.toLowerCase());
            }
        }

        Map<String, Contact> contactMap = new Map<String, Contact>();
        for (Contact c : [SELECT Id, Email FROM Contact WHERE Email IN :emails]) {
            contactMap.put(c.Email.toLowerCase(), c);
        }

        List<Enrollment_Score__c> recordsToInsert = new List<Enrollment_Score__c>();

        for (ScoreRequest s : wrapper.scores) {
            Result r = new Result();
            r.email = s.contactEmail;

            if (!contactMap.containsKey(s.contactEmail?.toLowerCase())) {
                r.success = false;
                r.message = 'Contact not found';
            } else {
                Contact c = contactMap.get(s.contactEmail.toLowerCase());

                Enrollment_Score__c esc = new Enrollment_Score__c(
                    Contact__c = c.Id,
                    Score__c = s.score,
                    Recommended_Action__c = s.recommendedAction,
                    Source_System__c = s.sourceSystem,
                    Scored_At__c = s.scoredAt
                );

                recordsToInsert.add(esc);

                r.success = true;
                r.message = 'Queued for insert';
            }

            response.results.add(r);
        }

        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }

        return response;
    }
}