import getCaseExtensionDetails from '@salesforce/apex/RSC_CTRL_CaseExtensionDetails.getCaseExtensionDetails';
import CASE_EXTENSION_OBJECT from '@salesforce/schema/SC_CaseExtension__c';
import {api, LightningElement, wire} from 'lwc';

/**
 * @description LWC to display case extension details related to a case.
 *
 * @author vikrant.goswami@accenture.com
 *
 * @date September 2022
 */
export default class RscLwcCaseExtensionDetails extends LightningElement
{
	@api recordId;
	objectApiName = CASE_EXTENSION_OBJECT.objectApiName;
	hasError;

	@wire(getCaseExtensionDetails, {caseId: '$recordId'})
	async fieldSetMap({data, error})
	{
		if(data)
		{
			if(data.caseExtensionId && data.fieldSetNames.length > 0)
			{
				await this.template.querySelector('c-cmn-lwc-record-form-with-field-set').getFieldsForFieldSet(data.caseExtensionId, data.fieldSetNames);
			}
			else
			{
				this.hasError = true;
			}
		}
		else if(error)
		{
			this.hasError = error;
		}
	};
}