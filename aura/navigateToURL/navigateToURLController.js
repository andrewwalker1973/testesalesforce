({
	goToURL : function (component, event, helper) {
    var urlEvent = $A.get("e.force:navigateToURL");
    var url = component.get("v.urlToNavigate");
    urlEvent.setParams({
      "url": url
    });
    urlEvent.fire();
}})