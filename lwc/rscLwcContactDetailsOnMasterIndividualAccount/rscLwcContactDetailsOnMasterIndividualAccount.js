/**
 * @description LWC Component used to display the Contact Details, Correspondence Address, Residential
 Address and Physical Address section on Master Individual Account Under the Contact Details tab
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date January 2022
 */
import {LightningElement, api} from 'lwc';

export default class RscLwcContactDetailsOnMasterIndividualAccount extends LightningElement
{
	@api recordId;
	@api objectApiName;

	get developerName()
	{
		return 'RSC_displayContactOnIndividualMaster';
	}
}