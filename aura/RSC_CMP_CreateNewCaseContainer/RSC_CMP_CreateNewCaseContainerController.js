({
	closeQA: function(component, event, helper)
	{
		$A.get('e.force:closeQuickAction').fire();
		var utilityAPI = component.find('utilityBar');
		utilityAPI.minimizeUtility();
	}
});