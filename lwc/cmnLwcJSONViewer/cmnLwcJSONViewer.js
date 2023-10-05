/**
 * @description A LWC component for displaying JSON
 *
 * @author Accenture
 *
 * @date February 2020
 */

import { LightningElement, api } from "lwc";

export default class CmnLwcJsonViewer extends LightningElement
{
  	@api jsonText;

    /*
     * @description After the UI is rendered.
     */
    renderedCallback()
    {
        try
        {
        	this.jsonText = this.highlightJSONSyntax(this.jsonText);
        	const container = this.template.querySelector('.container');
        	container.appendChild(document.createElement('pre')).innerHTML = this.jsonText;
        }
        catch (renderError)
        {
            const container = this.template.querySelector('.container');
            container.appendChild(document.createElement('pre')).innerHTML = '{ "error" : \"' + this.jsonText + '\"}';
        }
    }

	/*
	 * @description Highlight the JSON to color the attributes based on the data type
	 */
 	highlightJSONSyntax(inputJSON) {
 	    inputJSON = JSON.parse(inputJSON);
 	    inputJSON = JSON.stringify(inputJSON, undefined, 4);
		inputJSON = inputJSON.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        return inputJSON.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
            var cls = 'number';
            if (/^"/.test(match)) {
                if (/:$/.test(match)) {
                    cls = 'key';
                } else {
                    cls = 'string';
                }
            } else if (/true|false/.test(match)) {
                cls = 'boolean';
            } else if (/null/.test(match)) {
                cls = 'null';
            }
            return '<span class="' + cls + '">' + match + '</span>';
        });
    }

}