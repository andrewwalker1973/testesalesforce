<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AW_SendClientWelcomeEmail</fullName>
        <description>Send Client Welcome Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AW_LibertyCommunityEmailTemplates/AW_CommunityUserWelcome</template>
    </alerts>
</Workflow>
