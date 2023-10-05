import {FlowNavigationBackEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import {api, LightningElement} from 'lwc';

/**
 * @description Tax flow footer to control flow/lwc navigation.
 * @story - 147578
 * @author darrion.james.singh@accenture.com
 * @date May 2022
 */
export default class RscLwcTaxFlowFooter extends LightningElement
{
	/**
	 * @description Decides whether to dispatch a flow navigation event or custom event
	 * @type {boolean}
	 */
	@api useFlowNextEvent = false;
	isChild = true;
	/**
	 * @description Tracks if a policy has been selected in the parent component. Used for event/navigation logic.
	 * @type {boolean}
	 */
	@api isPolicySelected = false;
	/**
	 * @description Tracks if a recipient has been selected in the parent component. Used for event/navigation logic.
	 * @type {boolean}
	 */
	@api isRecipientSelected = false;

	get nextTitle()
	{
		return this.useFlowNextEvent ? 'Send' : 'Next';
	}

	get previousTitle()
	{
		return 'Back';
	}

	/**
	 * @description Dispatches a navigation event or a custom event, depending whether the component is ready to proceed in the flow or whether the parent lwc
	 * still requires more logic but listening for a custom event.
	 * @param event The event from cmnLwcFlowFooter. See cmnLwcFlowFooter for possible values of event.detail
	 */
	dispatchFlowEvent(event)
	{
		switch(event.detail)
		{
			case 'NEXT':
				if(this.useFlowNextEvent)
				{
					if(this.isRecipientSelected)
					{
						this.dispatchEvent(new FlowNavigationNextEvent());
					}
					else
					{
						this.dispatchEvent(new CustomEvent('no_recipient_selected'));
					}
				}
				else
				{
					if(this.isPolicySelected)
					{
						this.dispatchEvent(new CustomEvent('confirmation_screen'));
					}
					else
					{
						this.dispatchEvent(new CustomEvent('no_policy_selected'));
					}
				}
				break;

			case 'BACK':
				if(this.useFlowNextEvent)
				{
					this.dispatchEvent(new CustomEvent('choose_screen'));
				}
				else
				{
					this.dispatchEvent(new FlowNavigationBackEvent());
				}
				break;

			default:
				throw new Error('Invalid Flow Event Type');
		}
	}
}