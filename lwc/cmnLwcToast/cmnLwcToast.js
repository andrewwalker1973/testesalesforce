import {LightningElement, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

/**
 * @description Common LWC to display custom Toast Events
 * @author darrion.james.singh@accenture.com
 * @date May 2022
 */
export default class CmnLwcToast extends LightningElement
{

	@api
	successNotification()
	{
		const evt = new ShowToastEvent({
			title: 'Success',
			message: 'Your details has been updated successfully',
			variant: 'success'
		});
		this.dispatchEvent(evt);
	}

	@api
	requiredFieldsNotification()
	{
		const evt = new ShowToastEvent({
			title: 'Required Fields',
			message: 'Please complete ALL the required fields.',
			variant: 'error'
		});
		this.dispatchEvent(evt);
	}

	@api
	customNotification(title, message, variant)
	{
		const evt = new ShowToastEvent({
			title,
			message,
			variant
		});
		this.dispatchEvent(evt);
	}

}