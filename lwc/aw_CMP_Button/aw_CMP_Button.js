import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CmnButton extends NavigationMixin(LightningElement) {

    @api buttonLabel;
    @api link;
    @api variant;
    @api stretch;

    handleClick() {
        this.navigateToWebPage();
    }

    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.link
            }
        });
    }

}