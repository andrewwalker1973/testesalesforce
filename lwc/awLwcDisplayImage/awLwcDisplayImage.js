import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getObjectImage from "@salesforce/apex/AW_CTR_ClientCommunity.getObjectImage";

export default class AwLwcDisplayImage extends LightningElement {

    @api recordId;
    @api sitePath;

    wiredObjectImage;
    @track image;
    @track imageError;
    @track imageUrl;

    @wire(getObjectImage, { objectId: '$recordId' }) objectImage(result) {
        this.wiredObjectImage = result;
        if (result.data) {
            this.image = result.data;
            console.log('this.goalList: ' + JSON.stringify(this.image));
            if(this.sitePath !== undefined) {
                this.imageUrl = this.sitePath + '/sfc/servlet.shepherd/version/download/' + this.image.Id;
            }
            else {
                this.imageUrl = '/sfc/servlet.shepherd/version/download/' + this.image.Id;
            }

            this.imageError = undefined;
        } else if (result.error) {
            this.imageError = result.error;
            this.image = undefined;
        }
    }

    @api
    refreshImage() {
        console.log('refresh fired');
        return refreshApex(this.wiredObjectImage);
    }

}