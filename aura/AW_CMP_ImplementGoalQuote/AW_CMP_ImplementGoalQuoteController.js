/*
* @description Aura parent component for the Implement Quote Modal.
*
* @author nihal.desai@accenture.com vishakha.saini@accenture.com
*
* @date November 2020, February 2022, May 2022
*/

({
	doInit: function(component, event, helper)
	{
		helper.fetchQuotes(component, event);
	}, handleRowActionQuote: function(component, event)
	{
		let selectedRows = event.getParam('selectedRows');
		component.set('v.selectedQuote', selectedRows[0].AW_Quote_Solution_Number__c);
		component.set('v.isContinueDisabled', false);
	}, continueAction: function(component, event, helper)
	{
		helper.navigateToCanvas(component, event);
	}, createNewQuote: function(component, event, helper)
	{
		helper.navigateToNewQuote(component, event);
	}, openGoalModal: function(component, event, helper)
	{
		helper.modalController(component, false, false, false);
	}, previousModal: function(component, event, helper)
	{ //if riskGoal flag true then open goal screen
		component.get('v.isRiskGoal') ? helper.modalController(component, true, false, false) : helper.modalController(component, false, true, false);
	}, closeModal: function(component, event, helper)
	{
		helper.modalController(component, false, false, false);
	}
});