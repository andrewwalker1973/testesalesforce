/**
 * Abstraction for Lightning Message Service
 */
import {APPLICATION_SCOPE, publish, releaseMessageContext, subscribe} from 'lightning/messageService';

// (MessageContext, MessageChannel, { key: value })
const publishMessage = (messageContext, messageChannel, payload) =>
{
	if(!messageContext)
	{
		throw new Error(`Error: messageContext is ${messageContext}`);
	}
	else if(!messageChannel)
	{
		throw new Error(`Error: messageChannel is ${messageChannel}`);
	}
	else if(!payload)
	{
		throw new Error(`Error: payload is ${payload}`);
	}

	publish(messageContext, messageChannel, payload);
};

// (MessageContext, MessageChannel, (message) => void)
const subscribeToMessageChannel = (messageContext, messageChannel, handler, isApplicationScope = false) =>
{
	if(!messageContext)
	{
		throw new Error(`Error: messageContext is ${messageContext}`);
	}
	else if(!messageChannel)
	{
		throw new Error(`Error: messageChannel is ${messageChannel}`);
	}
	else if(!handler)
	{
		throw new Error(`Error: handler is ${handler}`);
	}

	if(isApplicationScope)
	{
		return subscribe(messageContext, messageChannel, (message) => handler(message), {scope: APPLICATION_SCOPE});
	}
	return subscribe(messageContext, messageChannel, (message) => handler(message), null);
};

// (MessageContext)
const unsubscribeFromAll = (messageContext) =>
{
	releaseMessageContext(messageContext);
};

export {
	subscribeToMessageChannel,
	unsubscribeFromAll,
	publishMessage
};