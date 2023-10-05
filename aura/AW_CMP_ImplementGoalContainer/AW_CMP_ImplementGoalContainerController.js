/*
* @description Aura parent component for the Implement Goal functionality, also contains the link/unlink contracts LWC
*
* @author safwan.h.mohammed@accenture.com k.marakalala@accenture.com
*
* @date November 2020, April 2023
*/
({
	doInit: function(component, event, helper)
	{
		helper.checkSObject(component);
	}, openGoalModal: function(component, event, helper)
	{
		// If we start from the account, opportunity show the Financial Goal selection
		if(component.get('v.isAccountObject') === true || component.get('v.isOpportunityObject') === true)
		{
			let buttonName = event.getSource().getLocalId();
			component.set('v.goalButtonName', buttonName);
			helper.modalController(component, true, false, false);
		}
		else // If we start from Financial Goal records and goalType is risk then show Quote screen otherwise show the Planned Solution selection
		{
			component.get('v.isRiskGoal') ? helper.getPlannedSolution(component) : helper.modalController(component, false, true, false);
		}
	}, openServicingContainer: function(component)
	{
		component.set('v.isServicingQuoteContainerOpen', true);
	}, servicingQuoteButtonVisibility: function(component)
	{
		let accountFinServStatusNullCheck = (component.get('v.accountRecord')) ? component.get('v.accountRecord').FinServ__Status__c : null;
		let accountFinServStatusValue = (component.get('v.accountRecord')) ? component.get('v.accountRecord').FinServ__Status__c : '';
		let oppFinServStatusNullCheck = (component.get('v.opportunityRecord')) ? component.get('v.opportunityRecord').FinServ__Status__c : null;
		let oppFinServStatusValue = (component.get('v.opportunityRecord')) ? component.get('v.opportunityRecord').FinServ__Status__c : '';

		let accountObj = (component.get('v.sObjectType') === 'Account' && accountFinServStatusNullCheck != null && accountFinServStatusValue === 'Active');
		let oppObj = (component.get('v.sObjectType') === 'Opportunity' && oppFinServStatusNullCheck != null && oppFinServStatusValue === 'Active');

		if(accountObj || oppObj)
		{

			component.set('v.isServicingQuoteButtonVisible', true);
		}
		else
		{
			component.set('v.isServicingQuoteButtonVisible', false);
		}
	}, financialGoalButtonVisibility: function(component)
	{
		if(component.get('v.isFinancialGoalObject'))
		{
			let goalType = component.get('v.financialGoalRecord').AW_Goal_Type__c;
			if(goalType === 'Investment')
			{
				component.set('v.isImplementGoalButtonVisible', true);
			}
			else if(goalType === 'Risk')
			{
				component.set('v.isRiskGoalButtonVisible', true);
			}
		}
	}

});