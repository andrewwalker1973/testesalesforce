({
    handleClick : function(component, event, helper) 
    {
        var utilityAPI = component.find("UtilityBarEx");
        utilityAPI.setUtilityHighlighted({highlighted:true});
        helper.handleClickHelper(component);
    }
})