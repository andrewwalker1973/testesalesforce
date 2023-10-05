import { LightningElement, wire, track, api } from 'lwc';
import getCommunityUserDetails from "@salesforce/apex/AW_CTR_ClientProfilePicture.getCommunityUserDetails";

export default class AwLwcPersonAccountProfilePicture extends LightningElement {

    @api recordId;
    @track communityUser;
    @track communityUserError;
    wiredUser;

    @wire(getCommunityUserDetails, {accountId : '$recordId'}) user(result) {
        this.wiredUser = result;
        if (result.data) {
            this.communityUser = result.data;
            this.communityUserError = undefined;
        } else if (result.error) {
            this.communityUserError = result.error;
            this.communityUser = undefined;
        }
    }

}