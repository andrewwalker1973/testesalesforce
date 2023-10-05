<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <brand>
        <headerColor>#0070D2</headerColor>
        <logo>CMN_AdmininstrationLogo</logo>
        <logoVersion>1</logoVersion>
        <shouldOverrideOrgTheme>false</shouldOverrideOrgTheme>
    </brand>
    <description>An application used by Administrators to monitor or configure various items included in the Common Library; like web service calls.</description>
    <formFactors>Small</formFactors>
    <formFactors>Large</formFactors>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <isNavTabPersistenceDisabled>false</isNavTabPersistenceDisabled>
    <label>Administration</label>
    <navType>Standard</navType>
    <profileActionOverrides>
        <actionName>Tab</actionName>
        <content>AW_Admin_Homepage</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>standard-home</pageOrSobjectType>
        <type>Flexipage</type>
        <profile>Liberty Field Support</profile>
    </profileActionOverrides>
    <tabs>standard-home</tabs>
    <tabs>CMN_AppLog__c</tabs>
    <tabs>CMN_JobScheduler__c</tabs>
    <tabs>CMN_WebserviceCallQueue__c</tabs>
    <tabs>standard-report</tabs>
    <tabs>standard-Dashboard</tabs>
    <tabs>CMN_ObjectShareConfiguration__c</tabs>
    <uiType>Lightning</uiType>
</CustomApplication>
