/**
 * Created by pczerminski on 03.12.2020.
 */

 import { LightningElement, api, track } from 'lwc';

 export default class AwLwcStarRating extends LightningElement {
     @api ratingValue;
     @track widthPercent;
 
     connectedCallback() {
         if(this.ratingValue) {
             // Width percent is rounded to nearest tenth
             this.widthPercent = Math.round((this.ratingValue / 5 * 100 /10) * 10);
         }
     }
 
     get widthStars() {
         return `--w:` + this.widthPercent +'%';
     }
 }