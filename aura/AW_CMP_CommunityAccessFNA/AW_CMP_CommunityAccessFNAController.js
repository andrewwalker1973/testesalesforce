({
    navigate  : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'https://www.atwork.co.za/login'
        });
        urlEvent.fire();
    }
})