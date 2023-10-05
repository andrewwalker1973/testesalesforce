({
	onPageReferenceChange: function(component, event, helper)
	{
		//to display the spinner
		helper.showSpinner(component, event, helper);
		//setting parameters to get the fnaID
		var myPageRef = component.get('v.pageReference');
		var fnaId = myPageRef.state.c__fnaid;
		component.set('v.fnaId', fnaId);
		/**
		 * Description : Script on helper, fnaid from the pagerefernce and makes a server call and get the account id back.
		 * method name i.e. getAccountId should be same as defined in apex class
		 * params name i.e. fnaID should be same as defined in getAccountId method
		 **/
		var actionGetAccountId = component.get('c.getAccountId');
		actionGetAccountId.setParams({'fnaId': fnaId});
		actionGetAccountId.setCallback(this, function(response)
		{
			var state = response.getState(); // get the response state
			if(component.isValid() && state == 'SUCCESS' && response.getReturnValue() != null)
			{
				//to hide spinner
				helper.hideSpinner(component, event, helper);
				/**
				 * Description : When this event is received, Salesforce will redirect the user to the account linked to the
				 * chosen FNA.
				 **/
				var navEvt = $A.get('e.force:navigateToSObject');
				navEvt.setParams({
					'recordId': response.getReturnValue()
				});
				navEvt.fire();

			}
			else
			{
				/**
				 * Description : If the response state is not success and returnvalue is null.This event will
				 * redirect the user to the account home page
				 *
				 **/
				var homeEvent = $A.get('e.force:navigateToObjectHome');
				homeEvent.setParams({
					'scope': 'Account'
				});
				homeEvent.fire();
				//to hide spinner
				helper.hideSpinner(component, event, helper);
				//handling errors with toast message in general.
				var toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({
					'title': $Label.c.AW_Error,
					'message': $Label.c.AW_Error_Message,
					'type': 'error'
				});
				toastEvent.fire();
			}
		});
		$A.enqueueAction(actionGetAccountId);
	},

	/**
	 * Description : Dispalys the animated spinner image when the link processess starts.
	 **/
	showSpinner: function(component, event, helper)
	{
		var spinner = component.find('mySpinner');
		$A.util.removeClass(spinner, 'slds-hide');
	},

	/**
	 * Description : Hides the animated spinner image when the link processess ends.
	 **/
	hideSpinner: function(component, event, helper)
	{
		var spinner = component.find('mySpinner');
		$A.util.addClass(spinner, 'slds-hide');
	}

});