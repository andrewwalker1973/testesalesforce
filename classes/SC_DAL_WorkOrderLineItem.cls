/**
 * @description Public class to query Work Order Line Items
 *
 * @see WorkOrderLineItem
 *
 * @author vijay.jayswal@accenture.com
 *
 * @date February 2023
 */
public inherited sharing class SC_DAL_WorkOrderLineItem
{
	/**
	 * @description Object API name of the WorkOrderLineItem object
	 */
	public static final String OBJECT_NAME = WorkOrderLineItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();
	/**
	 * @description stores the Blood Requirement picklist value on WorkOrderLineItem
	 */
	public static final String BLOOD_REQUIREMENT = 'Blood Urea Nitrogen';
	/**
	 * @description stores the WorkOrderId Id
	 */
	private static final String FIELD_WORK_ORDER_ID = WorkOrderLineItem.WorkOrderId .getDescribe().getLocalName();
	/**
	 * @description stores the WorkOrderId Id
	 */
	private static final String FIELD_MEDICAL_REQ = WorkOrderLineItem.SC_MedicalRequirement__c .getDescribe().getLocalName();

	/**
	 * @description Will return the common fields used by all queries
	 *
	 * @return List of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_WORK_ORDER_ID,
				FIELD_MEDICAL_REQ
		};
	}

	/**
	 * @description The method retrieves WorkOrderLineItem by workOrder Id
	 *
	 * @param workOrderIds A set of object Ids related to the WorkOrder
	 *
	 * @return A list of items found
	 */
	public static List<WorkOrderLineItem> findByWorkOrderId(Set<Id> workOrderIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_WORK_ORDER_ID, workOrderIds, getDefaultFields());
	}
}