<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Telephone Number</label>
    <protected>false</protected>
    <values>
        <field>CMN_Enabled__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>CMN_Regular_Expression__c</field>
        <value xsi:type="xsd:string">^((\+)?[1-9]{1,4})?([-\s\.\/])?((\(\d{1,4}\))|\d{1,4})(([-\s\.\/])?[0-9]{1,6}){2,6}(\s?(ext|x)\s?[0-9]{1,6})?$</value>
    </values>
</CustomMetadata>
