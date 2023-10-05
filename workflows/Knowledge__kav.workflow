<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>RSC_SetApproverToEmpty</fullName>
        <description>Used to set the Knowledge Approver field to empty once all the approval is completed</description>
        <field>RSC_KnowledgeApproval__c</field>
        <name>Set Approver To Empty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RSC_SetNextPendingApproverInformation</fullName>
        <description>Used to set the next pending Approver information</description>
        <field>RSC_KnowledgeApproval__c</field>
        <formula>&apos;Knowledge Administrator Approval Pending&apos;</formula>
        <name>Set Next Pending Approver Information</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RSC_SetPendingApproverInformation</fullName>
        <description>Used to store the pending approver information</description>
        <field>RSC_KnowledgeApproval__c</field>
        <formula>IF((Owner:User.Profile.Name = &apos;Liberty Servicing Agent&apos;) , &apos;Team Leader Approval Pending&apos; , &apos;Knowledge Administrator Approval Pending&apos;)</formula>
        <name>Set Pending Approver Information</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SC_FieldUpdateOnKnowledgePublish</fullName>
        <description>This Field update will populate Invoke Trigger text field with the current date and time to reflect the new knowledge article publish.</description>
        <field>SC_ArticleApprovalTime__c</field>
        <formula>NOW()</formula>
        <name>Field Update On Knowledge Publish</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>RSC_PublishAsNew</fullName>
        <action>PublishAsNew</action>
        <description>Publishes Article</description>
        <label>Publish As New</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
</Workflow>