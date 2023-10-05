/*
* @description Aura parent component for the Implement Financial Goal Modal.
*
* @author nihal.desai@accenture.com vishakha.saini@accenture.com pavan.t@lntinfotech.com
*
* @date November 2020, February 2022, May 2022, June 2022
*/

({
	fetchFinancialGoals: function(component)
	{
		let actionGetLabels = component.get('c.getLabels');
		actionGetLabels.setParams({
			'apiName': 'FinServ__FinancialGoal__c'
		});
		actionGetLabels.setCallback(this, function(c)
		{
			let stateGetLabels = c.getState();
			if(stateGetLabels === 'SUCCESS')
			{
				component.set('v.financialGoalLabels', c.getReturnValue());
				let result = c.getReturnValue();

				let cols = [//                    Get Label From Fields
					{label: result['name'], fieldName: 'Name', type: 'text'},
					{label: result['aw_goal_type__c'], fieldName: 'AW_Goal_Type__c', type: 'text'},
					{label: result['finserv__status__c'], fieldName: 'FinServ__Status__c', type: 'text'}
				];

				component.set('v.financialGoalColumns', cols);
			}
		});
		$A.enqueueAction(actionGetLabels);

		let actionFetchGoals = component.get('c.fetchGoals');
		actionFetchGoals.setParams({
			'accountId': component.get('v.parentAccountId')
		});
		actionFetchGoals.setCallback(this, function(a)
		{
			let state = a.getState();
			if(state === 'SUCCESS')
			{
				let result = a.getReturnValue();
				let riskGoalList = [];
				let investmentGoalList = [];
				let riskGoalIds = [];
				let riskPlanNeed = [];

				let uniqResult = this.unique(result, [
					'AW_Goal_Type__c',
					'FinServ__Type__c',
					'Name'
				]);

				for(let i = 0; i < uniqResult.length; i++)
				{
					if(uniqResult[i].AW_Goal_Type__c === 'Risk')
					{
						riskGoalIds.push(uniqResult[i].Id);
						riskGoalList.push(uniqResult[i]);
					}

					else if(uniqResult[i].AW_Goal_Type__c === 'Investment')
					{
						investmentGoalList.push(uniqResult[i]);
					}
				}

				if(riskGoalList.length !== 0)
				{
					riskPlanNeed.push({'Name': 'Risk Planning', 'AW_Goal_Type__c': 'Risk', 'FinServ__Status__c': 'Not Started'});
				}

				component.set('v.riskGoalIds', riskGoalIds);
				component.set('v.riskGoalData', riskGoalList[0]);

				if(component.get('v.goalButtonNameChild') === 'implementGoalButton')
				{
					component.set('v.financialGoalData', investmentGoalList);
				}
				else if(component.get('v.goalButtonNameChild') === 'riskGoalButton')
				{
					component.set('v.financialGoalData', riskPlanNeed);
					component.set('v.riskPlanningTypes', riskGoalList);
				}

				//If we have data in the table, show the table, if not, show a message
				if(component.get('v.financialGoalData').length === 0)
				{
					component.set('v.isFinancialGoalEmpty', true);
				}
				else
				{
					component.set('v.isFinancialGoalEmpty', false);
				}
				component.set('v.isLoading', false);
			}
		});
		$A.enqueueAction(actionFetchGoals);
	},

	unique: function(arr, keyProps)
	{
		const kvArray = arr.map(entry =>
		{
			const key = keyProps.map(k => entry[k]).join('|');
			return [
				key,
				entry
			];
		});
		const map = new Map(kvArray);
		return Array.from(map.values());
	},

	modalController: function(component, financialGoal, plannedSolution, quote)
	{
		//        Function for opening and closing modals
		component.set('v.isFinancialGoalOpenChild', financialGoal);
		component.set('v.isPlannedSolutionOpenChild', plannedSolution);
		component.set('v.isQuoteOpenChild', quote);
	},

	/**
	 * @description Method to fetch planned solution
	 */
	getPlannedSolution: function(component)
	{
		component.set('v.isLoading', true);
		let action = component.get('c.fetchSolutionsByGoalIds');
		action.setParams({
			'goalIds': component.get('v.riskGoalIds')
		});

		action.setCallback(this, function(response)
		{
			let state = response.getState();
			if(state === 'SUCCESS')
			{
				if(response.getReturnValue().length === 0)
				{
					this.modalController(component, false, true, false);
				}
				else
				{
					component.set('v.selectedPlannedSolution', response.getReturnValue()[0]);
					this.modalController(component, false, false, true);
				}
				component.set('v.isLoading', false);
			}
		});
		$A.enqueueAction(action);
	}
});