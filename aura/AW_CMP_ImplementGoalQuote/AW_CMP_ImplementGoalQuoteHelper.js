/*
* @description Aura parent component for the Implement Quote Modal.
*
* @author nihal.desai@accenture.com vishakha.saini@accenture.com
*
* @date November 2020, February 2022, May 2022
*/

({
	fetchQuotes: function(component)
	{
		if(component.get('v.sObjectTypeChild') === 'FinServ__FinancialGoal__c' && component.get('v.isRiskGoal'))
		{
			component.set('v.isFromRiskGoal', true);
		}
		let actionGetLabels = component.get('c.getLabels');

		actionGetLabels.setParams({
			'apiName': 'Quote'
		});

		actionGetLabels.setCallback(this, function(c)
		{
			let stateGetLabels = c.getState();
			if(stateGetLabels === 'SUCCESS')
			{
				component.set('v.quoteLabels', c.getReturnValue());
				let result = c.getReturnValue();

				let cols = [//                    Get Label From Fields
					{label: result['aw_quote_solution_number__c'], fieldName: 'AW_Quote_Solution_Number__c', type: 'text'},
					{label: result['aw_product_category__c'], fieldName: 'AW_Product_Category__c', type: 'text'},
					{label: result['aw_product_type__c'], fieldName: 'AW_Product_Type__c', type: 'text'},
					{label: result['aw_total_investment_amount__c'], fieldName: 'AW_Total_Investment_Amount__c', type: 'text'},
					{label: result['aw_total_premium_amount__c'], fieldName: 'AW_Total_Premium_Amount__c', type: 'text'},
					{label: result['status'], fieldName: 'Status', type: 'text'},
					{label: result['aw_quote_date__c'], fieldName: 'AW_Quote_Date__c', type: 'text'}
				];

				component.set('v.quoteColumns', cols);
			}
		});
		$A.enqueueAction(actionGetLabels);
		this.getQuotes(component);
	}, navigateToCanvas: function(component, event)
	{
		let solution = component.get('v.selectedPlannedSolution');
		let accountId = component.get('v.parentAccountId');
		let quoteSolutionNumber = component.get('v.selectedQuote');

		let pageReference = {
			type: 'standard__component', attributes: {
				componentName: 'c__AW_CMP_BPOCanvasContainer'
			}, state: {
				'c__solutionid': solution.Id,
				'c__accountid': accountId,
				'c__quoteSolutionNumber': quoteSolutionNumber,
				'c__navigateToRecord': component.get('v.navigateToRecordId')
			}
		};
		component.set('v.pageReference', pageReference);
		let navService = component.find('navService');
		event.preventDefault();
		navService.navigate(pageReference);
	}, navigateToNewQuote: function(component, event)
	{
		let solution = component.get('v.selectedPlannedSolution');
		let accountId = component.get('v.parentAccountId');
		let quoteSolutionNumber = null;

		let pageReference = {
			type: 'standard__component', attributes: {
				componentName: 'c__AW_CMP_BPOCanvasContainer'
			}, state: {
				'c__solutionid': solution.Id,
				'c__accountid': accountId,
				'c__quoteSolutionNumber': quoteSolutionNumber,
				'c__navigateToRecord': component.get('v.navigateToRecordId')
			}
		};
		component.set('v.pageReference', pageReference);
		let navService = component.find('navService');
		event.preventDefault();
		navService.navigate(pageReference);
	}, modalController: function(component, financialGoal, plannedSolution, quote)
	{
		//Function for opening and closing modals
		component.set('v.isFinancialGoalOpenChild', financialGoal);
		component.set('v.isPlannedSolutionOpenChild', plannedSolution);
		component.set('v.isQuoteOpenChild', quote);
	}, /**
	 * @description Method to get Quote record
	 */
	getQuotes: function(component)
	{
		let action;
		if(component.get('v.isRiskGoal'))
		{
			action = component.get('c.fetchQuotesWithAccountId');
			action.setParams({
				'accountId': component.get('v.parentAccountId')
			});
		}
		else
		{
			action = component.get('c.fetchQuotesWithSolutionId');
			action.setParams({
				'solutionId': component.get('v.selectedPlannedSolution').Id
			});
		}
		action.setCallback(this, function(response)
		{
			let state = response.getState();
			if(state === 'SUCCESS')
			{
				if(component.get('v.isRiskGoal'))
				{
					let quoteRelatedToRiskGoal = [];
					let quoteData = response.getReturnValue();
					for(let i = 0; i < quoteData.length; i++)
					{
						if(quoteData[i].AW_Product_Category__c === 'Risk')
						{
							quoteRelatedToRiskGoal.push(quoteData[i]);
						}
					}
					component.set('v.quoteData', quoteRelatedToRiskGoal);
				}
				else
				{
					component.set('v.quoteData', response.getReturnValue());
				}

				//If we have data in the table, show the table, if not, show a message
				if(component.get('v.quoteData').length === 0)
				{
					component.set('v.isQuoteEmpty', true);
				}
				else
				{
					component.set('v.isQuoteEmpty', false);
				}
				component.set('v.isLoading', false);
			}
		});

		$A.enqueueAction(action);
	}
});