/*
 * @description Used for redirecting to and Integrating BPO  Canvas App inside Salesforce 
 *
 * @author annu.agarwal@lntinfotech.com, a.shrikrishna.pethe@accenture.com
 *
 * @date June 2022
*/
//noinspection BadExpressionStatementJS

// eslint-disable-next-line no-unused-expressions
({
	onPageReferenceChange: function(component, event, helper)
	{
		helper.onPageReferenceChange(component, event);
	}, reInit: function()
	{
		// eslint-disable-next-line no-undef
		$A.get('e.force:refreshView').fire();
	}
});