/*
* @description Used for redirecting to and Integrating BPO WIQ Canvas App inside Salesforce and create the Quote record
*
* @author a.shrikrishna.pethe@accenture.com  pavan.t@lntinfotech.com
*
* @date June 2022 November 2022
*/
({
	onPageReferenceChange: function(component, event, helper)
	{
		helper.fetchValues(component);
	}, reInit: function()
	{
		$A.get('e.force:refreshView').fire();
	}, closeModal: function(component, event, helper)
	{
		helper.modalController(component, false, false, false);
	}, onSubParentLoaded: function(component, event, helper)
	{
		helper.onSubParentLoad(component);
	}
});