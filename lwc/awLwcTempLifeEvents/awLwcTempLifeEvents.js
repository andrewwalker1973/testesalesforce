import { LightningElement, wire, track } from 'lwc';
import { deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import getPersonLifeEvents from "@salesforce/apex/AW_CTR_ClientCommunity.getPersonLifeEventList";
import savePersonLifeEvent from '@salesforce/apex/AW_CTR_ClientCommunity.savePersonLifeEvent';
import PERSONLIFEEVENT_ID_FIELD from '@salesforce/schema/PersonLifeEvent.Id';
import PERSONLIFEEVENT_TYPE_FIELD from '@salesforce/schema/PersonLifeEvent.EventType';
import PERSONLIFEEVENT_NAME_FIELD from '@salesforce/schema/PersonLifeEvent.Name';
import PERSONLIFEEVENT_DESCRIPTION_FIELD from '@salesforce/schema/PersonLifeEvent.EventDescription';
import PERSONLIFEEVENT_IMPACT_FIELD from '@salesforce/schema/PersonLifeEvent.AW_Impact__c';
import PERSONLIFEEVENT_IMPACTDES_FIELD from '@salesforce/schema/PersonLifeEvent.AW_ImpactOnOutcomeGoals__c';
import PERSONLIFEEVENT_PRIORITY_FIELD from '@salesforce/schema/PersonLifeEvent.AW_PriorityLevel__c';
import PERSONLIFEEVENT_DATE_FIELD from '@salesforce/schema/PersonLifeEvent.EventDate';

export default class AwLwcTempLifeEvents extends LightningElement {

    @track displayPersonEventDialog = false;
    @track personLifeEventList;
    @track personLifeEventListError;
    @track formMode; //new, edit
    @track insertedPersonLifeEventId;
    wiredPersonLifeEvents;
    
    //edit goal variables
    @track personLifeEventId;
    @track personLifeEventName;
    @track personLifeEventType;
    @track personLifeEventDescription;
    @track personLifeEventImpact;
    @track personLifeEventImpactDes;
    @track personLifeEventPriority;
    @track personLifeEventDate;

    @wire(getPersonLifeEvents) personLifeEvents(result) {
        this.wiredPersonLifeEvents = result;
        console.log('result: ' + JSON.stringify(result));
        if (result.data) {
            console.log('personLifeEventList: ' + JSON.stringify(result.data));
            this.personLifeEventList = result.data;
            this.personLifeEventListError = undefined;
        } else if (result.error) {
            this.personLifeEventListError = result.error;
            this.personLifeEventList = undefined;
        }
    }


    get personLifeEventPriorityOptions() {
        return [
            { label: "High", value: "High" },
            { label: "Medium", value: "Medium" },
            { label: "Low", value: "Low" }
        ];
    }

    get personLifeEventImpactOptions() {
        return [
            { label: "Positive", value: "Positive" },
            { label: "Negative", value: "Negative" }
        ];
    }

    openDialog() {
        this.displayPersonEventDialog = true;
    }

    closeDialog() {
        this.displayPersonEventDialog = false;
    }

    editLifeEvent(event) {
        this.formMode = 'edit';
        this.clearForm();
        this.openDialog();

        const personLifeEventId = event.target.attributes.getNamedItem("data-recordid").value;
        const personLifeEventData = this.personLifeEventList;

        let selectedGoal = personLifeEventData.find(obj => {
            return obj.Id === personLifeEventId;
        });

        this.personLifeEventId = selectedGoal[PERSONLIFEEVENT_ID_FIELD.fieldApiName];
        this.personLifeEventName = selectedGoal[PERSONLIFEEVENT_NAME_FIELD.fieldApiName];
        this.personLifeEventType = selectedGoal[PERSONLIFEEVENT_TYPE_FIELD.fieldApiName];
        this.personLifeEventDescription = selectedGoal[PERSONLIFEEVENT_DESCRIPTION_FIELD.fieldApiName];
        this.personLifeEventImpact = selectedGoal[PERSONLIFEEVENT_IMPACT_FIELD.fieldApiName];
        this.personLifeEventImpactDes = selectedGoal[PERSONLIFEEVENT_IMPACTDES_FIELD.fieldApiName];
        this.personLifeEventPriority = selectedGoal[PERSONLIFEEVENT_PRIORITY_FIELD.fieldApiName];
        this.personLifeEventDate = selectedGoal[PERSONLIFEEVENT_DATE_FIELD.fieldApiName];

    }

    newpersonLifeEvent() {
        this.clearForm();
        this.openDialog();
    }

    savePersonLifeEvent() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allValid) {
            const personLifeEvent = {};
            if (this.personLifeEventId !== null) {
                personLifeEvent['personLifeEventId'] = this.personLifeEventId;
            }
            personLifeEvent['personLifeEventName'] = this.template.querySelector("[data-field='life-event-name']").value;
            personLifeEvent['personLifeEventDescription'] = this.template.querySelector("[data-field='life-event-description']").value;
            personLifeEvent['personLifeEventImpact'] = this.template.querySelector("[data-field='life-event-impact']").value;
            personLifeEvent['personLifeEventImpactDes'] = this.template.querySelector("[data-field='life-event-impactdes']").value;
            personLifeEvent['personLifeEventPriority'] = this.template.querySelector("[data-field='life-event-priority']").value;
            personLifeEvent['personLifeEventDate'] = this.template.querySelector("[data-field='life-event-date']").value;
            personLifeEvent['personLifeEventPriorityVisible'] = true;

            //personLifeEvent['personLifeEventType'] = 'Retirement';

            console.log(JSON.stringify(personLifeEvent));

            savePersonLifeEvent({ request: JSON.stringify(personLifeEvent) })
                .then(result => {
                    this.insertedPersonLifeEventId = result;
                    this.template.querySelector('c-cmn-lwc-toast').successNotification();
                    this.closeDialog();
                    refreshApex(this.wiredPersonLifeEvents);
                })
                .catch(error => {
                    console.log('error' + JSON.stringify(error));
                    this.template.querySelector('c-cmn-lwc-toast').customNotification('Error updating record', error.body.message, 'error');
                });

            /*
            if (this.formMode === 'edit') {
                const recordInput = { fields };
        console.log('recordInput' + JSON.stringify(recordInput));
                updateRecord(recordInput)
                  .then(() => {
                    this.template.querySelector('c-cmn-lwc-toast').successNotification();
                    this.closeDialog();
                    // Display fresh data in the form
                    refreshApex(this.wiredPersonLifeEvents);
                  })
                  .catch(error => {
                    console.log('error' + JSON.stringify(error));
                    this.template.querySelector('c-cmn-lwc-toast').customNotification('Error updating record', error.body.message, 'error');
                  });
              }
              */

        }
        else {
            // The form is not valid
            this.template.querySelector('c-cmn-lwc-toast').customNotification('Something is wrong', 'Check your input and try again.', 'error');
        }
    }

    deleteLifeEvent(event) {
        console.log("here");
        const recordId = event.target.dataset.recordid;
        console.log('recordId: ' + recordId);
        deleteRecord(recordId)
            .then(() => {
                this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', 'Goal deleted successfully', 'success');
                return refreshApex(this.wiredGoals);
            })
            .catch(error => {
                this.template.querySelector('c-cmn-lwc-toast').customNotification('Error Deleting record', 'You can only delete goals you have created. ' + error.body.message, 'error');
            });
    }

    clearForm() {
        //to do: find all field dynamically and clear
        this.personLifeEventId = null;
        this.personLifeEventName = "";
        this.personLifeEventType = "";
        this.personLifeEventDescription = "";
        this.personLifeEventImpact = "";
        this.personLifeEventImpactDes = "";
        this.personLifeEventPriority = "";
        this.personLifeEventDate = "";
    }

}