import { LightningElement, api, wire } from 'lwc';
import getLatestScore from '@salesforce/apex/EnrollmentScoreController.getLatestScore';

export default class EnrollmentScoreCard extends LightningElement {
    @api recordId;
    score;

    @wire(getLatestScore, { contactId: '$recordId' })
    wiredScore({ data, error }) {
        if (data) {
            this.score = data;
        } else {
            this.score = null;
        }
    }

    get priorityLabel() {
        if (!this.score) return '';

        if (this.score.Score__c >= 75) return '🔴 Hot';
        if (this.score.Score__c >= 40) return '🟠 Warm';
        return '🔵 Cold';
    }

    get badgeClass() {
        if (!this.score) return '';

        if (this.score.Score__c >= 75) return 'badge hot';
        if (this.score.Score__c >= 40) return 'badge warm';
        return 'badge cold';
    }
}