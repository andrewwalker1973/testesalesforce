import getContractExtensionDetails from '@salesforce/apex/RSC_CTRL_ContractExtensionDetails.getContractExtensionDetails';
import ASSOCIATED_CONTRACT_EXTENSION_OBJECT from '@salesforce/schema/SC_AssociatedContractExtension__c';
import {api, LightningElement, wire} from 'lwc';

/**
 * @description LWC to display the associated contract extension details.
 *
 * @author vikrant.goswami@accenture.com
 *
 * @date July 2022
 */
export default class RscLwcContractExtensionDetails extends LightningElement
{
	@api recordId;
	objectApiName = ASSOCIATED_CONTRACT_EXTENSION_OBJECT.objectApiName;
	hasError;

	@wire(getContractExtensionDetails, {associatedContractId: '$recordId'})
	async fieldSetMap({data, error})
	{
		if(data)
		{
			if(data.contractExtensionId && data.fieldSetNames.length > 0)
			{
				await this.template.querySelector('c-cmn-lwc-record-form-with-field-set').getFieldsForFieldSet(data.contractExtensionId, data.fieldSetNames);
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