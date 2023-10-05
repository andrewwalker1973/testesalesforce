({
    doInit : function(component, event, helper) {
        helper.fetchUserDetail(component, event, helper);	
        helper.fetchAccountAddress(component, event, helper);
    }
})