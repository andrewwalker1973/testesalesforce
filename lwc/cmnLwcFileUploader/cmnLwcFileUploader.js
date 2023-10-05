/**
 * @description Common component used to upload the large size files to Salesforce by using the Standard REST API
 *
 * @author bhanumurty.rayala@liberty.co.za
 *
 * @see CMN_CTRL_FileUploader
 *
 * @date January 2023
 */
import getBaseURL from '@salesforce/apex/CMN_CTRL_FileUploader.getBaseURL';
import getSessionId from '@salesforce/apex/CMN_CTRL_FileUploader.getSessionId';
import errorHeader from '@salesforce/label/c.CMN_FileUploadErrorMessage';
import {reduceErrors} from 'c/cmnLwcUtil';
import {api, LightningElement, wire} from 'lwc';

const CONTENT_TYPE = 'application/json';
const CONTENT_LOCATION = 'S';
const METHOD_POST = 'POST';

export default class CmnLwcFileUploader extends LightningElement
{
	@api acceptedFormats;

	contentVersionId;
	fileInstance;
	uploadedFileName;
	isFileLoaded = false;

	/**
	 * @description method to get the base url
	 */
	@wire(getBaseURL)
	baseUrl;

	/**
	 * @description method to get the session ID
	 */
	@wire(getSessionId)
	sessionId;

	/**
	 * @description Used to return the boolean flag to indicate if the file is uploaded
	 *
	 * @return The boolean flag
	 */
	@api get isFileSelected()
	{
		return this.isFileLoaded;
	}

	/**
	 * @description method to display the toast message using the common toast
	 */
	showToastError = (errorMessage, header = errorHeader) => this.template.querySelector('c-cmn-lwc-toast').customNotification(header, errorMessage, 'error');

	/**
	 * @description method to read the file using file reader
	 */
	uploadFile(event)
	{
		let file = event.target.files[0];
		this.uploadedFileName = event.detail.files[0].name;

		let reader = new FileReader();
		reader.onload = () =>
		{
			let fileData = reader.result.split(',')[1];
			this.fileInstance = {
				filename: file.name, fileData: fileData
			};
		};

		this.isFileLoaded = true;
		reader.readAsDataURL(file);
	}

	/**
	 * @description method to upload the file by creating the content version for the given first publish location ID
	 */
	@api
	async createContentVersion(firstPublishLocationId)
	{
		const {fileData, filename} = this.fileInstance;

		//request body for the fetch api
		let requestOptions = {
			method: METHOD_POST, headers: {
				Authorization: this.sessionId.data, 'Content-Type': CONTENT_TYPE
			}, body: JSON.stringify({
				Title: filename, PathOnClient: filename, ContentLocation: CONTENT_LOCATION, FirstPublishLocationId: firstPublishLocationId, VersionData: fileData
			})
		};

		// Method to invoke fetch api to upload the files via lightning web component
		await fetch(this.baseUrl.data, requestOptions)
		.then((response) =>
		{
			return response.text();
		})
		.then((data) =>
		{
			this.contentVersionId = JSON.parse(data).id;
			if(this.contentVersionId)
			{
				//Dispatch event to trigger further action in the parent component.
				const contentVersionEvent = new CustomEvent('uploadfile', {
					detail: {
						contentVersionId: this.contentVersionId, firstPublishLocationId: firstPublishLocationId
					}
				});
				this.dispatchEvent(contentVersionEvent);
			}
		})
		.catch((error) =>
		{
			console.error('error', error);
			this.showToastError(reduceErrors(error));
		});
		return this.contentVersionId;
	}
}