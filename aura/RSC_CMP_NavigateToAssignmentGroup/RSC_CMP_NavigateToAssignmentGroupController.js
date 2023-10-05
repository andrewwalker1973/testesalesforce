({ invoke : function(component, event, helper) {
var record = component.get("v.recordId");
var baseURL = "/apex/ortoo_qra__AssignmentGroup?id="+ record + "&mo";
var urlEvent = $A.get("e.force:navigateToURL");
urlEvent.setParams({
"url": baseURL,
"isredirect": "true"
});
urlEvent.fire();
}})