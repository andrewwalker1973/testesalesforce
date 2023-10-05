({
	doInit : function(component, event, helper) {
		var action = component.get("c.fetchOutcome");
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('recordId: '+response.getReturnValue());
                component.set("v.recordId", response.getReturnValue());
                console.log('Success');
            }
            else {
                console.log(response.getError());
            }
        }
        ));
        $A.enqueueAction(action);
	}
})