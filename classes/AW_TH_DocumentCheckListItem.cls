/**
 * @description Trigger handler for the document checklist item.
 *
 * @see AW_TRG_Envelope
 * @see AW_TH_DocumentCheckListItem_TEST
 * @author nihal.desai@accenture.com jason.van.beukering@accenture.com
 *
 * @date 2021, February 2022
 */
public inherited sharing class AW_TH_DocumentCheckListItem extends CMN_TRH_BaseObject
{
	private List<DocumentChecklistItem> newItems = Trigger.new;
	private List<DocumentChecklistItem> oldItems = Trigger.old;
	private Map<Id, AW_Envelope__c> envelopeMap = new Map<Id, AW_Envelope__c>();
	private User currentUser;
	private static final String ERROR_PREVENT_DELETE = 'Documents which have already been submitted may not be deleted';
	private static final String ERROR_PREVENT_INSERT = 'New DocumentChecklist Item can only be created when Envelope status is New';

	/**
	 * @description Will initialise variables required for later processing
	 */
	private void initialiseVariables()
	{
		List<DocumentChecklistItem> checklistItems = new List<DocumentChecklistItem>();

		if(Trigger.isDelete)
		{
			checklistItems = oldItems;
		}
		else if(Trigger.isInsert)
		{
			currentUser = AW_DAL_User.getCurrentUser();
			checklistItems = newItems;
		}

		Set<Id> envelopeIds = new Set<Id>();

		for(DocumentChecklistItem checkListItem : checklistItems)
		{
			//We only care if the parent is an envelope
			if(CMN_UTIL_System.getSObjectTypeById(checkListItem.ParentRecordId) == AW_Envelope__c.SObjectType)
			{
				envelopeIds.add(checkListItem.ParentRecordId);
			}
		}

		//No point in running a query if none of the parent objects are envelopes
		if(!envelopeIds.isEmpty())
		{
			envelopeMap.putAll(AW_DAL_Envelope.findById(envelopeIds));
		}
	}

	/**
	 * @description Will check if the parent object is envelope with status of new and then prevent delete
	 *
	 * @param anObject a checklist item
	 */
	private void setErrorStatus(SObject anObject)
	{
		DocumentChecklistItem checkListItem = (DocumentChecklistItem)anObject;

		//No point processing further if map is empty
		if(!envelopeMap.isEmpty())
		{
			AW_Envelope__c envelope = envelopeMap.get(checkListItem.ParentRecordId);

			if(!AW_DAL_Envelope.STATUS_NEW.equalsIgnoreCase(envelope.AW_Status__c))
			{
				checkListItem.addError(Trigger.isDelete ? ERROR_PREVENT_DELETE : ERROR_PREVENT_INSERT);
			}
		}
	}

	/**
	 * @description Process all items to collect Ids to do a bulk query and use the results to determine if an invalid delete is being performed
	 */
	public override void bulkBefore()
	{
		initialiseVariables();
	}

	/**
	 * @description React to object being deleted and check if it should be prevented
	 *
	 * @param so object being deleted
	 */
	public override void beforeDelete(SObject so)
	{
		super.beforeDelete(so);
		setErrorStatus(so);
	}

	/**
	 * @description React to object being inserted if the Envelope Status is New
	 *
	 * @param so object being deleted
	 */
	public override void beforeInsert(SObject so)
	{
		super.beforeInsert(so);
		setErrorStatus(so);
		setDocumentChecklistItemOwner((DocumentChecklistItem)so);
	}

	/**
	 * @description Will update the owner of the object to Parent Account Owner
	 *
	 * @param newDocumentChecklistItem A DocumentChecklistItem that's needs to be assigned to Parent Account Owner
	 */
	private void setDocumentChecklistItemOwner(DocumentChecklistItem newDocumentChecklistItem)
	{
		if((AW_DAL_Profile.PROFILE_PERSONAL_ASSISTANT.equalsIgnoreCase(currentUser.Profile.Name)) &&
				(CMN_UTIL_System.getSObjectTypeById(newDocumentChecklistItem.ParentRecordId) == AW_Envelope__c.SObjectType))
		{
			newDocumentChecklistItem.OwnerId = envelopeMap.get(newDocumentChecklistItem.ParentRecordId).OwnerId;
		}
	}

}