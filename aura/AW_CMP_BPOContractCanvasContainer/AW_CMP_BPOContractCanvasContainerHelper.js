/*
* @description Used for redirecting to and Integrating BPO WIQ Canvas App inside Salesforce and create the Quote record
*
 @author  annu.agarwal@lntinfotech.com, a.shrikrishna.pethe@accenture.com
*
*@date June 2022
*/
//noinspection JSUnresolvedVariable
({
	modalController: function(component, contracts, bpo, servicingContainer)
	{
		// Function for opening and closing modals
		component.set('v.isContractsOpenChild', contracts);
		component.set('v.isBpoOpenChild', bpo);
		component.set('v.isServicingQuoteContainerOpenGrandChild', servicingContainer);
	},

	fetchValues: function(component)
	{
		let contractNumber = component.get('v.selectedContract');
		component.set('v.contractNumber', contractNumber.name);

		let consultantCode = component.get('v.consultantCode');

		let userId = component.get('v.userId');

		let quoteSolutionNumber = component.get('v.selectedQuote');
		component.set('v.quoteSolutionNumber', quoteSolutionNumber);
		let json = '{"contractNumber": "' + contractNumber.name + '", "consultantCode": "' + consultantCode + '", "quoteSolutionNumber": "'
				+ quoteSolutionNumber + '", "userId": "' + userId + '"}';
		// Base64 encode the json object
		let encodedJson = btoa(json);
		let parameters = '{"fromSF": "' + true + '", "signed_request": "' + encodedJson + '"}';

		//let decodedJson = atob(encodedJson);
		component.set('v.parameters', parameters);
	},

	onSubParentLoad: function(component)
	{
		window.addEventListener('message', function(event)
		{
			let data = JSON.parse(event.data);
			if(data.targetModule === 'Canvas' && data.body && data.body.event && data.body.event.name === 'upSetQuoteInfo')
			{

				let opportunityId = component.get('v.opportunityId');
				let selectedContract = component.get('v.selectedContract');
				let createQuoteWithExternalId = component.get('c.createQuoteWithExternalIdForContract');
				createQuoteWithExternalId.setParams({
					'quoteNumberInExternalSystem': data.body.event.payload.param2,
					'quotePDFName': data.body.event.payload.param1,
					'changeType': JSON.stringify(data.body.event.payload.param3),
					'lifeAssured': JSON.stringify(data.body.event.payload.param4),
					'opportunityId': opportunityId,
					'contractNumber': selectedContract.name,
					'financialEntity': selectedContract.financialEntity,
					'productCategory': selectedContract.productCategory,
					'financialEntityName': selectedContract.financialAccountNumber
				});

				createQuoteWithExternalId.setCallback(this, function(response)
				{
					let state = response.getState();
					if(!component.isValid() || state !== 'SUCCESS')
					{
						let toastEvent = $A.get('e.force:showToast');
						toastEvent.setParams({
							'title': $Label.c.AW_Error, 'message': $Label.c.AW_Error_Message, 'type': 'error'
						});
						toastEvent.fire();
					}
					if(state === 'success' || state === 'SUCCESS')
					{
						alert('success');
					}
				});
				$A.enqueueAction(createQuoteWithExternalId);

			}

		}, false);

	}

});