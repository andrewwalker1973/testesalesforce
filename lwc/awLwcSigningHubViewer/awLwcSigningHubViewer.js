/**
 * @description Component used to fetch the load the SigningHub portal viewer
 *
 * @author Accenture
 *
 * @see @story 166448
 *
 * @date August 2021
 */

import { LightningElement, track, wire, api } from 'lwc';
import { reduceErrors } from 'c/cmnLwcUtil';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import modalStyle from '@salesforce/resourceUrl/AW_SigningHubViewerModalStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import signingHubUrl from '@salesforce/label/c.SigningHubUrl';
import fetchOAuthToken from '@salesforce/apex/AW_CTRL_SigningHubOAuthToken.fetchOAuthToken';
import PACKAGE_ID from '@salesforce/schema/AW_Envelope__c.AW_PackageID__c';

const FIELD = [PACKAGE_ID];

export default class AwLwcSigningHubViewer extends LightningElement
{
    @api recordId;
    isSpinner;
    packageId;
    iFrameUrl;
    hasRendered;

    /**
    * Wire method to fetch the Package Id value of the envelope
    */
    @wire(getRecord, { recordId: '$recordId', fields: FIELD })
        receiveRecord(result)
        {
            if (result.data)
            {
                this.packageId = getFieldValue(result.data, PACKAGE_ID);
                if(!this.packageId)
                {
                    this.closeIFrame();
                    this.showToast('Package ID not found', 'No Package ID found for Envelope', 'error');
                }
            }
            else if (result.error)
            {
                var errorMessage = reduceErrors(error).join(' // ');
                this.showToast('Error loading Envelope', errorMessage, 'error');
                this.closeIFrame();
            }
    }

    /**
     * show loading spinner while iFrame content loads
     */
    connectedCallback()
    {
        /**
         * Loading style for modal from a static resource
         */
        loadStyle(this, modalStyle);
        this.isSpinner = true;
    }

    /**
     * renderedCallback which loads the iframe once the OAuth token is fetched
     */
    renderedCallback()
    {
        if(!this.hasRendered && this.packageId)
        {
            this.hasRendered = true;
            fetchOAuthToken({envelopeId: this.recordId})
                .then(result =>
                {
                    if(result.callSuccessful == true)
                    {
                        this.iFrameUrl = `${signingHubUrl}/Integration?access_token=${result.oAuthTokenOrErrorMessage}&document_id=${this.packageId}`;
                    }
                    else
                    {
                        this.isSpinner = false;
                        this.closeIFrame();
                        var errorMessage = result.oAuthTokenOrErrorMessage;
                        this.showToast('Error fetching the OAuth Token', errorMessage, 'error');
                    }
                })
                .catch(error =>
                {
                    this.isSpinner = false;
                    this.closeIFrame();
                    var errorMessage = reduceErrors(error).join(' // ');
                    this.showToast('Error fetching the OAuth Token', errorMessage, 'error');
                });
        }
    }

    /**
     * used to show toast message based on different success or fail scenarios
     */
    showToast(title, message, variant)
    {
        this.template.querySelector('c-cmn-lwc-toast').customNotification(title, message, variant);
    }

    /**
     * hide the loading spinner once the iFrame content is loaded
     */
    iframeLoaded(event)
    {
        //Stop spinner only if the src is populated
        if (event.target.src)
        {
            this.isSpinner = false;
        }
    }

    /**
     * close the iFrame using the close icon
     */
    closeIFrame()
    {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}