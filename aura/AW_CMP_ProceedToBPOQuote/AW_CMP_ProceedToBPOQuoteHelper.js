/**
 * Created by dpucerea on 22/11/2020.
 */

({
	navigateToCanvas: function(component, event)
	{
		component.set('v.isLoading', true);

		var action = component.get('c.fetchQuoteWithQuoteId');
		action.setParams({
			quoteId: component.get('v.recordId')
		});

		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if(state === 'SUCCESS')
			{
				var quote = response.getReturnValue();
				component.set('v.isLoading', false);

				var pageReference = {
					type: 'standard__component', attributes: {
						componentName: 'c__AW_CMP_BPOCanvasContainer'
					}, state: {
						'c__solutionid': quote.AW_Planned_Solution__c,
						'c__accountid': quote.AccountId,
						'c__quoteSolutionNumber': quote.AW_Quote_Solution_Number__c,
						'c__navigateToRecord': component.get('v.recordId')
					}
				};
				component.set('v.pageReference', pageReference);
				var navService = component.find('navService');
				component.set('v.isLoading', false);

				event.preventDefault();
				navService.navigate(pageReference);

			}
			else if(state === 'ERROR')
			{
				var errors = response.getError();
				if(errors)
				{
					if(errors[0] && errors[0].message)
					{
						console.error('Error message: ' + errors[0].message);
					}
				}
				else
				{
					console.error('Unknown error');
				}
				component.set('v.isLoading', false);
			}
		});
		$A.enqueueAction(action);
	}
});