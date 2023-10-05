/**
 * @description Common component to redirect to salesforce page
 * @author darrion.james.singh
 * @date January 2022
 */

import {api, LightningElement} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class CmnLwcRedirect extends NavigationMixin(LightningElement)
{
	/**
	 * @description Redirect to record page
	 * @param recordId Valid SObject recordId
	 */
	@api redirectToRecordPage(recordId)
	{
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordId,
				actionName: 'view'
			}
		});
	}

}