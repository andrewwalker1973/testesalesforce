/**
 * @description Controller to get the required information for Knowledge Script components
 *
 * @see SC_CTRL_Script_TEST @story 297812
 *
 * @author bhaskar.arora@accenture.com uttpal.chandra@accenture.com
 *
 * @date July 2022, March 2023
 */
public inherited sharing class SC_CTRL_Script
{
	/**
	 * @description Method used to get the case details
	 *
	 * @param caseId record id of the case
	 *
	 * @return script linked to service type of the given case
	 */
	@AuraEnabled(Cacheable=true)
	public static DTO_Script getScriptForCase(Id caseId)
	{
		Case foundCase = SC_DAL_Case.findById(caseId);

		DTO_Script dtoScript;

		if(foundCase != null)
		{
			dtoScript = new DTO_Script();
			dtoScript.serviceTypeName = foundCase?.RSC_ServiceType__r.Name;

			Knowledge__kav foundArticle = SC_DAL_Knowledge.findByPublishedKnowledgeArticleId(foundCase.RSC_ServiceType__r?.SC_KnowledgeArticle__r.KnowledgeArticleId);

			if(foundArticle != null)
			{
				dtoScript.title = foundArticle.Title;
				dtoScript.content = foundArticle.AW_Text__c;
				dtoScript.scriptId = foundArticle.Id;
			}
		}

		return dtoScript;
	}

	/**
	 * @description DTO containing details of script
	 */
	public class DTO_Script
	{
		/**
		 * @description The id of the script
		 */
		@AuraEnabled
		public Id scriptId;
		/**
		 * @description The title of the script
		 */
		@AuraEnabled
		public String title;
		/**
		 * @description The content in the script
		 */
		@AuraEnabled
		public String content;
		/**
		 * @description The service type name of the case
		 */
		@AuraEnabled
		public String serviceTypeName;
	}

}