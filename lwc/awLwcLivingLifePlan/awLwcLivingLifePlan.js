import { LightningElement, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import { refreshApex } from '@salesforce/apex';
import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import getPersonLifeEvents from "@salesforce/apex/AW_CTR_ClientCommunity.getPersonLifeEventList";
import getGoals from "@salesforce/apex/AW_CTR_ClientCommunity.getGoalList";
import deleteGoal from "@salesforce/apex/AW_CTR_ClientCommunity.deleteGoal";
import savePersonLifeEvent from '@salesforce/apex/AW_CTR_ClientCommunity.savePersonLifeEvent';
import PERSONLIFEEVENT_ID_FIELD from '@salesforce/schema/PersonLifeEvent.Id';
import PERSONLIFEEVENT_TYPE_FIELD from '@salesforce/schema/PersonLifeEvent.EventType';
import PERSONLIFEEVENT_NAME_FIELD from '@salesforce/schema/PersonLifeEvent.Name';
import PERSONLIFEEVENT_DESCRIPTION_FIELD from '@salesforce/schema/PersonLifeEvent.EventDescription';
import PERSONLIFEEVENT_IMPACT_FIELD from '@salesforce/schema/PersonLifeEvent.AW_Impact__c';
import PERSONLIFEEVENT_IMPACTDES_FIELD from '@salesforce/schema/PersonLifeEvent.AW_ImpactOnOutcomeGoals__c';
import PERSONLIFEEVENT_PRIORITY_FIELD from '@salesforce/schema/PersonLifeEvent.AW_PriorityLevel__c';
import PERSONLIFEEVENT_DATE_FIELD from '@salesforce/schema/PersonLifeEvent.EventDate';
import GOAL_OBJECT from '@salesforce/schema/FinServ__FinancialGoal__c';
import GOAL_ID_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.Id';
import GOAL_NAME_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.Name';
import GOAL_TYPE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__Type__c';
import GOAL_PRIORITY_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.AW_PriorityLevel__c';
import GOAL_DESCRIPTION_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__Description__c';
import GOAL_TARGETDATE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__TargetDate__c';
import GOAL_INITIALVALUE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__InitialValue__c';
import GOAL_ACTUALVALUE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__ActualValue__c';
import GOAL_TARGETVALUE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__TargetValue__c';
import GOAL_PRIMARYOWNER_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__PrimaryOwner__c';
import GOAL_PRODUCTTYPE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.AW_ProductType__c';

export default class AwLwcLivingLifePlan extends LightningElement {

    @track goalList;
    @track goalListError;
    @track personLifeEventList;
    @track personLifeEventListError;
    @track livingLifePlanList = [];
    @track displayPersonEventDialog = false;
    @track displayGoalDialog = false;
    @track displayGoalDialog = false;
    @track displayGoalRecordTypeDialog = false;
    @track insertedPersonLifeEventId;
    @track insertedGoalId;
    @track goalRecordType;
    @track isInvestmentGoal;
    @track isProtectionGoal;
    @track formMode; //new, edit
    @track hideUpload = true;
    @track chartData;
    wiredGoals;
    wiredPersonLifeEvents;
    wiredObjectImage;

    //edit goal variables
    @track personLifeEventId;
    @track personLifeEventName;
    @track personLifeEventType;
    @track personLifeEventDescription;
    @track personLifeEventImpact;
    @track personLifeEventImpactDes;
    @track personLifeEventPriority;
    @track personLifeEventDate;

    //edit goal variables
    @track goalId;
    @track goalName;
    @track goalDescription;
    @track goalPriority;
    @track goalProductType;
    @track goalType;
    @track goalTargetDate;
    @track goalInitialValue;
    @track goalActualValue;
    @track goalTargetValue;

    @wire(getGoals) goals(result) {
        this.wiredGoals = result;
        if (result.data) {
            this.goalList = result.data;
            this.goalList = this.goalList.map(item => Object.assign({}, item, { 'isGoal': true }));
            this.buildLivingLifePlanList();
            this.goalListError = undefined;
        } else if (result.error) {
            this.goalListError = result.error;
            this.goalList = undefined;
        }
    }

    @wire(getPersonLifeEvents) personLifeEvents(result) {
        this.wiredPersonLifeEvents = result;
        if (result.data) {
            this.personLifeEventList = result.data;
            this.personLifeEventList = this.personLifeEventList.map(item => Object.assign({}, item, { 'isPersonLifeEvent': true }));
            this.buildLivingLifePlanList();
            this.personLifeEventListError = undefined;
        } else if (result.error) {
            this.personLifeEventListError = result.error;
            this.personLifeEventList = undefined;
        }
    }

    @wire(getRecord, { recordId: userId, fields: ['User.AccountId'] })
    user;

    get userAccountId() {
        return this.user.data.fields.AccountId.value;
    }

    buildLivingLifePlanList() {
        this.livingLifePlanList = [];
        this.livingLifePlanList = this.personLifeEventList.concat(this.goalList);
        console.log("livingLifePlanList" + JSON.stringify(this.livingLifePlanList, null, 2));
        //Sort list of goals and events 
        this.livingLifePlanList.sort(function (a, b) {
            return parseFloat(b.AW_SortingDate__c) - parseFloat(a.AW_SortingDate__c)
        });

        console.log("livingLifePlanList sorted" + JSON.stringify(this.livingLifePlanList, null, 2));
    }

    refreshGoalImage(){
        this.template.querySelector('c-aw-lwc-display-image').refreshImage(); 
    }

    get goalPriorityOptions() {
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

    get goalTypeInvestmentPicklistValues() {
        return [
            { label: "Retirement", value: "Retirement" },
            { label: "Saving for a rainy day", value: "Saving for a rainy day" },
            { label: "Lifestyle goals", value: "Lifestyle goals" },
            { label: "Self-Improvement goals", value: "Self-Improvement goals" }
        ];
    }

    get goalTypeProtectionPicklistValues() {
        return [
            { label: "Protect Me", value: "Protect Me" },
            { label: "Protect My Family", value: "Protect My Family" },
            { label: "Protect My Assets", value: "Protect My Assets" }
        ];
    }

    get goalProductTypeOptions() {
        return [
            { label: "Investment", value: "Investment" },
            { label: "Protection", value: "Protection" }
        ];
    }

    openPersonLifeEventDialog() {
        this.displayPersonEventDialog = true;
    }

    closePersonLifeEventDialog() {
        this.displayPersonEventDialog = false;
    }

    openGoalDialog() {
        this.displayGoalDialog = true;
    }

    closeGoalDialog() {
        this.displayGoalDialog = false;
    }

    openRecordTypeDialog() {
        this.displayGoalRecordTypeDialog = true;
    }

    closeRecordTypeDialog() {
        this.displayGoalRecordTypeDialog = false;
    }

    newGoal() {
        this.formMode = 'new';
        this.hideUpload = false;
        this.openRecordTypeDialog();
    }

    createNewGoal() {
        if (this.template.querySelector("[data-field='product-type']").value === 'Investment') {
            this.isInvestmentGoal = true;
            this.isProtectionGoal = false;
        }
        else if (this.template.querySelector("[data-field='product-type']").value === 'Protection') {
            this.isInvestmentGoal = false;
            this.isProtectionGoal = true;
        }

        this.goalProductType = this.template.querySelector("[data-field='product-type']").value;
        this.clearGoalForm();
        this.openGoalDialog();
        this.displayGoalRecordTypeDialog = false;
    }

    editPersonLifeEvent(event) {
        this.clearPersonLifeEventForm();
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

        this.openPersonLifeEventDialog();
    }

    editGoal(event) {
        this.formMode = 'edit';
        this.hideUpload = true;
        this.clearGoalForm();
        const goalId = event.target.attributes.getNamedItem("data-recordid").value;
        const goalData = this.goalList;

        let selectedGoal = goalData.find(obj => {
            return obj.Id === goalId;
        });

        this.goalId = selectedGoal[GOAL_ID_FIELD.fieldApiName];
        this.goalType = selectedGoal[GOAL_TYPE_FIELD.fieldApiName];
        this.goalPriority = selectedGoal[GOAL_PRIORITY_FIELD.fieldApiName];
        this.goalName = selectedGoal[GOAL_NAME_FIELD.fieldApiName];
        this.goalDescription = selectedGoal[GOAL_DESCRIPTION_FIELD.fieldApiName];
        this.goalTargetDate = selectedGoal[GOAL_TARGETDATE_FIELD.fieldApiName];
        this.goalInitialValue = selectedGoal[GOAL_INITIALVALUE_FIELD.fieldApiName];
        this.goalActualValue = selectedGoal[GOAL_ACTUALVALUE_FIELD.fieldApiName];
        this.goalTargetValue = selectedGoal[GOAL_TARGETVALUE_FIELD.fieldApiName];
        this.isInvestmentGoal = (selectedGoal[GOAL_PRODUCTTYPE_FIELD.fieldApiName] === 'Investment');
        this.isProtectionGoal = (selectedGoal[GOAL_PRODUCTTYPE_FIELD.fieldApiName] === 'Protection');

        this.openGoalDialog();
    }

    savePersonLifeEvent() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allValid) {
            const personLifeEvent = {};
            personLifeEvent['personLifeEventId'] = this.personLifeEventId;
            personLifeEvent['personLifeEventName'] = this.template.querySelector("[data-field='life-event-name']").value;
            personLifeEvent['personLifeEventDescription'] = this.template.querySelector("[data-field='life-event-description']").value;
            personLifeEvent['personLifeEventImpact'] = this.template.querySelector("[data-field='life-event-impact']").value;
            personLifeEvent['personLifeEventImpactDes'] = this.template.querySelector("[data-field='life-event-impactdes']").value;
            //plaster for review - fix
            personLifeEvent['personLifeEventPriority'] = '';
            personLifeEvent['personLifeEventDate'] = this.template.querySelector("[data-field='life-event-date']").value;

            savePersonLifeEvent({ request: JSON.stringify(personLifeEvent) })
                .then(result => {
                    this.insertedPersonLifeEventId = result;
                    this.template.querySelector('c-cmn-lwc-toast').successNotification();
                    this.closePersonLifeEventDialog();
                    refreshApex(this.wiredPersonLifeEvents);
                })
                .catch(error => {
                    console.log("save goal error: " + JSON.stringify(error));
                    this.template.querySelector('c-cmn-lwc-toast').customNotification('Error updating record', error.body.message, 'error');
                });

        }
        else {
            // The form is not valid
            this.template.querySelector('c-cmn-lwc-toast').customNotification('Something is wrong', 'Check your input and try again.', 'error');
        }
    }

    saveGoal() {

        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allValid) {
            const fields = {};
            if (this.goalId !== null) {
                fields[GOAL_ID_FIELD.fieldApiName] = this.goalId;
            }
            fields[GOAL_NAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='goal-name']").value;
            fields[GOAL_TYPE_FIELD.fieldApiName] = this.template.querySelector("[data-field='goal-type']").value;
            fields[GOAL_PRIORITY_FIELD.fieldApiName] = this.template.querySelector("[data-field='goal-priority']").value;
            fields[GOAL_TARGETDATE_FIELD.fieldApiName] = this.template.querySelector("[data-field='target-date']").value;
            fields[GOAL_ACTUALVALUE_FIELD.fieldApiName] = this.template.querySelector("[data-field='actual-value']").value;
            fields[GOAL_TARGETVALUE_FIELD.fieldApiName] = this.template.querySelector("[data-field='target-value']").value;

            if (this.isInvestmentGoal) {
                fields[GOAL_INITIALVALUE_FIELD.fieldApiName] = this.template.querySelector("[data-field='initial-value']").value;
            }

            if (this.formMode === 'edit') {
                const recordInput = { fields };
                console.log('recordInput: ' + JSON.stringify(recordInput));
                updateRecord(recordInput)
                    .then(() => {
                        this.template.querySelector('c-cmn-lwc-toast').successNotification();
                        this.closeGoalDialog();
                        // Display fresh data in the form
                        refreshApex(this.wiredGoals);
                        this.template.querySelector('c-aw-lwc-doughnut-chart').updateChart();
                    })
                    .catch(error => {
                        this.template.querySelector('c-cmn-lwc-toast').customNotification('Error updating record', error.body.message, 'error');
                    });
            }
            else if (this.formMode === 'new') {
                fields[GOAL_PRODUCTTYPE_FIELD.fieldApiName] = this.goalProductType;
                fields[GOAL_PRIMARYOWNER_FIELD.fieldApiName] = this.userAccountId;
                const recordInput = { apiName: GOAL_OBJECT.objectApiName, fields };

                window.console.log('recordInput: ' + JSON.stringify(recordInput));

                createRecord(recordInput)
                    .then(goal => {
                        this.insertedGoalId = goal.Id;
                        this.template.querySelector('c-cmn-lwc-toast').successNotification();
                        this.closeGoalDialog();
                        // Display fresh data in the form
                        refreshApex(this.wiredGoals);
                        this.template.querySelector('c-aw-lwc-doughnut-chart').updateChart();
                    })
                    .catch(error => {
                        this.template.querySelector('c-cmn-lwc-toast').customNotification('Error updating record', error.body.message, 'error');
                    });
            }
        }
        else {
            // The form is not valid
            this.template.querySelector('c-cmn-lwc-toast').customNotification('Something is wrong', 'Check your input and try again.', 'error');
        }

    }


    deleteGoal(event) {
        const recordId = event.target.dataset.recordid;

        deleteGoal({ itemId: recordId })
        .then(result => {
            this.template.querySelector('c-cmn-lwc-toast').customNotification('Success', 'Goal deleted successfully', 'success');
            refreshApex(this.wiredGoals);
        })
        .catch(error => {
            this.template.querySelector('c-cmn-lwc-toast').customNotification('Error Deleting record', error.body.message, 'error');
        });
    }

    clearGoalForm() {
        //to do: find all field dynamically and clear
        this.goalId = null;
        this.goalType = "";
        this.goalTargetDate = "";
        this.goalInitialValue = "";
        this.goalActualValue = "";
        this.goalTargetValue = "";
        this.goalName = "";
        this.goalDescription = "";
    }

    clearPersonLifeEventForm() {
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