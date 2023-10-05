/*
* @description Aura parent component for the Implement Servicing Quote
*
* @author pavan.t@lntinfotech.com
*
* @date June 2022
*/

({
	doInit: function(component, event, helper)
	{
		helper.getServicingContract(component, event, helper);
	}/*, openContractsModal: function(component, event, helper)
	{
		helper.modalController(component, true, false);//Added by Annu
	} */
});