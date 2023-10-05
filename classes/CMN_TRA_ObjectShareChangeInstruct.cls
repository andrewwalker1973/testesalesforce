/**
 * @description Trigger handler on the Shared Object Change Instruction Platform Event
 *
 * @see CMN_TRA_ObjectShareChangeInstruct_TEST
 * @see CMN_ObjectShareChangeInstruction__e
 *
 * @author jason.van.beukering@accenture.com prashant.k.jain@accenture.com
 *
 * @date July 2022
 */
public inherited sharing class CMN_TRA_ObjectShareChangeInstruct extends CMN_TRA_BaseObject implements CMN_TRA_Interfaces.CMN_INT_AfterInsert
{
	/**
	 * @description Will ensure that the event raised insert the appropriate shareObject
	 *
	 * @param insertedEvents The platform event insert
	 */
	public void afterInsert(List<CMN_ObjectShareChangeInstruction__e> insertedEvents)
	{
		createShares(insertedEvents);
	}

	/**
	 * @description Will add a new share record for the shareObject
	 *
	 * @param insertedEvents List of platform events
	 */
	private static void createShares(List<CMN_ObjectShareChangeInstruction__e> insertedEvents)
	{
		List<SObject> apexShares = new List<SObject>();

		for(CMN_ObjectShareChangeInstruction__e shareEvent : insertedEvents)
		{
			SObject shareObject = CMN_DAL_DataFactory.newSObjectShare
					(
							shareEvent.CMN_ObjectId__c,
							shareEvent.CMN_AccessLevel__c,
							shareEvent.CMN_ShareWith__c
					);

			apexShares.add(shareObject);
		}

		CMN_DAL_SObjectDomain.insertDBObjects(apexShares, false);
	}
}