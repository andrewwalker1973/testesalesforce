/*----------------------------------------------*/

/* Component sizing */

.forceCommunityHtmlBlock {
    padding-top: 40px;
}

c-slc-lwc-your-servicing-team > .slds-grid {
    max-width: 1440px;
    margin-left: auto;
    margin-right: auto;
    
}

/* Component sizing ended*/

/*----------------------------------------------*/

/* Content lanes */

.siteforceContentArea .comm-layout-column:not(:empty) {
    padding: 0 !important;
}

.siteforceContentArea .comm-layout-column .ui-widget:not(:last-child) {
    margin-bottom: 0 !important;
}

.siteforceDesignTimeRegion > div:nth-of-type(1) > div > .js-dynamic-collection,
.contentRegion > div > div:nth-of-type(1) > .js-dynamic-collection {
    max-width: 100%;
    background: #F6F7F8;
}

.siteforceDesignTimeRegion > div:nth-of-type(2),
.contentRegion > div > div:nth-of-type(2) {
    background: #F6F7F8;
}

.siteforceDesignTimeRegion > div:nth-of-type(3),
.contentRegion > div > div:nth-of-type(3) {
    background: #F6F7F8;
}

.siteforceDesignTimeRegion > div:nth-of-type(4),
.contentRegion > div > div:nth-of-type(4) {
    background: #F6F7F8;
}

.siteforceDesignTimeRegion > div:nth-of-type(5),
.contentRegion > div > div:nth-of-type(5) {
    background: #F6F7F8;
}

.siteforceDesignTimeRegion > div:nth-of-type(6),
.contentRegion > div > div:nth-of-type(6) {
    background: #2B3341;
}

.siteforceDesignTimeRegion > div:nth-of-type(7),
.contentRegion > div > div:nth-of-type(7) {
    background: #2B3341;
}

.siteforceDesignTimeRegion > div:nth-of-type(7) h1,
.contentRegion > div > div:nth-of-type(7) h1{
    color: #ffffff;
    padding-bottom: 1.5rem !important;
}

.siteforceDesignTimeRegion > div:nth-of-type(8),
.contentRegion > div > div:nth-of-type(8) {
    background: #2B3341;
}

.siteforceDesignTimeRegion > div:nth-of-type(9),
.contentRegion > div > div:nth-of-type(9) {
    background: #2B3341;
}

/* Content lanes ended*/

/*----------------------------------------------*/

/* Carousel indicators styling */

.slds-is-active {
    background: #2B3341 !important;
    border-color: #2B3341 !important;
}

.slds-carousel__indicator-action {
    border-color: #2B3341 !important;
}

.slds-carousel__indicators {
    margin-bottom: 0;
}

/* Carousel indicators styling ended */

/*----------------------------------------------*/

/* Team Component Styling */

.slds-slot img {
    border-radius: 0.5rem;
    height: 200px;
    object-fit: cover;
}

.slds-slot {
    display: flex;
}

slot > div > .slds-text-title_caps {
    font-size: 1rem;
}

slot > div > .slds-p-bottom_xx-small {
    font-size: 1.25rem;
    color: #ffffff;
}

b > .slds-text-heading_small {
    font-size: 1.5rem;
    color: #ffffff;
    padding-top: 2rem !important
}

slot > div > .slds-text-title_caps,
slot > div > .slds-text-title_caps > lightning-formatted-email > a {
    color: #ffffff;
}

.slds-size_6-of-12, 
.slds-size--6-of-12 {
    width: 360px;
    max-width: 360px;
}

.slds-text-title_caps > lightning-formatted-url > a {
    color: #ffffff;
}

/* Team component styling ended */

/*----------------------------------------------*/

.slds-tabs_scoped {
    margin-left: auto;
    margin-right: auto;
    max-width: 1440px;
}

.slds-tabs_scoped__nav {
    background-color: #2B3341 !important;
}

.slds-is-active .slds-tabs_scoped__link {
    background-color: #777F88;
    color: #FFFFFF;
}

.slds-tabs_scoped__content {
       background-color: #2B3341;
    padding: 2rem 0 0 0;
}

.slds-tabs_scoped__item .slds-tabs_scoped__link {
    border-radius: 8px !important;
    text-decoration: none !important;
}

a {
    font-size: 1rem;
}

.slds-tabs_scoped__link {
    height: auto !important;
    padding: 8px 16px !important;
    color: #FFFFFF !important;
}

a:hover {
    color: #FFFFFF !important;
}

.slds-size_6-of-12 {
    display: flex;
    flex-direction: row;
}

.slds-size_6-of-12 > slot > div {
    padding-left: 1rem;
}

.slds-size_6-of-12 > slot > img {
    height: 10rem;
    width: 10rem;
}
