/*
* @description Used for create the service Quote record for WIQ
*
* @author kiran.yelisetti@liberty.co.za
*
* @date August 2021.
*/
//noinspection JSUnresolvedVariable
({
	fetchFinancialAccounts: function(component)
	{
		let actionGetLabels = component.get('c.getLabels');

		actionGetLabels.setParams({
			'sObjectType': 'FinServ__FinancialAccount__c'
		});

		actionGetLabels.setCallback(this, function(c)
		{
			let stateGetLabels = c.getState();
			if(stateGetLabels === 'SUCCESS')
			{
				component.set('v.contractsLabels', c.getReturnValue());
				//let result = c.getReturnValue();
				let cols = [//                    Get Label From Fields
					{label: 'Product Category', fieldName: 'productCategory', type: 'text'},
					{label: 'Product Type', fieldName: 'financialAccountNumber', type: 'text'},
					{label: 'Policy Number', fieldName: 'name', type: 'text'},
					{label: 'Total Premium Amount', fieldName: 'premiumAmount', type: 'decimal'}
				];

				component.set('v.contractsColumns', cols);
			}
			else if(stateGetLabels === 'ERROR')
			{
				$A.log('Errors', c.getError());
			}
		});
		$A.enqueueAction(actionGetLabels);
		let actionFetchFinancialAccounts = component.get('c.getServicingContractWrapper');

		actionFetchFinancialAccounts.setParams({
			'accountId': component.get('v.accountId')
		});

		actionFetchFinancialAccounts.setCallback(this, function(a)
		{

			let state = a.getState();
			if(state === 'SUCCESS')
			{

				//noinspection JSUnresolvedVariable
				component.set('v.contractsData', a.getReturnValue().quoteList);

				// If we have data in the table, show the table, if not, show a message
				if(component.get('v.contractsData').length === 0)
				{
					component.set('v.isFinancialAccountEmpty', true);
				}
				else
				{
					component.set('v.isFinancialAccountEmpty', false);
					component.set('v.consultant', a.getReturnValue().code);
					let consultant = component.get('v.consultant');
					let consultantCode = consultant.consultantCode;
					let userId = consultant.userId;
					component.set('v.userId', userId);
					component.set('v.consultantCode', consultantCode);
				}
				component.set('v.isLoading', false);
			}
			else if(state === 'ERROR')
			{
				$A.log('Errors', a.getError());
			}

		});
		$A.enqueueAction(actionFetchFinancialAccounts);

	}, navigateToNewQuote: function(component, event)
	{
		let contract = component.get('v.selectedContract');
		let accountId = component.get('v.accountId');
		let opportunityId = component.get('v.opportunityId');
		let quoteSolutionNumber = null;
		let consultant = component.get('v.consultant');
		let userId = consultant.userId;
		let consultantCode = consultant.consultantCode;
		let pageReference = {
			type: 'standard__component', attributes: {
				componentName: 'c__AW_CMP_BPOContractCanvasContainer'
			}, state: {
				'c__contractNumber': contract.name,
				'c__consultantCode': consultantCode,
				'c__userId': userId,
				'c__accountId': accountId,
				'c__opportunityId': opportunityId,
				'c__quoteSolutionNumber': quoteSolutionNumber
			}
		};
		component.set('v.pageReference', pageReference);
		let navService = component.find('navService');
		let pageReferenceNew = component.get('v.pageReference');
		event.preventDefault();
		navService.navigate(pageReferenceNew);
	}, modalController: function(component, contracts, bpo, createNewQuote)
	{
		// Function for opening and closing modals
		component.set('v.isContractsOpenChild', contracts);
		component.set('v.isBpoOpenChild', bpo);//Added by Annu
		component.set('v.isServicingQuoteContainerOpenGrandChild', !!createNewQuote);

	}
});