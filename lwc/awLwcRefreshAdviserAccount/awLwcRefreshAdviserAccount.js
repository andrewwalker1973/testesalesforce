/**
 * @description LWC Component to display the master account details on adviser account.
 *
 * @author pavan.t@lntinfotech.com, k.marakalala@accenture.com
 *
 * @date July 2023
 */
import {refreshApex} from '@salesforce/apex';
import checkForAccountPolicies from '@salesforce/apex/AW_CTRL_RefreshAdviserAccount.checkForAccountPolicies';
import getFieldDetailsForRecord from '@salesforce/apex/AW_CTRL_RefreshAdviserAccount.getFieldDetailsForRecord';
import updateChildAccount from '@salesforce/apex/AW_CTRL_RefreshAdviserAccount.updateChildAccount';
import PARENT_ACCOUNT_ID from '@salesforce/schema/Account.AW_ParentAccount__c';
import {getFieldValue, getRecord, notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import {api, LightningElement, track, wire} from 'lwc';

const POLICIES_EXCEPTION_MESSAGE = 'Exception when fetching policies for account';
const FIELD_DETAILS_EXCEPTION_MESSAGE = 'Exception when loading Master Account Details';
const TOAST_ERROR_MESSAGE_VARIANT = 'error';
const UPDATE_ACCOUNT_EXCEPTION_MESSAGE = 'Exception when updating account';
const UPDATE_ACCOUNT_SUCCESS_MESSAGE = 'Your client detail has been updated successfully';
const READ_ONLY_FIELD_SETS = [
	'AW_RefreshAdviserAdditionalInfoSection',
	'AW_RefreshAdviserSystemInfoSection'
];

export default class AwLwcRefreshAdviserAccount extends LightningElement {
  @api recordId;
  @track fieldDifferenceList = [];
  accountHasPolicies;
  activeSections = [
    "AW_RefreshAdviserCoreDetailSection",
    "AW_RefreshAdviserContactDetailSection"
  ];
  blankString = "<BLANK>";
  contactSupportMessage =
    "Liberty client master account record is not available for this client, please contact support at workbench@liberty.co.za";
  isModalOpen = false;
  isSpinnerLoading = false;
  masterAccountNotFoundMessage =
    "Liberty client master account record is not available for this client, please contact support at workbench@liberty.co.za";
  originalFieldDifferenceList = [];
  parentAccountId;
  selectedItems = [];
  updateDifferenceButtonLabel;
  @track fieldSetDifferenceDTOList;
  refreshDTOResponse;

  /**
   * @description wired method to get the parent account id
   **/
  @wire(getRecord, { recordId: "$recordId", fields: [PARENT_ACCOUNT_ID] })
  wiredCase(result) {
    this.refreshDTOResponse = result;
    if (result.data) {
      this.parentAccountId = getFieldValue(result.data, PARENT_ACCOUNT_ID);
      if (this.parentAccountId !== undefined && this.parentAccountId === null) {
        this.checkForAccountPolicies(this.recordId);
      } else if (
        this.parentAccountId !== undefined &&
        this.parentAccountId !== null
      ) {
        this.getFieldsForFieldSet([this.recordId, this.parentAccountId]);
      }
    } else if (result.error) {
      this.showToast(
        "Error",
        result.error.body.message,
        TOAST_ERROR_MESSAGE_VARIANT
      );
    }
  }

  /**
   * @description this method will check for account policies if parent account is null
   */
  checkForAccountPolicies() {
    checkForAccountPolicies({ accountId: this.recordId })
      .then((result) => {
        this.accountHasPolicies = result;
      })
      .catch((error) => {
        this.showToast(
          POLICIES_EXCEPTION_MESSAGE,
          error,
          TOAST_ERROR_MESSAGE_VARIANT
        );
      });
  }

  /**
   * @description method to get the field differences list
   * @param accountIdRecords list of account record ids
   */
  getFieldsForFieldSet(accountIdRecords) {
    getFieldDetailsForRecord({
      accountIds: accountIdRecords
    })
      .then((result) => {
        let childAccountFieldSetMembers = Object.values(result[this.recordId]);
        let parentAccountFieldSetMembers = Object.values(result[this.parentAccountId]);
        this.compareFieldDifferences(
          parentAccountFieldSetMembers,
          childAccountFieldSetMembers
        );
      })
      .catch((error) => {
        console.log("error:" + error);
        this.showToast(
          FIELD_DETAILS_EXCEPTION_MESSAGE,
          error,
          TOAST_ERROR_MESSAGE_VARIANT
        );
      });
  }
  //noinspection FunctionWithMultipleLoopsJS
  /**
   * @description method to compute the field differences bases on parent and child values
   * @param parentAccountFieldSetMembers parent account fieldSetMembers
   * @param childAccountFieldSetMembers child account fieldSetMembers
   */
  compareFieldDifferences(
    parentAccountFieldSetMembers,
    childAccountFieldSetMembers
  ) {
    this.fieldSetDifferenceDTOList = [];
    this.fieldDifferenceList = [];
    let totalDifferenceCount = 0;
    for (let i = 0; i < parentAccountFieldSetMembers.length; i++) {
      let fieldDifferencePerSection = [];
      let sectionName = "";
      let sectionAPIName = "";
      let sectionDifferenceCount = 0;
      let fieldDifferenceItem = {};
      for (let j = 0; j < parentAccountFieldSetMembers[i].length; j++) {
        let parentFieldItem = parentAccountFieldSetMembers[i][j];
        let childFieldItem = childAccountFieldSetMembers[i][j];
        sectionName = parentFieldItem.fieldSetName;
        sectionAPIName = parentFieldItem.fieldSetAPIName;
        this.checkValueIsSetForField(parentFieldItem, childFieldItem);
        this.setAdditionalAttributesForFields(parentFieldItem, childFieldItem);
        if (
          !READ_ONLY_FIELD_SETS.includes(parentFieldItem.fieldSetAPIName) &&
          parentFieldItem.fieldDisplayValue.toUpperCase() !==
            parentFieldItem.childFieldDisplayValue.toUpperCase()
        ) {
          this.fieldDifferenceList.push(parentFieldItem);
          parentFieldItem.hasFieldDifference = true;
          totalDifferenceCount++;
          sectionDifferenceCount++;
        } else {
          parentFieldItem.hasFieldDifference = false;
        }
        fieldDifferencePerSection.push(parentFieldItem);
      }
      this.composeFieldSetDifferenceDTOList(
        fieldDifferenceItem,sectionDifferenceCount,sectionName,
        sectionAPIName,fieldDifferencePerSection
        );
    }
    this.setUpdateDifferenceButtonLabel(totalDifferenceCount);
    this.originalFieldDifferenceList = this.fieldDifferenceList.map((element) => Object.assign({}, element));
  }

  /**
   *@description this method will check field value is set or not
   * @param parentFieldItem parent account fieldSetMember
   * @param childFieldItem child account fieldSetMember
   */
  checkValueIsSetForField(parentFieldItem, childFieldItem) {
    if (parentFieldItem.valueIsSet === false) {
      parentFieldItem.fieldDisplayValue = "";
      parentFieldItem.fieldValue = null;
    }
    if (childFieldItem.valueIsSet === false) {
      parentFieldItem.childFieldDisplayValue = "";
      childFieldItem.fieldValue = null;
    } else {
      parentFieldItem.childFieldDisplayValue = childFieldItem.fieldDisplayValue;
    }
  }

  /**
   *@description this method will set the values for additional attributes
   * @param parentFieldItem parent account fieldSetMember
   * @param childFieldItem child account fieldSetMember
   */
  setAdditionalAttributesForFields(parentFieldItem, childFieldItem) {
    if (parentFieldItem.fieldType === "DATE") {
      parentFieldItem.fieldDisplayValue =
        parentFieldItem.fieldDisplayValue.replace("00:00:00", "");
      parentFieldItem.childFieldDisplayValue =
        parentFieldItem.childFieldDisplayValue.replace("00:00:00", "");
    }
    parentFieldItem.isCurrencyField = parentFieldItem.fieldType === "CURRENCY";
    parentFieldItem.isMasterBlank =
      parentFieldItem.fieldValue === null && childFieldItem.fieldValue !== null;
    parentFieldItem.fieldLabel = parentFieldItem.fieldLabel.includes("ID")
      ? parentFieldItem.fieldLabel.replace("ID", "")
      : parentFieldItem.fieldLabel;
  }

  /**
   *@description getter method to check the account has the parent record
   *@param totalDifferenceCount total field difference count
   */
  setUpdateDifferenceButtonLabel(totalDifferenceCount) {
    this.updateDifferenceButtonLabel =
      totalDifferenceCount > 0
        ? "Update Difference (" + totalDifferenceCount + ")"
        : "No Difference";
  }

  /**
   * @description this method will set the values for fieldSetDifferenceDTOList
   * @param fieldDifferenceItem field section item
   * @param sectionDifferenceCount no of differences count per each section
   * @param sectionName fieldset name
   * @param sectionAPIName fieldset api name
   * @param fieldDifferencePerSection field difference items per section
   */
  composeFieldSetDifferenceDTOList(
    fieldDifferenceItem,
    sectionDifferenceCount,
    sectionName,
    sectionAPIName,
    fieldDifferencePerSection
  ) {
    fieldDifferenceItem.sectionName =
      sectionDifferenceCount > 0
        ? sectionName + " (" + sectionDifferenceCount + ")"
        : sectionName;
    fieldDifferenceItem.sectionApiName = sectionAPIName;
    fieldDifferenceItem.fieldDetails = fieldDifferencePerSection;
    this.fieldSetDifferenceDTOList.push(fieldDifferenceItem);
  }

  /**
   *@description getter method to check the account has the parent record
   */
  get checkParentAccountId() {
    return this.parentAccountId === null;
  }

  /**
   * @description used to show toast message based on different success or fail scenarios
   */
  showToast(title, message, variant) {
    this.template
      .querySelector("c-cmn-lwc-toast")
      .customNotification(title, message, variant);
  }

  /**
   * @description handle update differences model
   */
  updateDifferencesModal() {
    this.isModalOpen = true;
  }

  /**
   * @description handle model close
   */
  closeModal() {
    this.isModalOpen = false;
    this.fieldDifferenceList = this.originalFieldDifferenceList.map((element) =>
      Object.assign({}, element)
    );
    this.selectedItems = [];
  }

  /**
   * @description handle conditional disable of update button on model
   */
  get disableUpdateButton() {
    return !(
      this.selectedItems &&
      this.selectedItems.length > 0 &&
      !this.isSpinnerLoading
    );
  }

  /**
   * @description handle conditional disable of update difference button on component
   */
  get disableUpdateDifferencesButton() {
    return !(this.fieldDifferenceList && this.fieldDifferenceList.length > 0);
  }

  /**
   * @description handle field differences check
   */
  get checkForFieldDifferences() {
    return this.fieldSetDifferenceDTOList;
  }

  /**
   * @description handle update differences model field selection
   */
  handleFieldSelectionChange(event) {
    let fieldName = event.currentTarget.dataset.id;
    let templateName = this.template.querySelector(`[data-cv="${fieldName}"]`);
    let index = this.fieldDifferenceList.findIndex(
      (element) => element.fieldAPIName === fieldName
    );
    if (event.target.checked) {
      templateName.classList.add("add-color");
      this.fieldDifferenceList[index].childFieldDisplayValue =
        this.fieldDifferenceList[index].fieldDisplayValue;
      this.selectedItems.push(this.fieldDifferenceList[index]);
    } else {
      templateName.classList.remove("add-color");
      this.fieldDifferenceList[index].childFieldDisplayValue =
        this.originalFieldDifferenceList[index].childFieldDisplayValue;
      let itemIndex = this.selectedItems.indexOf(fieldName);
      this.selectedItems.splice(itemIndex, 1);
    }
  }

  /**
   * @description updates account record with selected fields from master
   *
   */
  updateAccountDetails() {
    this.isSpinnerLoading = true;
    let selectedFieldAPINames = [];
    this.selectedItems.forEach(function (fieldItem) {
      selectedFieldAPINames.push(fieldItem.fieldAPIName);
    });

    updateChildAccount({
      selectedFields: selectedFieldAPINames,
      parentAccountId: this.parentAccountId,
      childAccountId: this.recordId
    })
      .then(() => {
        refreshApex(this.refreshDTOResponse).then(() => {
          notifyRecordUpdateAvailable([{ recordId: this.recordId }]).then(
            () => {
              this.isSpinnerLoading = false;
              this.isModalOpen = false;
              this.showToast(
                "Success",
                UPDATE_ACCOUNT_SUCCESS_MESSAGE,
                "Success"
              );
            }
          );
        });
      })
      .catch((error) => {
        this.isModalOpen = false;
        this.isSpinnerLoading = false;
        this.showToast(
          UPDATE_ACCOUNT_EXCEPTION_MESSAGE,
          error,
          TOAST_ERROR_MESSAGE_VARIANT
        );
        this.fieldDifferenceList = this.originalFieldDifferenceList.map(
          (element) => Object.assign({}, element)
        );
      })
      .finally(() => {
        this.selectedItems = [];
      });
  }
}