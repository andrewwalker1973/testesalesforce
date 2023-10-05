<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AW_UpdateUACFID</fullName>
        <field>AW_UACFID__c</field>
        <formula>Owner.AW_UACFID__c</formula>
        <name>Update UACFID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AW_UpdateUACFID</fullName>
        <actions>
            <name>AW_UpdateUACFID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Owner name is change, the UACFID will change to new  UACFID</description>
        <formula>OR(ISNEW(),ISCHANGED(AW_AccountOwnerId__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
