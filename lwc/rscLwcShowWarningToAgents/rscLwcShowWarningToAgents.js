/**
 * @description Lightning web component to show warning if the logged-in agent is not owner of the case.
 *
 * @author kushal.a.garg@accenture.com
 *
 * @date May 2022
 */
import { LightningElement, wire, api } from 'lwc';
import userId from '@salesforce/user/Id';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import OWNER_ID from '@salesforce/schema/Case.OwnerId';
import warningMessage from '@salesforce/label/c.RSC_ShowWarningToServicingAgents';

export default class RscLwcShowWarningToAgents extends LightningElement
{
	@api recordId;
	ownerId;
	showNotification = false;
	message = warningMessage;

	/**
	 * @description function to get details of case record.
	 */
	@wire (getRecord,{recordId: '$recordId' , fields:[OWNER_ID]}) wiredCase({error,data})
	{
		if(data)
		{
			this.ownerId = this.ownerId || getFieldValue(data, OWNER_ID);
			this.handleNotification();
		}
		else if(error)
		{
			this.showErrorToast(error.body.message);
		}
	}

	/**
	 * @description function to show notification if the logged-in user is not owner of the case.
	 */
	handleNotification()
	{
		if(this.ownerId !== userId)
		{
			this.showNotification = true;
		}
	}

}