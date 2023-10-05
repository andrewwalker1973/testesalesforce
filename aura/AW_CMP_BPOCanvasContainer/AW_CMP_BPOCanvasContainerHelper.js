/*
 * @description Used for redirecting to and Integrating BPO  Canvas App inside Salesforce 
 *
 * @author annu.agarwal@lntinfotech.com, a.shrikrishna.pethe@accenture.com
 *
 * @date June 2022
*/
/* eslint-disable no-undef */
//noinspection JSUnresolvedVariable,BadExpressionStatementJS,JSAnnotator

// eslint-disable-next-line no-unused-expressions
({
	onPageReferenceChange: function(component)
	{
		//setting parameters to get the solution and quote id in the canvas
		let myPageRef = component.get('v.pageReference');

		let plannedSolutionId = myPageRef.state.c__solutionid;

		component.set('v.plannedSolutionId', plannedSolutionId);

		let accountId = myPageRef.state.c__accountid;

		component.set('v.accountId', accountId);

		let quoteSolutionNumber = myPageRef.state.c__quoteSolutionNumber;

		component.set('v.quoteSolutionNumber', quoteSolutionNumber);

		let navigateToRecord = myPageRef.state.c__navigateToRecord;

		component.set('v.navigateToRecord', navigateToRecord);

		// NOTE: Lightning is very picky about quotes.
		// JSON keys and values MUST be wrapped with double quotes.
		let json = '{"plannedSolutionId": "' + plannedSolutionId + '", "quoteSolutionNumber": "' + quoteSolutionNumber + '"}';
		component.set('v.parameters', json);

		/**
		 * Description : When this event is received, Salesforce will save a quote and populate the ‘quote number’ field
		 * with the value of param and link the quote with the correct related record.
		 *
		 **/
		// eslint-disable-next-line no-undef
		Sfdc.canvas.parent.subscribe({
			name: 'upsertQuoteInfo', onData: function(event)
			{
				component.set('v.quoteNumber', event.param2);
			}
		});

		/**
		 * Description : When this event is received, Salesforce will redirect the user to the account linked to the
		 * chosen planned solution.
		 *
		 **/
		// eslint-disable-next-line no-undef
		Sfdc.canvas.parent.subscribe({
			name: 'finish', onData: function()
			{
				let navEvt = $A.get('e.force:navigateToSObject');
				navEvt.setParams({
					'recordId': navigateToRecord
				});
				navEvt.fire();
				//US-301890 When BackToGoals button is clicked in BPO, make an API call to BPO to fetch the current quote details synchronously
				component.set('v.isLoading', true);
				let createQuoteWithExternalId = component.get('c.createQuoteWithExternalId');
				createQuoteWithExternalId.setParams({
					'quoteNumberInExternalSystem': component.get('v.quoteNumber'),
					'accountId': component.get('v.accountId'),
					'solutionId': component.get('v.plannedSolutionId')
				});

				createQuoteWithExternalId.setCallback(this, function(response)
				{
					component.set('v.isLoading', false);
					let state = response.getState();
					if(!component.isValid() || state !== 'SUCCESS')
					{
						// eslint-disable-next-line no-undef
						let toastEvent = $A.get('e.force:showToast');
						toastEvent.setParams({
							'title': $Label.c.AW_Error, 'message': $Label.c.AW_Error_Message, 'type': 'error'
						});
						toastEvent.fire();
					}

				});
				$A.enqueueAction(createQuoteWithExternalId);
			}
		});
	}
});