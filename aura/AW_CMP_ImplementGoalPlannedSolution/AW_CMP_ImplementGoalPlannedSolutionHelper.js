/*
 *@description  Aura component for the Implement Goal Planned Solution Modal.
 * 
 *@author dpucerea ,nihal.desai@accenture.com
 *
 *@date June, 2022
*/

({
	fetchPlannedSolutions: function(component)
	{
		if(component.get('v.sObjectTypeChild') === 'Account' || component.get('v.sObjectTypeChild') === 'Opportunity')
		{
			component.set('v.isFromAccountOrOpportunity', true);
		}

		let actionGetLabels = component.get('c.getLabels');

		actionGetLabels.setParams({
			'apiName': 'AW_Planned_Solution__c'
		});

		actionGetLabels.setCallback(this, function(c)
		{
			let stateGetLabels = c.getState();
			if(stateGetLabels === 'SUCCESS')
			{
				component.set('v.plannedSolutionLabels', c.getReturnValue());
				let result = c.getReturnValue();

				let colsInvestment = [//                    Get Label From Fields
					{label: result['name'], fieldName: 'Name', type: 'text'},
					{label: result['aw_growth_strategy__c'], fieldName: 'AW_Growth_Strategy__c', type: 'text'},
					{label: result['aw_product_name__c'], fieldName: 'AW_Product_Name__c', type: 'text'},
					{label: result['aw_target_return__c'], fieldName: 'AW_Target_Return__c', type: 'text'}
				];

				component.set('v.plannedSolutionColumns', colsInvestment);
			}
		});
		$A.enqueueAction(actionGetLabels);

		let action = component.get('c.fetchSolutions');
		let selectedObj = component.get('v.selectedFinancialGoal');

		action.setParams({
			'goalId': selectedObj.Id
		});

		action.setCallback(this, function(a)
		{
			let state = a.getState();
			if(state === 'SUCCESS')
			{
				component.set('v.plannedSolutionGoalData', a.getReturnValue());

				//                If we have data in the table, show the table, if not, show a message
				//noinspection NegatedIfStatementJS
				if(component.get('v.plannedSolutionGoalData').length !== 0)
				{
					component.set('v.isPlannedSolutionEmpty', false);
				}
				else
				{
					component.set('v.isPlannedSolutionEmpty', true);
				}
				component.set('v.isLoading', false);

			}
		});
		$A.enqueueAction(action);
	}, modalController: function(component, financialGoal, plannedSolution, quote)
	{
		//        Function for opening and closing modals
		component.set('v.isFinancialGoalOpenChild', financialGoal);
		component.set('v.isPlannedSolutionOpenChild', plannedSolution);
		component.set('v.isQuoteOpenChild', quote);
	}
});