/**
 * @description Public class to return the records of ActionPlan Template Item Value
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date 2021
 */
public inherited sharing class SC_DAL_ActionPlanTemplateVersion
{
	private static final String FIELD_TEMPLATE_ID = ActionPlanTemplateVersion.ActionPlanTemplateId.getDescribe().getLocalName();
	private static final String OBJECT_NAME = ActionPlanTemplateVersion.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ActionPlanTemplateVersion.Id.getDescribe().getLocalName(),
				FIELD_TEMPLATE_ID
		};
	}

	/**
	 * @description This method is use to get the List of ActionPlanTemplateVersion with the particular ActionPlanTemplate
	 *
	 * @param templateId The record to which this item is associated
	 *
	 * @return A list of ActionPlanTemplateVersion
	 */
	public static List<ActionPlanTemplateVersion> findByTemplateId(Set<Id> templateId)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_TEMPLATE_ID, templateId, getDefaultFields());
	}
}