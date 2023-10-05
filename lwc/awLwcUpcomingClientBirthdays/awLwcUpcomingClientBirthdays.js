//noinspection JSUnresolvedFunction

/**
 * @description LWC Component to display upcoming client birthdays in next 7 days.
 *
 * @author pavan.t@lntinfotech.com, k.marakalala@acenture.com
 *
 * @date July 2023
 */

import getContacts from '@salesforce/apex/AW_CTRL_UpcomingClientBirthdays.getClientUpcomingBirthdayDetails';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import userId from '@salesforce/user/Id';
import {NavigationMixin} from 'lightning/navigation';
import {getListInfoByName} from 'lightning/uiListsApi';
import {LightningElement, track, wire} from 'lwc';

const UPCOMING_BIRTHDAYS_NEXT_7_DAYS_LIST_VIEW = 'AW_UpcomingBirthdaysNext7Days';
const EXCEPTION_MESSAGE = 'Exception When Fetching Upcoming Client Birthdays';
const TOAST_ERROR_MESSAGE_VARIANT = 'error';
export default class AwLwcUpcomingClientBirthdays extends NavigationMixin(LightningElement)
{
	@track contacts = [];
	birthdayCardTitle;
	noUpcomingBirthdaysMessage = 'There are no upcoming Birthdays for the next 7 Days';
	upcomingBirthdaysListViewId;

	/**
	 * get the size of the upcoming birthday contacts
	 */
	get hasContactsData()
	{
		return this.contacts.length > 0;
	}

	/**
	 * get the upcoming birthday clients for the account owner(logged-in user Id)
	 */
	@wire(getContacts, {accountOwnerId: userId}) wiredAccountsWithContacts({error, data})
	{
		if(data)
		{
			for (let i = 0; i < data.length; i++) {
				 this.birthDate = new Date(data[i].birthDate);
				 {
					this.contacts.push({sortId: data[i].birthDate === 'Today' ? 1 : 2, item: data[i]});
				}
			}
			//noinspection FunctionWithMultipleReturnPointsJS
			this.contacts.sort((a, b) => {
				if (a.sortId === b.sortId) {
					const aBirthDate = new Date(a.item.birthDate);
					const bBirthDate = new Date(b.item.birthDate);
					const aMonth = aBirthDate.getMonth();
					const bMonth = bBirthDate.getMonth();
					const aDate = aBirthDate.getDate();
					const bDate = bBirthDate.getDate();

					if (aMonth === bMonth) {
						return aDate - bDate;
					}
					return aMonth - bMonth;
				}
				return a.sortId - b.sortId;
			});
			this.contacts = this.contacts.map((x) => x.item);
			this.birthdayCardTitle = 'Birthdays (' + this.contacts.length + ')';
		}
		else if(error)
		{
			this.showToast(EXCEPTION_MESSAGE, error, TOAST_ERROR_MESSAGE_VARIANT);
		}
	}

	/**
	 * get the upcoming birthday next 7 days list view id from contact object
	 */
	@wire(getListInfoByName, {
		objectApiName: CONTACT_OBJECT.objectApiName, listViewApiName: UPCOMING_BIRTHDAYS_NEXT_7_DAYS_LIST_VIEW
	}) listInfo({error, data})
	{
		if(data)
		{
			//noinspection JSUnresolvedVariable
			this.upcomingBirthdaysListViewId = data.listReference.id;
		}
		else if(error)
		{
			this.showToast(EXCEPTION_MESSAGE, error, TOAST_ERROR_MESSAGE_VARIANT);
		}
	}

	/**
	 * Navigate to the upcoming client birthdays next 7 days list view on contact
	 */
	navigateToListView()
	{
		this[NavigationMixin.Navigate]({
			type: 'standard__objectPage', attributes: {
				objectApiName: 'Contact', actionName: 'list'
			}, state: {
				filterName: this.upcomingBirthdaysListViewId
			}
		});
	}

	/**
	 * Navigate to contact account
	 */
	navigateToAccount(event)
	{
		event.stopPropagation();
		const accountId = event.target.dataset.account;
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage', attributes: {
				recordId: accountId, objectApiName: 'Account', actionName: 'view'
			}
		});
	}

	/**
	 * used to show toast message based on different success or fail scenarios
	 */
	showToast(title, message, variant)
	{
		//noinspection JSUnresolvedFunction
		this.template
		.querySelector('c-cmn-lwc-toast')
		.customNotification(title, message, variant);
	}
}