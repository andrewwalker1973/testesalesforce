/*
 *@description  Aura component for the Implement Goal Planned Solution Modal.
 * 
 *@author dpucerea ,nihal.desai@accenture.com 
 *
 *@date June, 2022
 */

({
	doInit: function(component, event, helper)
	{
		helper.fetchPlannedSolutions(component, event);
	}, handleRowActionSolution: function(component, event)
	{
		let selectedRows = event.getParam('selectedRows');
		component.set('v.selectedPlannedSolution', selectedRows[0]);
		component.set('v.isContinueDisabled', false);
	}, openGoalModal: function(component, event, helper)
	{
		helper.modalController(component, false, false, true);
	}, previousModal: function(component, event, helper)
	{
		helper.modalController(component, true, false, false);
	}, closeModal: function(component, event, helper)
	{
		helper.modalController(component, false, false, false);
	}
});