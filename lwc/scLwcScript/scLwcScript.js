/**
 * @description LWC to display Script to agents.
 *
 * @author darrion.james.singh@accenture.com vikrant.goswami@accenture.com
 *
 * @see @story 297812
 *
 * @date November 2022
 */

import {refreshApex} from '@salesforce/apex';
import getKnowledgeScript from '@salesforce/apex/SC_CTRL_Script.getScriptForCase';
import {api, LightningElement, wire} from 'lwc';

export default class ScLwcScript extends LightningElement
{
	scriptWire;
	scriptFound;
	noScriptFound;
	foundError;
	@api recordId;

	get noRecord()
	{
		const data = this.scriptFound;
		return !(this.recordId && (data || this.noScriptFound));
	}

	@wire(getKnowledgeScript, {caseId: '$recordId'}) getScript(result)
	{
		this.scriptWire = result;
		const {data, error} = result;
		if(data)
		{
			if(data.serviceTypeName && data.scriptId)
			{
				this.scriptFound = data;
				this.noScriptFound = false;
			}
			else if(data.serviceTypeName)
			{
				this.scriptFound = false;
				this.noScriptFound = data;
			}
		}
		else
		{
			this.foundError = error;
		}
	}

	async refreshScript()
	{
		await refreshApex(this.scriptWire);
	}
}