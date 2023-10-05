({
    doInit : function(component, event, helper) 
    {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/page/home"
        });
        urlEvent.fire
        helper.doInitHelper(component);
    },
    reInit: function(component, event, helper) 
    {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/page/home"
        });
        urlEvent.fire();
        helper.doInitHelper(component);
    }
})