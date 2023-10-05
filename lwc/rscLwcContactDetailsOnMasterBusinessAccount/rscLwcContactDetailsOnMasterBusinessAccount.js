/**
 * @description LWC Component used to display the Contact Details, Correspondence Address, Residential
 Address and Physical Address section on Master Business Account Under the Contact Details tab
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date January 2022
 */
import {LightningElement, api} from 'lwc';

export default class RscLwcContactDetailsOnMasterBusinessAccount extends LightningElement
{
	@api recordId;
	@api objectApiName;

	get developerName()
	{
		return 'RSC_displayContactOnBusinessMaster';
	}
}