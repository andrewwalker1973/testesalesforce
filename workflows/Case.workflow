<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ECM_ClientClaimConfirmationEmail</fullName>
        <description>Client Claim Confirmation Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>workbench@liberty.co.za</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ECM_ContactCentreEmailTemplates/ECM_ClientClaimConfirmationEmail</template>
    </alerts>
    <alerts>
        <fullName>ECM_ServiceDeskClaimRequestEmail</fullName>
        <ccEmails>info@liberty.co.za</ccEmails>
        <description>Service Desk Claim Request Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>workbench@liberty.co.za</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ECM_ContactCentreEmailTemplates/ECM_ServiceDeskClaimRequestEmail</template>
    </alerts>
    <alerts>
        <fullName>SD_LibertyHealthCaseAcknowledgement</fullName>
        <description>Liberty Health Case Acknowledgement</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>workbench@liberty.co.za</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SD_LibertyHealthSupport/SD_CaseAcknowledgement</template>
    </alerts>
    <alerts>
        <fullName>SLI_CPDClosed</fullName>
        <description>STANLIB CPD - Closed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_CPDCaseClosed</template>
    </alerts>
    <alerts>
        <fullName>SLI_CorporateCashAwaitingFurtherInformation</fullName>
        <description>STANLIB Corporate Cash - Awaiting Further Information</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_CorporateCashAwaitingFurtherInformation</template>
    </alerts>
    <alerts>
        <fullName>SLI_CorporateCashClosed</fullName>
        <description>STANLIB Corporate Cash - Closed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_InstitutionalCaseClosed</template>
    </alerts>
    <alerts>
        <fullName>SLI_CorporateCashTriage</fullName>
        <description>STANLIB Corporate Cash - Triage</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_CorporateCashTriage</template>
    </alerts>
    <alerts>
        <fullName>SLI_DFMAwaitingFurtherInformation</fullName>
        <description>STANLIB DFM - Awaiting Further Information</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_DFMAwaitingFurtherInformation</template>
    </alerts>
    <alerts>
        <fullName>SLI_DFMClosed</fullName>
        <description>STANLIB DFM - Closed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_DFMCaseClosed</template>
    </alerts>
    <alerts>
        <fullName>SLI_DFMTriage</fullName>
        <description>STANLIB DFM - Triage</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_DFMTriage</template>
    </alerts>
    <alerts>
        <fullName>SLI_InstitutionalAwaitingFurtherInformation</fullName>
        <description>STANLIB Institutional - Awaiting Further Information</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_InstitutionalAwaitingFurtherInformation</template>
    </alerts>
    <alerts>
        <fullName>SLI_InstitutionalClosed</fullName>
        <description>STANLIB Institutional - Closed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_InstitutionalCaseClosed</template>
    </alerts>
    <alerts>
        <fullName>SLI_InstitutionalTriage</fullName>
        <description>STANLIB Institutional - Triage</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_InstitutionalTriage</template>
    </alerts>
    <alerts>
        <fullName>SLI_LISPAwaitingFurtherInformation</fullName>
        <description>STANLIB LISP - Awaiting Further Information</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_LISPAwaitingFurtherInformation</template>
    </alerts>
    <alerts>
        <fullName>SLI_LISPClosed</fullName>
        <description>STANLIB LISP - Closed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_LISPCaseClosed</template>
    </alerts>
    <alerts>
        <fullName>SLI_LISPTriage</fullName>
        <description>STANLIB LISP - Triage</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SLC_CaseemailTemplates/STANLIB_LISPTriage</template>
    </alerts>
    <fieldUpdates>
        <fullName>RSC_UpdateCasePriorityToHigh</fullName>
        <description>Update Request priority to High when TAT reaches 80% of the time.</description>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Update Case Priority To High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RSC_UpdateCasePriorityToMedium</fullName>
        <description>Update Request priority to Medium when TAT reaches 50% of the time.</description>
        <field>Priority</field>
        <literalValue>Medium</literalValue>
        <name>Update Case Priority To Medium</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>