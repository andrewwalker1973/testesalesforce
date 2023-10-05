import MC_OptionSelected from '@salesforce/messageChannel/CMN_MC_OptionSelected__c';
import {publishMessage, subscribeToMessageChannel} from 'c/cmnLightningMessageService';
import {FlowNavigationBackEvent, FlowNavigationFinishEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import {MessageContext} from 'lightning/messageService';
import {api, LightningElement, wire} from 'lwc';

export default class CmnLwcFlowFooter extends LightningElement
{
	@api hideBackButton = false;
	@api disableNext = false;
	@api nextTitle = 'Next';
	@api previousTitle = 'Back';
	@api overridePreviousToFinish = false;
	@api overrideNextToFinish = false;

	/**
	 * @description Set to True when this component is inside a parent LWC to manually handle flow Events.
	 * @type {boolean}
	 */
	@api isChildComponent = false;
	@wire(MessageContext) messageContext;

	isNextButtonDisabled = false;

	get isNextDisabled()
	{
		return this.isNextButtonDisabled;
	}

	set isNextDisabled(value)
	{
		this.isNextButtonDisabled = value;
	}

	connectedCallback()
	{
		this.isNextDisabled = this.disableNext;

		subscribeToMessageChannel(this.messageContext, MC_OptionSelected,
				message =>
				{
					if('optionSelected' in message)
					{
						this.isNextDisabled = !message.optionSelected;
					}
				});

		publishMessage(this.messageContext, MC_OptionSelected, {isReady: true});
	}

	/**
	 * @description Dispatches relevant event when the Back button is clicked.
	 */
	prevScreen()
	{
		if(this.isChildComponent)
		{
			this.dispatchFlowEvent('BACK');
		}
		else
		{
			this.dispatchEvent(this.overridePreviousToFinish ? new FlowNavigationFinishEvent() : new FlowNavigationBackEvent());
		}
	}

	/**
	 * @description Dispatches relevant event when the Next button is clicked.
	 */
	nextScreen()
	{
		if(this.isChildComponent)
		{
			this.dispatchFlowEvent('NEXT');
		}
		else
		{
			this.dispatchEvent(this.overrideNextToFinish ? new FlowNavigationFinishEvent() : new FlowNavigationNextEvent());
		}
	}

	/**
	 * @description Dispatch a custom 'flowscreenevent' event for the parent component when a next or back button is clicked.
	 * Used as an event to implement custom navigation logic from a parent component.
	 * @param {'BACK' | 'NEXT'} eventName Possible events to be dispatched.
	 */
	dispatchFlowEvent(eventName)
	{
		this.dispatchEvent(new CustomEvent('flowscreenevent', {detail: eventName}));
	}
}