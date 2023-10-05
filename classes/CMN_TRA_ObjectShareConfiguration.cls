/**
 * @description Trigger action that will be responsible for evaluating changes to the configuration for an object share and fire necessary platform events
 *
 * @see CMN_TRG_ObjectShareConfiguration
 * @see CMN_TRA_ObjectShareConfiguration_TEST
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_TRA_ObjectShareConfiguration extends CMN_TRA_ObjectShareEventPublisher
		implements CMN_TRA_Interfaces.CMN_INT_AfterInsert, CMN_TRA_Interfaces.CMN_INT_AfterUpdate,
				CMN_TRA_Interfaces.CMN_INT_AfterDelete, CMN_TRA_Interfaces.CMN_INT_AfterUndelete
{
	private static final String CLASS_METHOD = 'CMN_TRA_ObjectShareConfiguration/createAndPublishInstructions';

	// Expose the instructions via static list so that we can check processing in a Unit Test
	@TestVisible
	private static List<CMN_ObjectShareInstruction__e> instructions = new List<CMN_ObjectShareInstruction__e>();

	/**
	 * @description Will process a list of newly inserted items
	 *
	 * @param newItems inserted configuration items
	 */
	public void afterInsert(List<CMN_ObjectShareConfiguration__c> newItems)
	{
		createAndPublishInstructions(newItems, CMN_DAL_ObjectShareInstruction.OPERATION_INSERT);
	}

	/**
	 * @description Will process updates to existing items
	 *
	 * @param changedItems A list of items with their changes
	 * @param oldItems A list of items with their prior values
	 */
	public void afterUpdate(List<CMN_ObjectShareConfiguration__c> changedItems, List<CMN_ObjectShareConfiguration__c> oldItems)
	{
		createAndPublishInstructions(changedItems, CMN_DAL_ObjectShareInstruction.OPERATION_UPDATE);
	}

	/**
	 * @description Will process deletion of a list of items
	 *
	 * @param deletedItems The items that were deleted
	 */
	public void afterDelete(List<CMN_ObjectShareConfiguration__c> deletedItems)
	{
		createAndPublishInstructions(deletedItems, CMN_DAL_ObjectShareInstruction.OPERATION_DELETE);
	}

	/**
	 * @description Will process un-deletion of a list of items
	 *
	 * @param undeletedItems The items that were deleted
	 */
	public void afterUndelete(List<CMN_ObjectShareConfiguration__c> undeletedItems)
	{
		afterInsert(undeletedItems);
	}

	/**
	 * @description Will ensure that relevant share instruction platform events are created and published
	 *
	 * @param shareConfigurations The updated or inserted configuration items
	 * @param operation Indicates what operation was performed; either Insert, Update or Delete
	 */
	private void createAndPublishInstructions(List<CMN_ObjectShareConfiguration__c> shareConfigurations, String operation)
	{
		//We don't want to use the same valid share configurations for every chunk, we want to re-calculate valid shares
		validShareConfigurations = null;

		extractValidConfigurations(shareConfigurations, operation);

		if(!validShareConfigurations.isEmpty())
		{
			instructions.clear();

			for(CMN_ObjectShareConfiguration__c shareConfiguration : validShareConfigurations)
			{
				CMN_ObjectShareInstruction__e instruction = new CMN_ObjectShareInstruction__e();

				instruction.CMN_AccessLevel__c = shareConfiguration.CMN_AccessLevel__c;
				instruction.CMN_ObjectAPIName__c = shareConfiguration.CMN_ObjectAPIName__c;
				instruction.CMN_ObjectShareConfigurationId__c = shareConfiguration.Id;
				instruction.CMN_Operation__c = operation;
				instruction.CMN_ShareFrom__c = shareConfiguration.CMN_ShareFromId__c;
				instruction.CMN_ShareWith__c = shareConfiguration.CMN_ShareWithId__c;

				instructions.add(instruction);
			}

			publish(instructions, CLASS_METHOD);
		}

		//Since object is changing make sure we clear out the cache
		CMN_DAL_ObjectShareConfiguration.clearCache();
	}
}