import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id'; 
import USER_ACCOUNTID_FIELD from '@salesforce/schema/User.AccountId';
import USER_ACCOUNTRECORDTYPE_FIELD from '@salesforce/schema/User.Account.RecordType.DeveloperName';
import OWNER_NAME_FIELD from '@salesforce/schema/User.Name';

import getAccountDetails from '@salesforce/apex/SLC_CTRL_YourServicingTeam.getAccountDetails';
import getUnmannedContacts from '@salesforce/apex/SLC_CTRL_YourServicingTeam.getUnmannedContacts';
import getServicingTeam from '@salesforce/apex/SLC_CTRL_YourServicingTeam.getClientExpTeam';
import getEscalationTeam from '@salesforce/apex/SLC_CTRL_YourServicingTeam.getEscalationTeam';

export default class slcLwcYourServicingTeam extends LightningElement {
    static renderMode = 'light';
    
    @track error;
    @api baseURL; 
    @api contactUsURL;
    @api userAccountId;
    @api userAccountRecordType;
    @api ownerFirstName;
    @api ownerLastName;
    @api ownerPhoto;
    @api ownerEmail;
    @api ownerPhone;
    @api ownerTitle;
    @api backupFirstName;
    @api backupLastName;
    @api backupPhoto;
    @api backupEmail;
    @api backupPhone;
    @api backupTitle;
    @api userManned;
    @api parentClientClassification;
    @api showBDMCFM;
    @api showBackup;
    @api bdmCfmObject;
    @api instoGroupEmail = 'STANLIBInstitutional@stanlib.com';
    @api corpCashEmail = 'STANLIBCashSolutions@stanlib.com';
    @api showServicingTeam;
    @api servicingObject;
    @api showEscalationTeam;
    @api escalationObject;
    showTeamName = false;
    parentAccExists = false;
    cfmBdmLabel = 'CFM/BDM';
    cliExpLabel = 'Client Experience Team';
    escTeamLabel = 'Escalation Team';

    @api headshotHeightOwner;
    @api headshotWidthOwner;
    @api headshotHeightServicing;
    @api headshotWidthServicing;
    @api headshotHeightEscalation;
    @api headshotWidthEscalation;

    connectedCallback(){
        this.baseURL = window.location;
        this.contactUsURL = this.baseURL.origin+this.baseURL.pathname+'contactsupport';
    }

    //get person account id of logged in user
    @wire(getRecord, { recordId: USER_ID, fields: [OWNER_NAME_FIELD, USER_ACCOUNTID_FIELD, USER_ACCOUNTRECORDTYPE_FIELD] }) 
    wireUser({ error, data }) {
        if (error) {
           this.error = error; 
        } else if (data) {
            if(data.fields.AccountId.value){
                this.userAccountId = data.fields.AccountId.value;
                this.userAccountRecordType = data.fields.Account.value.fields.RecordType.value.fields.DeveloperName.value;

                //get details of owner (BDM/CFM), backup BDM/CFM, channel and manned status of person account
                getAccountDetails({ userAccountId : this.userAccountId })
                .then(result => {
                    console.log(result);
                    console.log(JSON.stringify(result))
                    this.userManned = result.SLR_MannedUnmanned__c;
                    this.parentAccExists = result.AW_ParentAccount__c;

                    //owner details
                    this.ownerFirstName = result.Owner.FirstName;
                    this.ownerLastName = result.Owner.LastName;
                    this.ownerPhoto = result.Owner.FullPhotoUrl;
                    this.ownerEmail = result.Owner.Email;
                    this.ownerPhone = result.Owner.Phone;
                    this.ownerId = result.Owner.Id;
                    this.ownerTitle = result.Owner.Title;

                    //backup BDM/CFM
                    if(this.parentAccExists && result.AW_ParentAccount__r.SLI_AlternateOwner__c){
                        this.backupFirstName = result.AW_ParentAccount__r.SLI_AlternateOwner__r.FirstName;
                        this.backupLastName = result.AW_ParentAccount__r.SLI_AlternateOwner__r.LastName;
                        this.backupPhoto = result.AW_ParentAccount__r.SLI_AlternateOwner__r.FullPhotoUrl;
                        this.backupEmail = result.AW_ParentAccount__r.SLI_AlternateOwner__r.Email;
                        this.backupPhone = result.AW_ParentAccount__r.SLI_AlternateOwner__r.Phone;
                        this.backupId = result.AW_ParentAccount__r.SLI_AlternateOwner__r.Id;
                        this.backupTitle = result.AW_ParentAccount__r.SLI_AlternateOwner__r.Title;
                    }

                    //create BDM/CFM object
                    if(this.userAccountRecordType=='SLI_PersonAccount'){
                        this.cfmBdmLabel = 'Client Fund Manager';
                        this.escTeamLabel = 'Leadership Team';
                        var dataList = [];
                        
                        var mainContact = {
                            fullName : this.ownerFirstName+' '+this.ownerLastName,
                            profilePhoto : this.ownerPhoto,
                            Id : this.ownerId,
                            emailAddress : this.ownerEmail,
                            emailFirstName : 'Email ' + this.ownerFirstName,
                            title : this.ownerTitle,
                            phone : this.ownerPhone
                        };

                        dataList.push(mainContact);
                        
                        if(this.parentAccExists && result.AW_ParentAccount__r.SLI_AlternateOwner__c){
                            var backupContact = {
                                fullName : this.backupFirstName+' '+this.backupLastName,
                                profilePhoto : this.backupPhoto,
                                Id : this.backupId,
                                emailAddress : this.backupEmail,
                                emailFirstName : 'Email ' + this.backupFirstName,
                                title : this.backupTitle,
                                phone : this.backupPhone
                            };
                        dataList.push(backupContact); 
                        }   

                        this.bdmCfmObject = dataList;
                    } else {
                        this.cfmBdmLabel = 'Business Development Manager';
                        this.escTeamLabel = 'Escalation Team';
                        var dataList = [];

                        if(this.userManned=='Manned'){
                            var mainContact = {
                                fullName : this.ownerFirstName+' '+this.ownerLastName,
                                profilePhoto : this.ownerPhoto,
                                Id : this.ownerId,
                                emailAddress : this.ownerEmail,
                                emailFirstName : 'Email ' + this.ownerFirstName,
                                title : this.ownerTitle,
                                phone : this.ownerPhone
                            };            
                            
                            dataList.push(mainContact);
                            this.bdmCfmObject = dataList;
                        } else { 
                            getUnmannedContacts()
                            .then(result => {
                                if(result.length > 0){
                                    for(var i=0; i<result.length; i++){
                                        var unmannedObject = {
                                            fullName : result[i].FirstName+' '+result[i].LastName,
                                            profilePhoto : result[i].FullPhotoUrl,
                                            Id : result[i].Id,
                                            emailAddress : result[i].Email,
                                            emailFirstName : 'Email ' + result[i].FirstName,
                                            title : result[i].Title,
                                            phone : result[i].Phone
                                        };
                                        dataList.push(unmannedObject);
                                        this.bdmCfmObject = dataList;
                                    }                                   
                                }
                            })
                            .catch(error => {
                                this.error = error;
                                console.log('getUnmannedContacts error: ' + this.error)
                            })
                        }
                    }                    

                    if(this.parentAccExists && result.AW_ParentAccount__r.SLI_ClientClassification__c){
                        this.parentClientClassification = result.AW_ParentAccount__r.SLI_ClientClassification__c;
                        this.getTeamDetails(this.parentClientClassification);
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log('getAccountDetails error: ' + this.error)
                })
            }
        }
    }

    //get team members of servicing and escalation teams
    getTeamDetails(clientClassification){
        var groupEmail;
        if(clientClassification=='Institutional'){
            groupEmail = this.instoGroupEmail;
        } else if (clientClassification=='Corporate Cash'){
            groupEmail = this.corpCashEmail;
        }
        
        getServicingTeam({ teamName : clientClassification })
        .then(result => {
            if(result.length > 0){
                this.showServicingTeam = true;
                var dataList = [];

                for(var i=0; i<result.length; i++){
                    var currentObject = {
                        fullName : result[i].FirstName+' '+result[i].LastName,
                        profilePhoto : result[i].FullPhotoUrl,
                        Id : result[i].Id,
                        emailAddress : result[i].Email,
                        emailFirstName : 'Email ' + result[i].FirstName,
                        title : result[i].Title,
                        phone : result[i].Phone,
                        groupEmailAddress : groupEmail ? groupEmail : result[i].Email
                    };
                    dataList.push(currentObject);
                }
                this.servicingObject = dataList;  
            } else {
                this.showServicingTeam = false;
            }                   
        })
        .catch(error => {
            this.error = error;
            console.log('getServicingTeam error: ' + this.error)
        })

        getEscalationTeam({ teamName : clientClassification })
        .then(result => {
            if(result.length > 0){
                this.showEscalationTeam = true;
                var dataList = [];

                for(var i=0; i<result.length; i++){
                    var currentObject = {
                        fullName : result[i].FirstName+' '+result[i].LastName,
                        profilePhoto : result[i].FullPhotoUrl,
                        Id : result[i].Id,
                        emailAddress : result[i].Email,
                        emailFirstName : 'Email ' + result[i].FirstName,
                        title : result[i].Title,
                        phone : result[i].Phone
                    };
                    dataList.push(currentObject);
                }
                this.escalationObject = dataList;
            } else {
                this.showEscalationTeam = false;
            }                   
        })
        .catch(error => {
            this.error = error;
            console.log('getEscalationTeam error: ' + this.error)
        })
    }

}