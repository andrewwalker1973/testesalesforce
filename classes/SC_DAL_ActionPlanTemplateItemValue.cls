/**
 * @description Public class to return the records of ActionPlan Template Item Value
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date 2021
 */
public inherited sharing class SC_DAL_ActionPlanTemplateItemValue
{
	private static final String OBJECT_NAME = ActionPlanTemplateItemValue.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_TEMPLATE_ID = 'ActionPlanTemplateItem.ActionPlanTemplateVersion.ActionPlanTemplate.Id';
	public static final String FIELD_TEMPLATE_VERSION_ID = 'ActionPlanTemplateItem.ActionPlanTemplateVersionId';

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ActionPlanTemplateItemValue.ActionPlanTemplateItemId.getDescribe().getLocalName(),
				ActionPlanTemplateItemValue.ItemEntityFieldName.getDescribe().getLocalName(),
				ActionPlanTemplateItemValue.ValueLiteral.getDescribe().getLocalName(),
				FIELD_TEMPLATE_ID,
				FIELD_TEMPLATE_VERSION_ID
		};
	}

	/**
	 * @description This method is use to get the List of ActionPlanTemplateItemValue with the particular WorkTypeId
	 *
	 * @param templateId The record to which this item is associated
	 *
	 * @return A list of ActionPlanTemplateItemValue
	 */
	public static List<ActionPlanTemplateItemValue> findByTemplateId(Set<Id> templateId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_TEMPLATE_ID, templateId, getDefaultFields());
	}
}