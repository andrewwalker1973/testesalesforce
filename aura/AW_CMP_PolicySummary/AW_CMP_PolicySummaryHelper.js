({
    getContractNumber : function(component){
        var recordId = component.get('v.recordId');
        var sObjectType = component.get('v.sObjectType');
        
        /**
         * Description : Script on helper, recordID from the Record and makes a server call and get the return response back.
         * method name i.e. getPolicySummary should be same as defined in apex class
         * params name i.e. recordId should be same as defined in fetchcontractnumber method 
        **/   
        var action = component.get('c.getPolicySummary');
        action.setParams({
            "recordId" : component.get("v.recordId"),
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state === 'SUCCESS') {
                var result = a.getReturnValue()["fileByteStream"];
                var contractNumber = a.getReturnValue()["contractNumbers"];

                if(result != null){ 
                    //convert base64 into pdf file..
                    var url = 'data:application/pdf;base64,' + result;
                    var anc = document.getElementById('anchorTag');// for file name and dynamic url pass                   
                    var filename = `${(contractNumber).replace(/[^a-zA-Z0-9À-ú ]/g, "")}_Policy Summary_${new Date().toISOString().split('T')[0]}`;
                    
                    anc.href = url;
                    anc.download = filename;
                    anc.click();
                    this.showSuccessToast(component, event, helper);
                }
                else {
                    this.showErrorToast(component, event, helper);
                }
                // Close the action panel
                $A.get("e.force:closeQuickAction").fire();
            }
            if(state === 'ERROR') {
                this.showErrorToast(component, event, helper);
                // Close the action panel
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },   
    
    //success toast message for download success
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": 'success',
            "message": "The Policy summary has been downloaded successfully."
        });
        toastEvent.fire();
    },
    
    //Error toast message for download failed
    showErrorToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "type": 'error',
            "message": "Something went wrong. Kindly contact System administrator."
        });
        toastEvent.fire();
    }
})