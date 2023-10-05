/*----------------------------------------------*/

/* Component sizing */

.forceCommunityHtmlBlock {
    padding-top: 80px;
    padding-bottom: 80px;
}

.cb-section_row > div > div > div:nth-of-type(1) {
    max-width: 1440px;
	margin-left: auto;
	margin-right: auto;
}

.cb-section_row > div > div > div:nth-of-type(2) {
    max-width: 1440px;
	margin-left: auto;
	margin-right: auto;
}

/* Component sizing ended*/

/*----------------------------------------------*/

/* Button styling */

.buttons {
    display: flex;
    padding-top: 40px;
}

.onboarding_button_main {
    padding: 0.5rem 2rem 0.5rem 2rem;
    font-size: 1rem;
    border-radius: 4px;
    background: #2B3341;
}

.onboarding_button_main > p > a {
    color: #ffffff;
    font-weight: 500;
}

.onboarding_button_second {
    padding: 0.5rem 2rem 0.5rem 2rem;
    margin-right: 1rem;
    font-size: 1rem;
    border-color: #D5D8DC;
	border-radius: 4px;
    border-style: solid;
    border-width: 1px;
    font-weight: 500;
}

/* Button styling ended */

/*----------------------------------------------*/

/* Table styling */

.opptyTable > tbody > tr:nth-of-type(1) {
	background-color: #EDF0F8 !important;
}

.opptyTable {
    border-spacing: 0 1rem !important;
    border-collapse: separate;
    width: 100% !important;
}

.opptyTable > tbody > tr > th:first-child {
    border-radius: 0.5rem 0 0 0.5rem !important;
}

.opptyTable > tbody > tr > th:last-child {
    border-radius: 0 0.5rem 0.5rem 0 !important;
}

.opportunityDetail {
	 background-color: #F6F7F8 !important;
}

.opportunityDetail td:first-child {
    border-radius: 0.5rem 0 0 0.5rem !important;
}

.opportunityDetail td:last-child {
    border-radius: 0 0.5rem 0.5rem 0 !important;
}

.opportunityDetail td {
    padding: 1rem !important;
    font-size: 1rem;
}

.opportunityDetail th {
    padding: 1rem !important;
    font-size: 1rem;
}

.opptyTable > tbody > tr > th {
    padding: 0.5rem 1rem 0.5rem 1rem !important;
    font-size: 1rem;
}

.flowruntimeBody__lwc {
    padding-left: 0 !important;
}

/* Table styling ended */

/*----------------------------------------------*/

/* Document vault styling */

c-slc-lwc-vaulted-documents-account .slds-p-horizontal_large, 
c-slc-lwc-vaulted-documents-account .slds-p-horizontal--large,
c-slc-lwc-vaulted-documents-account .slds-card__body {
    padding-left: 0 !important;
}