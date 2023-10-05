/**
 * @description Controller used to get the case extension details.
 *
 * @see RSC_CTRL_CaseExtensionDetails_TEST @story ST-316918
 *
 * @author vikrant.goswami@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class RSC_CTRL_CaseExtensionDetails
{
	/**
	 * @description Method used to get case extension fieldset based on case record Id
	 *
	 * @param caseId record Id of the case
	 *
	 * @return case extension record id and associated fieldset name corresponding to the service type of the case
	 */
	@AuraEnabled(Cacheable=true)
	public static DTO_CaseExtensionDetails getCaseExtensionDetails(Id caseId)
	{
		Case foundCase = SC_DAL_Case.findById(caseId);

		DTO_CaseExtensionDetails dtoDetails = new DTO_CaseExtensionDetails();

		if(foundCase != null)
		{
			dtoDetails.caseExtensionId = foundCase?.SC_CaseExtension__c;

			List<String> listOfFieldSetNames = foundCase.RSC_ServiceType__r?.RSC_CaseExtensionFieldSet__c.replaceAll('\\s+', '').split(',');

			for(String fieldSetName : listOfFieldSetNames)
			{
				dtoDetails.fieldSetNames.add(fieldSetName);
			}
		}

		return dtoDetails;
	}

	/**
	 * @description DTO containing the details for a case extension
	 */
	public class DTO_CaseExtensionDetails
	{
		/**
		 * @description field to store case extension record id
		 */
		@AuraEnabled
		public String caseExtensionId;

		/**
		 * @description field to store case extension field set name
		 */
		@AuraEnabled
		public List<String> fieldSetNames = new List<String>();
	}

}