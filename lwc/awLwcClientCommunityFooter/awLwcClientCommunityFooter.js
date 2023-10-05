import { LightningElement, api } from 'lwc';
import faisLine from '@salesforce/label/c.AW_ClientCommunityFAISLine';
import termsAndConditions from '@salesforce/label/c.AW_TermsAndConditionsLink';

export default class AwLwcClientCommunityFooter extends LightningElement {

    @api componentWidth; 

    label = {
        faisLine,
        termsAndConditions
    };

    get footerWidth(){
        return 'width: ' + this.componentWidth + 'px;';
    }

}