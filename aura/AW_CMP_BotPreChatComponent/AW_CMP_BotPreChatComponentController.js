({
doInit: function(component, event, helper) {
        var action = component.get("c.getCurrentUser");
        action.setCallback(this, function(response) {
            console.log(response);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result, embedded_svc);
                component.set('v.username', result.Username);
                if(result.Username){
                    component.set('v.firstName', result.FirstName);
                    component.set('v.lastName', result.LastName);
                    component.set('v.email', result.Email);
                    helper.startChat(component, event, helper);
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    onStartButtonClick: function(component, event, helper) {
        //handling errors
        if(!component.get('v.firstName')
          || !component.get('v.lastName')
           || !component.get('v.email')) return alert('Missing fields.');
        helper.startChat(component, event, helper);
    }
});