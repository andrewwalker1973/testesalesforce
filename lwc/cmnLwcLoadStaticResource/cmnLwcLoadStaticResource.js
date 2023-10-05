/**
 * @description LWC used to load the latest version of static resource files. Currently supports two files, can be extended for more.
 *
 * @author Futureform
 *
 * @see 
 *
 * @date March 2023
 */
import {api, LightningElement, track, wire} from 'lwc';

import {loadStyle} from 'lightning/platformResourceLoader';
import slcPortalCSS from '@salesforce/resourceUrl/SLC_PortalCSS';

export default class CmnLwcLoadStaticResource extends LightningElement {
    isCssLoaded = false;
    @api staticResourceFileName1;
    @api staticResourceFileName2;

    connectedCallback(){ 
        const STYLESHEET_NAME = "SLC";
        const cssLinks = document.querySelectorAll("link");

        if(cssLinks){
            cssLinks.forEach((link) => {
                const href = link.href;
                if(href && href.includes(STYLESHEET_NAME)){
                    link.remove();
                }
            });
        }

		if(this.isCssLoaded){
            return
        }  
        this.isCssLoaded = true;

        if(this.staticResourceFileName1){
            loadStyle(this, slcPortalCSS+'/SLC_PortalCSS/'+this.staticResourceFileName1)
            .then(() => {
                console.log("CSS 1 Loaded Successfully")
            })
            .catch(error => { 
                console.log(error)
            });
        }

        if(this.staticResourceFileName2){
            loadStyle(this, slcPortalCSS+'/SLC_PortalCSS/'+this.staticResourceFileName2)
            .then(() => {
                console.log("CSS 2 Loaded Successfully")
            })
            .catch(error => { 
                console.log(error)
            });
        }


        /*const STYLESHEET_NAME = "SLC";
        const cssLinks = document.querySelectorAll("link");
        console.log(cssLinks);
        console.log(cssLinks.length)

        if(cssLinks){
            cssLinks.forEach((link) => {
                const href = link.href;
                if(href && href.includes(STYLESHEET_NAME)) {
                    link.remove();
                }
            });
        }*/
    }

}