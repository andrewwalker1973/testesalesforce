import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getGoals from "@salesforce/apex/AW_CTR_ClientCommunity.getGoalList";

export default class AwLwcGoalSnapshot extends NavigationMixin(LightningElement) {

    @track goalList;
    @track goalListError;

    wiredGoals;

    @wire(getGoals) goals(result) {
        this.wiredGoals = result;
        if (result.data) {
            this.goalList = result.data;
            this.goalListError = undefined;
        } else if (result.error) {
            this.goalListError = result.error;
            this.goalList = undefined;
        }
    }

    scrollLeft() {
        let timelineContainer = this.template.querySelector('.timeline-container');
        sideScroll(timelineContainer, 'left', 25, 100, 10);
    }

    scrollRight() {
        let timelineContainer = this.template.querySelector('.timeline-container');
        sideScroll(timelineContainer, 'right', 25, 100, 10);
    }

}

function sideScroll(element, direction, speed, distance, step) {
    let scrollAmount = 0;
    let slideTimer = setInterval(function () {
        if (direction == 'left') {
            element.scrollLeft -= step;
        } else {
            element.scrollLeft += step;
        }
        scrollAmount += step;
        if (scrollAmount >= distance) {
            window.clearInterval(slideTimer);
        }
    }, speed);
}