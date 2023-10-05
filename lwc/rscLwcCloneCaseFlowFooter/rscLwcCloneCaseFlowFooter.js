import {FlowNavigationBackEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import {api, LightningElement} from 'lwc';

/**
 * @description Flow footer that has a Back, Cancel, and Clone button. Used to provide a Clone Case option for certain flows.
 * @author darrion.james.singh@accenture.com
 * @date May 2022
 */
export default class RscLwcCloneCaseFlowFooter extends LightningElement
{
	isCancelClicked = false;

	@api get isCancel()
	{
		return this.isCancelClicked;
	}

	navigateBack()
	{
		this.dispatchEvent(new FlowNavigationBackEvent());
	}

	navigateCancel()
	{
		this.isCancelClicked = true;
		this.dispatchEvent(new FlowNavigationNextEvent());
	}

	navigateClone()
	{
		this.dispatchEvent(new FlowNavigationNextEvent());
	}
}