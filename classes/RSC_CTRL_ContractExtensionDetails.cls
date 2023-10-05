/**
 * @description Controller used to get the associated contract extension details.
 *
 * @see RSC_CTRL_ContractExtensionDetails_TEST  @story 320305
 *
 * @author vikrant.goswami@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class RSC_CTRL_ContractExtensionDetails
{
	/**
	 * @description method to get associated contract extension field set based on associated contract id
	 *
	 * @param associatedContractId record Id of associated contract
	 *
	 * @return DTO with associated contract extension id and field set names
	 */
	@AuraEnabled(Cacheable=true)
	public static DTO_ContractExtensionDetails getContractExtensionDetails(Id associatedContractId)
	{
		SC_AssociatedContract__c associatedContract = SC_DAL_AssociatedContract.findById(new Set<Id>{associatedContractId}).iterator().next();
		DTO_ContractExtensionDetails dtoContractExtensionDetails = new DTO_ContractExtensionDetails();
		if(associatedContract != null)
		{
			dtoContractExtensionDetails.contractExtensionId = associatedContract.SC_AssociatedContractExtension__c;
			List<String> listOfFieldSetNames =
					associatedContract.SC_Case__r?.RSC_ServiceType__r?.RSC_AssociatedContractExtensionFieldSet__c.replaceAll('\\s+', '').split(',');
			for (String fieldSetName : listOfFieldSetNames)
			{
				dtoContractExtensionDetails.fieldSetNames.add(fieldSetName);
			}
		}
		return dtoContractExtensionDetails;
	}

	/**
	 * @description DTO containing the details for a case extension
	 */
	public class DTO_ContractExtensionDetails
	{
		/**
		 * @description field to store associated contract extension record Id
		 */
		@AuraEnabled
		public String contractExtensionId;

		/**
		 * @description List to store associated contract extension fieldset names
		 */
		@AuraEnabled
		public List<String> fieldSetNames = new List<String>();
	}
}