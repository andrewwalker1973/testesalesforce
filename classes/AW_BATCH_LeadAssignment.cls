/**
 * @description Batch class to use in Lead Assignment
 *
 * @see AW_BATCH_LeadAssignment_TEST
 *
 * @author Accenture, jason.van.beukering@accenture.com
 *
 * @date 2019, August 2023
 */
public class AW_BATCH_LeadAssignment implements Database.Batchable<SObject>, Database.Stateful
{
	private final List<User> usersToUpdate = new List<User>();

	/**
	 * @description Start method of batch class
	 *
	 * @param context Represents the parameter type of a batch job method and contains the batch job ID.
	 *
	 * @return Recordset containing the leads to process
	 */
	public Database.QueryLocator start(Database.BatchableContext context)
	{
		return CMN_DAL_Lead.findAllByOwnerIdQuery(AW_DAL_Group.getDistributionQueue().Id);
	}

	/**
	 * @description Gets invoked when the batch job finishes
	 *
	 * @param context Represents the parameter type of a batch job method and contains the batch job ID.
	 * @param leads The leads to process in the current batch
	 */
	public void execute(Database.BatchableContext context, List<Lead> leads)
	{
		usersToUpdate.addAll(AW_DAL_LeadAssignment.assignAdviser(leads));
	}

	/**
	 * @description Finish method of batch class
	 *
	 * @param context Represents the parameter type of a batch job method and contains the batch job ID.
	 */
	public void finish(Database.BatchableContext context)
	{
		CMN_DAL_SObjectDomain.updateDBObjects(usersToUpdate, false);
	}

}