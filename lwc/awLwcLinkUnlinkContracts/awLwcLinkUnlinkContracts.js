/**
 * @description LWC Component used to Link/Unlink Contracts on Account or Goal Record Page.
 *
 * @author safwan.h.mohammed@accenture.com kiran.kumaryelisetti@lntinfotech.com
 *
 * @date December 2022 June 2023
 */
import getContracts from '@salesforce/apex/AW_CTRL_LinkUnlinkContracts.getContracts';
import getInvestmentGoalsForAccount from '@salesforce/apex/AW_CTRL_LinkUnlinkContracts.getInvestmentGoalsForAccount';
import updateContracts from '@salesforce/apex/AW_CTRL_LinkUnlinkContracts.updateContracts';
import REFRESH_LWC from '@salesforce/messageChannel/AW_MC_RefreshLwc__c';
import ACCOUNT from '@salesforce/schema/Account';
import FINANCIAL_GOAL from '@salesforce/schema/FinServ__FinancialGoal__c';
import OPPORTUNITY from '@salesforce/schema/Opportunity';
import {reduceErrors} from 'c/cmnLwcUtil';
import {MessageContext, publish} from 'lightning/messageService';
import {RefreshEvent} from 'lightning/refresh';
import {api, LightningElement, wire} from 'lwc';

const UPDATE_SUCCESS_MESSAGE = 'Contracts linked/unlinked successfully';
const COLUMNS = [
	{label: 'Account Number', fieldName: 'FinServ__FinancialAccountNumber__c'},
	{label: 'Account Name', sortable: true, fieldName: 'Name'},
	{label: 'Investment Value', fieldName: 'AW_CurrentValue__c'}
];

const GOAL_COLUMNS = [
	{label: 'Financial Goal', fieldName: 'Name'},
	{
		label: 'Target Value', sortable: true, fieldName: 'FinServ__TargetValue__c'
	},
	{label: 'Target Date', fieldName: 'FinServ__TargetDate__c'},
	{label: 'Growth Strategy', fieldName: 'AW_Growth_Strategy__c'}
];

export default class AwLwcLinkUnlinkContracts extends LightningElement
{
	@api objectApiName;
	@api goalRecordId;
	@api accountRecordId;
	selectedRowData;
	goalId;
	isShowModalFinancialGoal = false;
	isShowModalAccount = false;
	columns = COLUMNS;
	contractList = [];
	financialAccountsToDeLink = [];
	financialGoalList = [];
	goalColumns = GOAL_COLUMNS;
	isDisabled = true;
	isLoading;

	@wire(MessageContext)
	messageContext;

	get showLinkContractsToGoalButton()
	{
		return this.objectApiName !== OPPORTUNITY.objectApiName;
	}

	get toast()
	{
		return this.template.querySelector('c-cmn-lwc-toast');
	}

	get hasGoals()
	{
		return this.financialGoalList.length > 0;
	}

	get hasContracts()
	{
		return this.contractList.length > 0;
	}

	get goalTable()
	{
		return this.template.querySelector('.financial-goal-table');
	}

	get contractTable()
	{
		return this.template.querySelector('.contract-table');
	}

	get preSelectedContractIds()
	{
		return this.contractList
		.filter((contract) => contract.AW_FinancialGoal__c === this.goalId)
		.map((contract) => contract.Id);
	}

	handleGoalRowSelection()
	{
		this.isDisabled = false;
	}

	/**
	 * @description used to show the modal pop-up
	 */
	async showModalBox()
	{
		this.isLoading = true;
		switch(this.objectApiName)
		{
			case FINANCIAL_GOAL.objectApiName:
				this.goalId = this.goalRecordId;
				this.isShowModalFinancialGoal = true;
				await this.fetchFinancialAccounts();
				break;
			case ACCOUNT.objectApiName:
				this.isShowModalAccount = true;
				await this.fetchFinancialGoals();
				break;
			default:
				break;
		}
	}

	/**
	 * @description used to fetch Financial goals from account Record
	 */
	fetchFinancialGoals()
	{
		this.isLoading = true;
		return getInvestmentGoalsForAccount({accountId: this.accountRecordId})
		.then((response) =>
		{
			this.financialGoalList = response;
		})
		.catch(this.catchError)
		.finally(() =>
		{
			this.isLoading = false;
		});
	}

	/**
	 * @description used to fetch the Financial accounts
	 */
	fetchFinancialAccounts()
	{
		this.isLoading = true;
		return getContracts({
			accountId: this.accountRecordId, goalId: this.goalId
		})
		.then((response) =>
		{
			this.contractList = response;
		})
		.catch(this.catchError)
		.finally(() =>
		{
			this.isLoading = false;
		});
	}

	/**
	 * @description used to close the modal
	 */
	closeModal()
	{
		this.isShowModalFinancialGoal = false;
		this.isShowModalAccount = false;
		this.financialAccountsToDeLink = [];
		this.financialGoalList = [];
		this.contractList = [];
		this.isDisabled = true;
	}

	/**
	 * @description used to move between two models and fetch the goal id
	 */
	handleNext()
	{
		//noinspection JSUnresolvedFunction
		this.selectedRowData = this.goalTable.getSelectedRows();
		this.goalId = this.selectedRowData[0].Id;
		this.isShowModalAccount = false;
		//noinspection JSIgnoredPromiseFromCall
		this.fetchFinancialAccounts();
		this.isShowModalFinancialGoal = true;
	}

	/**
	 * @description used update the Financial Accounts when the save button is clicked
	 */
	handleSave()
	{
		//noinspection JSUnresolvedFunction
		this.selectedRowData = this.contractTable.getSelectedRows();
		let selectedFinancialAccountIds = this.selectedRowData.map((row) => row.Id);
		this.financialAccountsToDeLink =
				this.preSelectedContractIds.filter((existingContractId) => existingContractId && !selectedFinancialAccountIds.includes(existingContractId));

		this.isLoading = true;
		updateContracts({
			selectedFinancialAccountIds, deselectedFinancialAccountIds: this.financialAccountsToDeLink, goalId: this.goalId
		})
		.then(async() =>
		{
			await this.fetchFinancialAccounts();
			//noinspection JSUnresolvedReference
			this.dispatchEvent(new RefreshEvent());
			const payload = {refreshMessage: this.goalId};
			publish(this.messageContext, REFRESH_LWC, payload);
			this.closeModal();
			//noinspection JSUnresolvedFunction
			this.toast.customNotification('Success', UPDATE_SUCCESS_MESSAGE, 'Success');
		})
		.catch(this.catchError)
		.finally(() =>
		{
			this.isLoading = false;
		});
	}

	/**
	 * @description used to catch error message in a failed scenario
	 */
	catchError(error)
	{
		this.isLoading = false;
		this.closeModal();
		//noinspection JSUnresolvedFunction
		this.toast.customNotification('Error', reduceErrors(error), 'error');
	}
}