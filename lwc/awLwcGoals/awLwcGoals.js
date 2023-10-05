import { LightningElement, wire, track } from "lwc";
import userId from '@salesforce/user/Id';
import getGoals from "@salesforce/apex/AW_CTR_ClientCommunity.getGoalList";
import { deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import GOAL_OBJECT from '@salesforce/schema/FinServ__FinancialGoal__c';
import GOAL_ID_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.Id';
import GOAL_NAME_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.Name';
import GOAL_TYPE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__Type__c';
import GOAL_DESCRIPTION_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__Description__c';
import GOAL_TARGETDATE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__TargetDate__c';
import GOAL_INITIALVALUE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__InitialValue__c';
import GOAL_ACTUALVALUE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__ActualValue__c';
import GOAL_TARGETVALUE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__TargetValue__c';
import GOAL_PRIMARYOWNER_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.FinServ__PrimaryOwner__c';
import GOAL_PRODUCTTYPE_FIELD from '@salesforce/schema/FinServ__FinancialGoal__c.AW_ProductType__c';


export default class AwLwcGoals extends LightningElement {
  @track displayGoalDialog = false;
  @track displayGoalRecordTypeDialog = false;
  @track goalList;
  @track goalListError;
  @track insertedGoalId;
  @track goalRecordType;
  @track isInvestmentGoal;
  @track isProtectionGoal;
  @track formMode; //new, edit
  wiredGoals;

  //edit goal variables
  @track goalId;
  @track goalName;
  @track goalDescription;
  @track goalProductType;
  @track goalType;
  @track goalTargetDate;
  @track goalInitialValue;
  @track goalActualValue;
  @track goalTargetValue;

  @wire(getRecord, { recordId: userId, fields: ['User.AccountId'] })
  user;

  get userAccountId() {
    return this.user.data.fields.AccountId.value;
  }

  @wire(getGoals) goals(result) {
    this.wiredGoals = result;
    if (result.data) {
      this.goalList = result.data;
      this.goalListError = undefined;
    } else if (result.error) {
      this.goalListError = result.error;
      this.goalList = undefined;
    }
  }

  @wire(getObjectInfo, { objectApiName: GOAL_OBJECT })
  objectInfo;

  get recordTypeInvestmentId() {
    const rtis = this.objectInfo.data.recordTypeInfos;
    return Object.keys(rtis).find(rti => rtis[rti].name === 'Investment');
  }

  get recordTypeProtectionId() {
    const rtis = this.objectInfo.data.recordTypeInfos;
    return Object.keys(rtis).find(rti => rtis[rti].name === 'Protection');
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

  get recordTypeName() {
    return [
      { label: "Investment", value: "Investment" },
      { label: "Protection", value: "Protection" }
    ];
  }


  openDialog() {
    this.displayGoalDialog = true;
  }

  closeDialog() {
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
    this.clearForm();
    this.openDialog();
    this.displayGoalRecordTypeDialog = false;
  }

  editGoal(event) {
    this.formMode = 'edit';
    this.clearForm();
    const goalId = event.target.attributes.getNamedItem("data-recordid").value;
    const goalData = this.goalList;

    let selectedGoal = goalData.find(obj => {
      return obj.Id === goalId;
    });

    this.goalId = selectedGoal[GOAL_ID_FIELD.fieldApiName];
    this.goalType = selectedGoal[GOAL_TYPE_FIELD.fieldApiName];
    this.goalName = selectedGoal[GOAL_NAME_FIELD.fieldApiName];
    this.goalDescription = selectedGoal[GOAL_DESCRIPTION_FIELD.fieldApiName];
    this.goalTargetDate = selectedGoal[GOAL_TARGETDATE_FIELD.fieldApiName];
    this.goalInitialValue = selectedGoal[GOAL_INITIALVALUE_FIELD.fieldApiName];
    this.goalActualValue = selectedGoal[GOAL_ACTUALVALUE_FIELD.fieldApiName];
    this.goalTargetValue = selectedGoal[GOAL_TARGETVALUE_FIELD.fieldApiName];
    this.isInvestmentGoal = (selectedGoal[GOAL_PRODUCTTYPE_FIELD.fieldApiName] === 'Investment');
    this.isProtectionGoal = (selectedGoal[GOAL_PRODUCTTYPE_FIELD.fieldApiName] === 'Protection');

    this.openDialog();
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
      fields[GOAL_DESCRIPTION_FIELD.fieldApiName] = this.template.querySelector("[data-field='goal-description']").value;
      fields[GOAL_TARGETDATE_FIELD.fieldApiName] = this.template.querySelector("[data-field='target-date']").value;
      //console.log('actual' + this.template.querySelector("[data-field='actual-value']").value);
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
            this.closeDialog();
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

        createRecord(recordInput)
          .then(goal => {
            this.insertedGoalId = goal.Id;
            this.template.querySelector('c-cmn-lwc-toast').successNotification();
            this.closeDialog();
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
    this.goalId = null;
    this.goalType = "";
    this.goalTargetDate = "";
    this.goalInitialValue = "";
    this.goalActualValue = "";
    this.goalTargetValue = "";
    this.goalName = "";
    this.goalDescription = "";
  }

}