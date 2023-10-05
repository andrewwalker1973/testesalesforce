/*
* @description Used for create the service Quote record for WIQ
*
* @author kiran.yelisetti@liberty.co.za
*
* @date August 2021.
*/
({
	doInit: function(component, event, helper)
	{
		helper.fetchFinancialAccounts(component);
	}, handleRowActionContracts: function(component, event)
	{
		let selectedRows = event.getParam('selectedRows');
		component.set('v.selectedContract', selectedRows[0]);
		component.set('v.isContinueDisabled', false);
	}, closeModal: function(component, event, helper)
	{
		helper.modalController(component, false, false, false);
	}, createNewQuote: function(component, event, helper)
	{
		helper.modalController(component, false, true, true);
	}
});