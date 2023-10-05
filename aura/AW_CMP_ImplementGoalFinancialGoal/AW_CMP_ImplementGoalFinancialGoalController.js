/*
* @description Aura parent component for the Implement Financial Goal Modal.
*
* @author nihal.desai@accenture.com vishakha.saini@accenture.com pavan.t@lntinfotech.com
*
* @date November 2020, February 2022, May 2022 , June 2022
*/

({
	doInit: function(component, event, helper)
	{
		helper.fetchFinancialGoals(component, event);
	}, handleRowActionGoal: function(component, event)
	{
		let selectedRows = event.getParam('selectedRows');
		component.set('v.selectedFinancialGoal', selectedRows[0]);
		component.set('v.isContinueDisabled', false);

		if(selectedRows[0].AW_Goal_Type__c === 'Risk')
		{
			component.set('v.isRiskGoal', true);
		}
		else
		{
			component.set('v.isRiskGoal', false);
		}
	}, openGoalModal: function(component, event, helper)
	{
		//if goal type risk then set modal to open quote screen directly if planned solution is linked to risk goal
		component.get('v.isRiskGoal') ? helper.getPlannedSolution(component) : helper.modalController(component, false, true, false);
	}, closeModal: function(component, event, helper)
	{
		helper.modalController(component, false, false, false);
	}
});