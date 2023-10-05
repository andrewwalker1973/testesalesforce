/**
 * @description LWC Component used to LWC Component used to render the detail section of FinancialAccount
 *
 * @author jayanth.kumar@accenture.com
 *
 * @date January 2022
 */
import {api, LightningElement} from 'lwc';

export default class RscLwcDisplayFinancialAccountWithFieldSets extends LightningElement
{
	@api recordId;
	@api objectApiName;

	get developerName()
	{
		return 'RSC_displayFinancialAccountWithFieldSets';
	}
}