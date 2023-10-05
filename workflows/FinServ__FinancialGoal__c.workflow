<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AW_UpdateGrowthStrategyOnFinancialGoal</fullName>
        <field>AW_Growth_Strategy__c</field>
        <formula>IF( VALUE(AW_Growth_Strategy__c) &gt;= 0 &amp;&amp; VALUE(AW_Growth_Strategy__c) &lt; 2 , &quot;CPI + 1% TO CPI + 2%&quot;,
IF(VALUE(AW_Growth_Strategy__c)&gt;= 2 &amp;&amp; VALUE(AW_Growth_Strategy__c)&lt; 3, &quot;CPI + 2% TO CPI + 3%&quot;,
IF(VALUE(AW_Growth_Strategy__c)&gt;= 3 &amp;&amp; VALUE(AW_Growth_Strategy__c)&lt; 4, &quot;CPI + 3% to CPI + 4%&quot;,
IF(VALUE(AW_Growth_Strategy__c)&gt;= 4 &amp;&amp; VALUE(AW_Growth_Strategy__c)&lt; 5, &quot;CPI + 4% to CPI + 5%&quot;,
IF(VALUE(AW_Growth_Strategy__c)&gt;= 5 , &quot;CPI + 5% to CPI + 6%&quot;, &quot;&quot;
)
)
)
)
)</formula>
        <name>AW_UpdateGrowthStrategyOnFinancialGoal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AW UpdateGrowthStrategyOnFinancialGoal</fullName>
        <actions>
            <name>AW_UpdateGrowthStrategyOnFinancialGoal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updating Growth Strategy to CPI Range</description>
        <formula>AND(NOT(ISBLANK(AW_Growth_Strategy__c )), NOT( CONTAINS( AW_Growth_Strategy__c, &quot;CPI&quot; )) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>