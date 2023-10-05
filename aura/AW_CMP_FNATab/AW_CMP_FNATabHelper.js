({
	doInitHelper : function(component) {
//	      Setting the action for Callback
        var action = component.get("c.getAvalonBaseUrl");
//        Setting the parameter for the action
        action.setParams(
            {
                recordId : null
            });

        action.setCallback(this, function(response){
            var state = response.getState();
//            Checking the state of the Callback
            if(state == 'SUCCESS') {
                var avalonHomeURL = response.getReturnValue();
                window.open(avalonHomeURL, 'avalonHomeTab');
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $Label.c.AW_Error,
                    "message": $Label.c.AW_Error_Message,
                    "type": 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
})