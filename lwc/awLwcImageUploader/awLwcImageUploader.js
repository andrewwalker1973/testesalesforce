import { LightningElement, track, api } from 'lwc';
//import cropper from "@salesforce/resourceUrl/cropper";
//import { loadScript } from "lightning/platformResourceLoader";
import saveObjectImage from '@salesforce/apex/AW_CTR_ClientCommunity.saveObjectImage';

export default class AwLwcImageUploader extends LightningElement {

    @api recordId;
    @track fileName = '';
    @track showLoadingSpinner = false;
    @track maxFileSizeWarning = false;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;
    

/*
    renderedCallback() {
        Promise.all([loadScript(this, cropper + "/cropper/cropper.min.js")])
            .then(() => {
                console.log("Cropper Loaded....");
            })
            .catch(error => {
                console.log("Error Loading Cropper: " + error);
            });
    }
    */

    // getting file 
    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    handleSave() {
        if (this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else {
            this.fileName = 'Please select file to upload!!';
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            this.maxFileSizeWarning = true;
            window.console.log('File Size is to long' + this.file.size);
            return;
        }
        this.maxFileSizeWarning = false;
        this.showLoadingSpinner = true;
        // create a FileReader object 
        this.fileReader = new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);

            // call the uploadProcess method 
            this.saveToFile();
        });

        this.fileReader.readAsDataURL(this.file);
    }

    saveToFile() {
        saveObjectImage({objectId: this.recordId, fileName: this.file.name, imageData: encodeURIComponent(this.fileContents)})
        .then(result => {
            window.console.log('result ====> ' +result);

            this.fileName = this.fileName + ' - Uploaded Successfully';
            this.showLoadingSpinner = false;
            this.dispatchEvent(new CustomEvent('upload'));

            window.console.log(result);

        })
        .catch(error => {
            // Showing errors if any while inserting the files
            window.console.log(error);
        });
    }

}