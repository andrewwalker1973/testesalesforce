/*----------------------------------------------*/

/* Component sizing */

.cb-section_column > div > div:nth-of-type(3) {
    width: 560px;
    margin-left: auto;
    margin-right: auto;
}

.forceCommunityRichText {
    width: 560px;
    margin-left: auto;
    margin-right: auto;
    padding-bottom: 0.25rem;
}

.forceCommunityHtmlBlock {
    padding-top: 40px;
}

/* Component sizing ended */

/*----------------------------------------------*/

/* Table styling */

flowruntime-flow {
    padding-top: 0 !important;
}

slot > flowruntime-base-section > div {
    display: flex;
    flex-direction: column;
}

.slds-size_1-of-1 {
    width: 100%;
}

.slds-grid {
    display: flex;
    justify-content: space-between;
}

.slds-checkbox_toggle .slds-checkbox_on {
    display: none !important;
}

.slds-checkbox_toggle .slds-checkbox_off {
    display: none !important;
}

.flowruntimeBody {
    padding-left: 0 !important;
	padding-right: 0 !important;
}

.slds-gutters .slds-col {
    padding-left: 0 !important;
	padding-right: 0 !important;
}

.slds-accordion__summary-content {
    font-size: 1.25rem;
}

/* Table styling ended */

/*----------------------------------------------*/

/* Table footer styling */

.slds-card__footer {
    padding: 0;
}

.slds-card__footer .slds-button_brand {
    padding: 0.5rem 2rem 0.5rem 2rem;
    font-size: 1rem;
    color: #ffffff;
    background: #2B3341;
}

.slds-button_reset {
    font-size: 1.5rem;
}

.slds-form-element {
    padding-bottom: 0.2rem !important;
}

.column[flowruntime-baseSection_baseSection] {
    margin-bottom: 0 !important;
}

.slds-form-element__label {
    font-size: 1rem;
}

.slds-accordion__summary-action {
    padding: 0 0 1rem 0 !important;
}

/* Table footer styling ended */

/*----------------------------------------------*/

/* New fixes */

.slds-rich-text-editor__output > spna > p > span {
    color: #777F88;
}

.slds-rich-text-editor__output > span > p {
    padding-bottom: 1.5rem;
}

.slds-checkbox_toggle [type=checkbox]:checked+.slds-checkbox_faux_container .slds-checkbox_faux:after {
    display: none;
}

.slds-checkbox_toggle .slds-checkbox_faux {
    background-color: #EDEFF0;
    border-color: #EDEFF0;
    box-shadow: none;
}

.slds-checkbox_toggle .slds-checkbox_faux:after {
    background-color: #2B3341;
}

.slds-form-element__label {
    color: #2B3144;
}

.flow-button__NEXT {
    padding: 0 !important;
}

.section-control:nth-of-type(2) {
 	padding-top: 1rem;   
}

/* New fixes ended */