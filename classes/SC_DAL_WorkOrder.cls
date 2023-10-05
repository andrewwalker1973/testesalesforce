/**
 * @description Public class to query Work Order object records
 *
 * @see WorkOrder
 *
 * @author mthobisi.ndlovu@accenture.com, vijay.jayswal@accenture.com
 *
 * @date February 2023
 */
public inherited sharing class SC_DAL_WorkOrder
{
	/**
	 * @description stores the Object API name of Work Order
	 */
	public static final String OBJECT_NAME = WorkOrder.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getLocalName();

	/**
	 * @description stores the Case Id
	 */
	private static final String FIELD_CASE_ID = WorkOrder.CaseId.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_CASE_ID
		};
	}
	/**
	 * @description The method retrieves WorkOrder by Case Id
	 *
	 * @param caseId ID of case  related to the WorkOrder
	 *
	 * @return A list of WorkOrder
	 */
	public static WorkOrder findByCaseId(Id caseId)
	{
		return (WorkOrder)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_CASE_ID, caseId, getDefaultFields());
	}
}