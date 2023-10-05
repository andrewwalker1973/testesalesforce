/**
 * @description Trigger Action to ensure Communication Log is processed and the send reminder flag is marked as false on old communication log records
 *
 * @see CMN_TRG_CommunicationLog @story ST-322854
 * @see CMN_TRA_CommunicationLog_TEST
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_TRA_CommunicationLog extends CMN_TRA_BaseObject implements CMN_TRA_Interfaces.CMN_INT_BeforeInsert
{
	/**
	 * @description Context method will be called before insertion of Object.
	 *
	 * @param newLogs To store the list of Communication Logs
	 */
	public void beforeInsert(List<CMN_CommunicationLog__c> newLogs)
	{
		// Get the communication template map metadata record for Outstanding Requirement Template
		CMN_CommunicationTemplateMap__mdt foundTemplateMap =
				CMN_DAL_CommunicationTemplateMap.findByName(CMN_DAL_CommunicationTemplateMap.TEMPLATE_OUTSTANDING_REQUIREMENTS);

		// Get communication template record for the template code
		CMN_CommunicationTemplate__c foundTemplate = CMN_DAL_CommunicationTemplate.findByTemplateCode(foundTemplateMap.CMN_TemplateCode__c);

		if(foundTemplate != null)
		{
			Set<Id> caseIds = new Set<Id>();

			// Prepare a set of Case Ids only for communication logs that are created to send reminders
			for(CMN_CommunicationLog__c log : newLogs)
			{
				if(log.CMN_SendReminder__c)
				{
					caseIds.add(log.Case__c);
				}
			}

			if(!caseIds.isEmpty())
			{
				// Find all existing communication log records based on case Ids & communication template where send reminder flag is set as true
				List<CMN_CommunicationLog__c> foundLogs = CMN_DAL_CommunicationLog.findByCasesAndTemplate(caseIds, foundTemplate.Id);

				// To stop sending multiple reminders to all recipients, Update send reminder flag as false for existing communication log records
				for(CMN_CommunicationLog__c foundLog : foundLogs)
				{
					foundLog.CMN_SendReminder__c = false;
				}

				CMN_DAL_SObjectDomain.upsertDBObjects(foundLogs);
			}
		}
	}
}