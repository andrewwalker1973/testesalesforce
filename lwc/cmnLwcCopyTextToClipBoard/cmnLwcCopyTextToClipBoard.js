import { LightningElement, api } from 'lwc';

export default class CmnLwcCopyTextToClipBoard extends LightningElement {

    @api copyText;
    @api actionText;

    getScriptText(event) {

        var temptext = this.copyText.replace(/(<([^>]+)>)/gi, "\n");
        console.log(temptext + '    ' + this.copyText );

        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", temptext);

        document.body.appendChild(hiddenInput);
        hiddenInput.select();

        document.execCommand("copy");
        document.body.removeChild(hiddenInput); 

    }
}