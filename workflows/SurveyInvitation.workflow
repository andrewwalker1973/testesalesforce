<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AW_SurveyInvitation</fullName>
        <description>Survey Invitation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AW_LibertyCommunityEmailTemplates/AW_LibertyCommunitiesSurveyFeedbackRequestEmail</template>
    </alerts>
    <alerts>
        <fullName>AW_SurveyReminder</fullName>
        <description>Survey Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>AW_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AW_LibertyCommunityEmailTemplates/AW_LibertyCommunitiesSurveyFeedbackRequestEmail</template>
    </alerts>
</Workflow>