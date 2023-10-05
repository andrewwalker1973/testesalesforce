/**
 * @description Public class to return the records of ActionPlan Template Item Value
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date 2021
 */
public inherited sharing class SC_DAL_ActionPlanTemplateItem
{
	private static final String FIELD_TEMPLATE_ID = 'ActionPlanTemplateVersion.ActionPlanTemplate.Id';
	private static final String OBJECT_NAME = ActionPlanTemplateItem.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ActionPlanTemplateItem.Id.getDescribe().getLocalName(),
				ActionPlanTemplateItem.ActionPlanTemplateVersionId.getDescribe().getLocalName(),
				FIELD_TEMPLATE_ID
		};
	}

	/**
	 * @description This method is use to get the List of ActionPlanTemplateItemValue with the particular WorkTypeId
	 *
	 * @param templateId The record to which this item is associated
	 *
	 * @return A list of ActionPlanTemplateItemValue
	 */
	public static List<ActionPlanTemplateItem> findByTemplateId(Set<Id> templateId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_TEMPLATE_ID, templateId, getDefaultFields());
	}
}