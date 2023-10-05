import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getLatestAdviserPerformance from "@salesforce/apex/AW_CTR_ProductionMeasures.getLatestAdviserPerformance";
import PCS_ICONS from '@salesforce/resourceUrl/AW_ProductionClubStatusIcons';
import satisfactionRatingReportId from '@salesforce/label/c.AW_MyClientSatisfactionRatingReportId';
import viewSurveysReportBtnLabel from '@salesforce/label/c.AW_ViewSurveysReportBtnLabel';

export default class AwLwcProductionMeasures extends NavigationMixin(LightningElement) {

    @track adviserPerformance;
    @track adviserPerformanceError;
    @track isRepresentative = false;
    @track isFinancialAdviser = false;
    @track isSeniorFa = false;
    @track isExecutiveFa = false;
    @track isAchiever = false;
    @track hasProductionMeasure = false;
    wiredAdviserPerformance;

    representativeIcon = PCS_ICONS + '/Representative.png';
    financialAdviserIcon = PCS_ICONS + '/Financial_Adviser.png';
    seniorFaIcon = PCS_ICONS + '/Senior_FA.png';
    executiveFaIcon = PCS_ICONS + '/Executive_FA.png';
    achieverIcon = PCS_ICONS + '/Achiever.png';

    label = {
        viewSurveysReportBtnLabel
    };

    @wire(getLatestAdviserPerformance) ap(result) {
        this.wiredAdviserPerformance = result;
        if (result.data) {
            this.adviserPerformance = result.data;
            this.adviserPerformanceError = undefined;

            if(this.adviserPerformance.productionMeasureId !== 'Not Available') {
                this.hasProductionMeasure = true;
            }

            if(this.adviserPerformance.productionMeasureClubStatus.toUpperCase() === 'REP') {
                this.isRepresentative = true;
            }
            if(this.adviserPerformance.productionMeasureClubStatus.toUpperCase() === 'FA') {
                this.isFinancialAdviser = true;
            }
            if(this.adviserPerformance.productionMeasureClubStatus.toUpperCase() === 'SFA') {
                this.isSeniorFa = true;
            }
            if(this.adviserPerformance.productionMeasureClubStatus.toUpperCase() === 'EFA') {
                this.isExecutiveFa = true;
            }
            if(this.adviserPerformance.productionMeasureClubStatus.toUpperCase() === 'ACHIEVER') {
                this.isAchiever = true;
            }

        } else if (result.error) {
            this.adviserPerformanceError = result.error;
            this.adviserPerformance = undefined;
        }
    }

    navigateToRecord(evt) {
        switch (evt.currentTarget.dataset.id) {
            case 'activityDetailsButton':
            // View a custom object record.
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.adviserPerformance.productionMeasureId,
                    actionName: 'view'
                }
            });
            break;

            case 'surveysReportButton':
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: satisfactionRatingReportId,
                    actionName: 'view'
                }
            });
            break;
        }
    }
}