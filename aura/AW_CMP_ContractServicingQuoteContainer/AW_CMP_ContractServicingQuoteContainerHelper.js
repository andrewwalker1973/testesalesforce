/*
* @description Aura parent component for the Implement Servicing Quote
* 
* @author pavan.t@lntinfotech.com
*
* @date June 2022
*/
({
	getServicingContract: function(component, event, helper)
	{
		component.set('v.accountId', component.get('v.parentRecordId'));
		let actionAccounts = component.get('c.getServicingContractWrapper');
		actionAccounts.setParams({
			'accountId': component.get('v.parentRecordId')
		});
		actionAccounts.setCallback(this, function(s)
		{
			let state = s.getState();
			if(state === 'SUCCESS')
			{
				component.set('v.selectedContractsParent', s.getReturnValue().quoteList);
				component.set('v.consultant', s.getReturnValue().code);
				helper.modalController(component, true, false);
			}
			else if(s.getState() === 'ERROR')
			{
				$A.log('Errors', s.getError());
			}
		});
		$A.enqueueAction(actionAccounts);

	}, modalController: function(component, contracts, bpo)
	{
		//Function for opening and closing modals
		component.set('v.isContractsOpen', contracts);
		component.set('v.isBpoOpenChild', bpo);
	}
});