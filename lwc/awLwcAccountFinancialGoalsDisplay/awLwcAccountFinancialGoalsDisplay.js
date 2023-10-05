/**
 * @description LWC Component used to view financial goals on Account record page.
 *
 * @author pavan.t@lntinfotech.com, safwan.h.mohammed@accenture.com, vishakha.saini@accenture.com
 *
 * @date December 2022, April 2023
 */

import fetchGoals from '@salesforce/apex/AW_CTRL_ImplementGoal.fetchGoals';
import REFRESH_LWC from '@salesforce/messageChannel/AW_MC_RefreshLwc__c';
import {MessageContext, subscribe} from 'lightning/messageService';
import {NavigationMixin} from 'lightning/navigation';
import {api, LightningElement, track, wire} from 'lwc';

const GOAL_TYPE_INVESTMENT = 'Investment';
const GOAL_TYPE_RISK = 'Risk';
const LUMP_SUM_DISABILITY = 'LUMP SUM DISABILITY';
const LIFE_COVER = 'LIFE COVER';
const INCOME_DISABILITY_TO_24_MONTHS = 'INCOME DISABILITY FIRST 24 MONTHS';
const INCOME_DISABILITY_AFTER_24_MONTHS = 'INCOME DISABILITY AFTER 24 MONTHS';
const CRITICAL_ILLNESS = 'CRITICAL ILLNESS';
const DELAY = 5000;

//noinspection JSClassNamingConvention
export default class AwLwcAccountFinancialGoalsDisplay extends NavigationMixin(LightningElement)
{

	@api recordId;
	@track investmentGoalRecords = [];
	@track riskGoalRecords = [];
	@track title;
	@track investmentSectionName;
	@track riskGoalSectionName;
	error;

	@wire(MessageContext)
	messageContext;

	connectedCallback()
	{
		this.fetchGoal();
		this.subscribeToMessageChannel();
	}

	fetchGoal()
	{
		fetchGoals({accountId: this.recordId})
		.then(result =>
		{
			if(result)
			{
				let investmentGoalCount = 0;
				let riskGoalCount = 0;
				let investmentGoalRecs = [];
				let riskGoalRecs = [];
				for(let i = 0; i < result.length; i++)
				{
					if(result[i].AW_Goal_Type__c === GOAL_TYPE_INVESTMENT)
					{
						investmentGoalRecs.push(result[i]);
						investmentGoalCount++;
					}
					else if(result[i].AW_Goal_Type__c === GOAL_TYPE_RISK)
					{
						switch(result[i].Name.toUpperCase())
						{
							case LUMP_SUM_DISABILITY:
								riskGoalRecs.push({riskId: 2, item: result[i]});
								break;
							case LIFE_COVER:
								riskGoalRecs.push({riskId: 1, item: result[i]});
								break;
							case INCOME_DISABILITY_TO_24_MONTHS:
								riskGoalRecs.push({riskId: 3, item: result[i]});
								break;
							case INCOME_DISABILITY_AFTER_24_MONTHS:
								riskGoalRecs.push({riskId: 4, item: result[i]});
								break;
							case CRITICAL_ILLNESS:
								riskGoalRecs.push({riskId: 5, item: result[i]});
								break;
							default:
								riskGoalRecs.push({riskId: 6, item: result[i]});
						}
						riskGoalCount++;
					}

				}

				this.title = 'Goals and Needs (' + (investmentGoalCount + riskGoalCount) + ')';
				this.investmentSectionName = 'Investment Goals (' + investmentGoalCount + ')';
				this.riskGoalSectionName = 'Risk Needs (' + riskGoalCount + ')';
				this.riskGoalRecords = riskGoalRecs.sort((a, b) => parseInt(a.riskId) - parseInt(b.riskId)).map((x) => x.item);

				this.investmentGoalRecords = investmentGoalRecs.sort(function compare(a, b)
				{
					let dateA = new Date(a.CreatedDate);
					let dateB = new Date(b.CreatedDate);
					return dateB - dateA;
				});
			}
			else if(result.error)
			{
				this.error = result.error;
			}
		});
	}

	subscribeToMessageChannel()
	{
		subscribe(this.messageContext, REFRESH_LWC, () => this.refreshLwc());
	}

	refreshLwc()
	{
		setTimeout(() => 
		{
			this.fetchGoal();
		}, DELAY);
	}

	onclickGoal(event)
	{
		event.preventDefault();
		event.stopPropagation();
		this.navigateToRecordViewPage(event.target.dataset.recordId);
	}

	navigateToRecordViewPage(eventRecordId)
	{
		this[NavigationMixin.GenerateUrl]({
			type: 'standard__recordPage', attributes: {
				recordId: eventRecordId, objectApiName: 'FinServ__FinancialGoal__c', actionName: 'view'
			}
		}).then(url =>
		{
			window.open(url, '_self');
		});
	}
}