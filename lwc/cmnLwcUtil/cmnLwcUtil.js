/**
 * @description Common Utility methods for LWC
 *
 * @author darrion.james.singh@accenture.com
 *
 * @date June 2021, February 2022
 */

//noinspection JSValidateJSDoc
/**
 * Reduces one or more LDS errors into a single string of error messages.
 * @see https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.data_error
 * @see https://developer.salesforce.com/blogs/2020/08/error-handling-best-practices-for-lightning-web-components
 *
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String} Error messages
 */
export function reduceErrors(errors)
{
	let errorArray;

	if(Array.isArray(errors))
	{
		errorArray = [...errors];
	}
	else
	{
		errorArray = [errors];
	}

	//noinspection FunctionWithMultipleReturnPointsJS
	return errorArray
	.filter(error => !!error)
	.map(({body, message, statusText}) =>
	{
		// UI API read errors
		//noinspection JSUnresolvedVariable
		if(body.duplicateResults && body.duplicateResults.length > 0)
		{
			return body.duplicateResults.map((e) => e.message);
		}

		//noinspection JSUnresolvedVariable
		if(body.fieldErrors && body.fieldErrors.length > 0 && Array.isArray(body.fieldErrors))
		{
			return body.fieldErrors.map((e) => e.message);
		}

		//noinspection JSUnresolvedVariable
		if(body.pageErrors && body.pageErrors.length > 0 && Array.isArray(body.pageErrors))
		{
			return body.pageErrors.map((e) => e.message);
		}

		if(Array.isArray(body))
		{
			return body.map((e) => e.message);
		}
		// UI API DML, Apex and network errors
		if(body && typeof body.message === 'string')
		{
			return body.message;
		}
		// JS errors
		if(typeof message === 'string')
		{
			return message;
		}
		// Unknown error shape so try HTTP status text
		return statusText;
	})
	.reduce((prev, curr) => prev.concat(' // ' + curr));
}

/**
 * @description Generic sorting function for an object
 * @param {string} field Field on which to sort the object
 * @param {-1 | 1} reverse 1 for the default order, and -1 to reverse the order
 * @param primer function which is applied to the value of the object at the key 'field' before sorting occurs.
 * @return {function(*, *)}
 */
export function sortBy(field, reverse, primer)
{
	const key = primer ? function(x)
	{
		return primer(x[field]);
	} : function(x)
				{
					return x[field];
				};

	return function(A, B)
	{
		let a = key(A);
		let b = key(B);
		return reverse * ((a > b) - (b > a));
	};
}

//noinspection JSUnusedGlobalSymbols
/**
 * @description Counter generator that starts at a specified number
 * @returns {Generator<number, void, *>}
 */
export function* counter(initialIndex)
{
	let index = initialIndex;
	while(true)
	{
		yield index;
		index++;
	}
}

/**
 * @description Array generator that starts at a specified element number
 * @param array
 * @param initialIndex Array index to begin at
 * @returns {Generator<null|*, void, *>}
 */
export function* arrayGenerator(array = [], initialIndex = 0)
{
	for(let i = initialIndex; i < array.length; i++)
	{
		yield array[i];
	}

	return null;
}

//noinspection JSUnusedGlobalSymbols
/**
 * @description Copies text to the clipboard
 * @param {string} text Text to be copied
 */
export function copyToClipBoard(text)
{
	return navigator.clipboard.writeText(text)
					.catch(err => console.error('Cannot write to clipboard: ', err));
}

/**
 * @description Takes in a string and replaces the placeholder characters with elements from the passed in substitutes array.
 * Works similar to the String.format Apex method.
 *
 * @param {string} templateString String with placeholders to be modified
 * @param {string[]} substitutes Array of strings to replace all placeholders in the templateString, from left to right.
 * @param {string} placeholder A character(s) which is used as a placeholder in the templateString.
 * The number of occurrences of the placeholder string should equal the number of elements in the substitutes array.
 *
 * @returns {string} The formatted string
 */
export function formatTemplateString(templateString, substitutes = [], placeholder = '{}')
{
	let finalString = templateString.trim();

	if(finalString.includes(placeholder))
	{
		substitutes.forEach(sub =>
		{
			finalString = finalString.replace(placeholder, sub);
		});
	}

	return finalString;
}

/**
 * @description Converts a mixed case string into sentence case
 * @param {string} mixedCaseString Mixed case string to be converted
 * @returns {string} Sentence case string
 */
export function convertToSentenceCase(mixedCaseString)
{
	return mixedCaseString.toLowerCase().replace(/(^\s*\w|[.!?]\s*\w)/g,
			(word) => word.toUpperCase());
}