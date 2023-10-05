/*
* @description Aura parent component for the Implement Goal functionality, also contains the link/unlink contracts LWC
*
* @author safwan.h.mohammed@accenture.com k.marakalala@accenture.com
*
* @date November 2020, April 2023
*/
({
	checkSObject: function(component)
	{
		component.set('v.recordId', component.get('v.recordId'));
		component.set('v.objectRecordId', component.get('v.recordId'));
		let sObject = component.get('v.sObjectType');
		/** Check the sObject type and set isAccountObject variable to true if it's an account
		 * If it's an account object, skip the AW_CMP_ImplementGoalFinancialGoal component
		 */
		if(sObject === 'Account')
		{
			component.set('v.isAccountObject', true);
			component.set('v.isServicingQuoteButtonVisible', true);
			component.set('v.isImplementGoalButtonVisible', true);
			component.set('v.isRiskGoalButtonVisible', true);
		}
		else if(sObject === 'Opportunity')
		{
			component.set('v.isOpportunityObject', true);
			component.set('v.isAccountObject', false);
			component.set('v.recordId', component.get('v.recordId'));
			component.set('v.isServicingQuoteButtonVisible', true);
			component.set('v.isImplementGoalButtonVisible', true);
			component.set('v.isRiskGoalButtonVisible', true);
			component.set('v.opportunityId', component.get('v.recordId'));
			let action = component.get('c.fetchAccountByOpportunityId');
			action.setParams({
				'opportunityID': component.get('v.recordId')
			});
			action.setCallback(this, function(a)
			{
				let state = a.getState();
				if(state === 'SUCCESS')
				{
					component.set('v.recordId', a.getReturnValue());
				}
			});
			$A.enqueueAction(action);
		}
		else if(sObject === 'FinServ__FinancialGoal__c')
		{
			component.set('v.isAccountObject', false);
			component.set('v.isOpportunityObject', false);
			component.set('v.isFinancialGoalObject', true);
			let action = component.get('c.fetchGoalsWithGoalId');
			action.setParams({
				'financialGoalID': component.get('v.recordId')
			});
			action.setCallback(this, function(a)
			{
				let state = a.getState();
				if(state === 'SUCCESS')
				{
					component.set('v.selectedFinancialGoalParent', a.getReturnValue()[0]);
					component.set('v.accountId', a.getReturnValue()[0].FinServ__PrimaryOwner__c);
					component.set('v.recordId', component.get('v.accountId'));
					if(a.getReturnValue()[0].AW_Goal_Type__c === 'Risk')
					{
						component.set('v.isRiskGoal', true);
					}
					else
					{
						component.set('v.isRiskGoal', false);
					}
				}
			});
			$A.enqueueAction(action);
		}
	}, modalController: function(component, financialGoal, plannedSolution, quote)
	{
		//        Function for opening and closing modals
		component.set('v.isFinancialGoalOpen', financialGoal);
		component.set('v.isPlannedSolutionOpen', plannedSolution);
		component.set('v.isQuoteOpen', quote);
	}, /**
	 * @description Method to fetch planned solution
	 */
	getPlannedSolution: function(component)
	{
		component.set('v.isLoading', true);
		let action = component.get('c.fetchSolutions');
		action.setParams({
			'goalId': component.get('v.recordId')
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
					component.set('v.selectedPlannedSolutionParent', response.getReturnValue()[0]);
					component.set('v.recordId', component.get('v.accountId'));
					this.modalController(component, false, false, true);
				}
			}
		});
		$A.enqueueAction(action);
	}
});