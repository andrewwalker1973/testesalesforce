/**
 * @description Provides Query methods related for Trigger Action custom metadata
 *
 * @see CMN_TriggerAction__mdt
 * @see CMN_FACTORY_TriggerAction
 *
 * @author jason.van.beukering@accenture.com
 *
 * @date June 2022
 */
public inherited sharing class CMN_DAL_TriggerAction
{
	/**
	 * @description All the relationship names for trigger actions linked to a trigger setting
	 */
	private static final Set<String> TRIGGER_ACTION_RELATIONSHIP_NAMES = new Set<String>
	{
			'After_Delete_Actions__r',
			'After_Insert_Actions__r',
			'After_Undelete_Actions__r',
			'After_Update_Actions__r',
			'Before_Delete_Actions__r',
			'Before_Insert_Actions__r',
			'Before_Update_Actions__r'
	};

	private static final String FIELD_TA_BYPASS_EXECUTION = CMN_TriggerAction__mdt.Bypass_Execution__c.getDescribe().getLocalName();
	private static final String FIELD_TS_BYPASS_EXECUTION = CMN_TriggerSetting__mdt.CMN_BypassExecution__c.getDescribe().getLocalName();
	private static final String OBJECT_NAME_TRIGGER_ACTION = CMN_TriggerAction__mdt.SObjectType.getDescribe().getLocalName();
	private static final String OBJECT_NAME_TRIGGER_SETTING = CMN_TriggerSetting__mdt.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Map containing trigger actions by Object API name and Trigger Operation
	 * Map<Account, map<AFTER_INSERT, List<CMN_TriggerAction__mdt>>
	 */
	private static Map<String, Map<String, List<CMN_TriggerAction__mdt>>> triggerActionByObjectNameAndOperationMap;

	/**
	 * @description Api name for the trigger setting field bypass permission
	 */
	public static final String FIELD_TS_BYPASS_PERMISSION = CMN_TriggerSetting__mdt.CMN_BypassPermission__c.getDescribe().getLocalName();
	/**
	 * @description Api name for the trigger setting field required permission
	 */
	public static final String FIELD_TS_REQUIRED_PERMISSION = CMN_TriggerSetting__mdt.CMN_RequiredPermission__c.getDescribe().getLocalName();

	/**
	 * @description Method use to get the commonly queried fields
	 *
	 * @return A list of commonly queried CMN_TriggerAction__mdt fields
	 *
	 * @see CMN_TriggerAction__mdt
	 */
	private static Set<String> getTriggerActionFields()
	{
		return new Set<String>
		{
				CMN_TriggerAction__mdt.Allow_Flow_Recursion__c.getDescribe().getLocalName(),
				CMN_TriggerAction__mdt.Apex_Class_Name__c.getDescribe().getLocalName(),
				CMN_TriggerAction__mdt.Bypass_Permission__c.getDescribe().getLocalName(),
				CMN_TriggerAction__mdt.Description__c.getDescribe().getLocalName(),
				CMN_TriggerAction__mdt.DeveloperName.getDescribe().getLocalName(),
				CMN_TriggerAction__mdt.Flow_Name__c.getDescribe().getLocalName(),
				CMN_TriggerAction__mdt.Order__c.getDescribe().getLocalName(),
				CMN_TriggerAction__mdt.Required_Permission__c.getDescribe().getLocalName(),
				FIELD_TA_BYPASS_EXECUTION
		};
	}

	/**
	 * @description Method use to get the commonly queried fields
	 *
	 * @return A list of commonly queried CMN_TriggerSetting__mdt fields
	 *
	 * @see CMN_TriggerSetting__mdt
	 */
	private static Set<String> getTriggerSettingFields()
	{
		return new Set<String>
		{
				FIELD_TS_BYPASS_PERMISSION,
				CMN_TriggerSetting__mdt.CMN_ObjectApiName__c.getDescribe().getLocalName(),
				FIELD_TS_REQUIRED_PERMISSION,
				FIELD_TS_BYPASS_EXECUTION
		};
	}

	/**
	 * @description Method will find trigger action custom metadata record that is active based on object api name and database trigger operation
	 *
	 * @param objectName API name of the object
	 * @param operation Operation on which to filter records
	 *
	 * @return items found
	 */
	public static List<CMN_TriggerAction__mdt> findActiveByObjectNameAndTriggerOperation(String objectName, TriggerOperation operation)
	{
		if(triggerActionByObjectNameAndOperationMap == null)
		{
			triggerActionByObjectNameAndOperationMap = new Map<String, Map<String, List<CMN_TriggerAction__mdt>>>();

			CMN_DAL_Search.SOQLSearchParameters triggerSettingParameters =
					new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME_TRIGGER_SETTING, getTriggerSettingFields());
			triggerSettingParameters.searchConditions.equalsX(FIELD_TS_BYPASS_EXECUTION, false);

			for(String relationshipName : TRIGGER_ACTION_RELATIONSHIP_NAMES)
			{
				CMN_DAL_Search.SOQLSearchParameters triggerActionParameters =
						new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME_TRIGGER_ACTION, getTriggerActionFields(), relationshipName);
				triggerActionParameters.searchConditions.equalsX(FIELD_TA_BYPASS_EXECUTION, false);

				triggerSettingParameters.childSearchParameters.add(triggerActionParameters);
			}

			List<CMN_TriggerSetting__mdt> foundSettings = CMN_DAL_Search.getObjects(triggerSettingParameters);

			for(CMN_TriggerSetting__mdt foundSetting : foundSettings)
			{
				Map<String, List<CMN_TriggerAction__mdt>> actionByOperationMap =
						triggerActionByObjectNameAndOperationMap.get(foundSetting.CMN_ObjectApiName__c);

				if(actionByOperationMap == null)
				{
					actionByOperationMap = new Map<String, List<CMN_TriggerAction__mdt>>();
					triggerActionByObjectNameAndOperationMap.put(foundSetting.CMN_ObjectApiName__c, actionByOperationMap);
				}

				addToActionByOperationsMap(foundSetting, actionByOperationMap, foundSetting.After_Delete_Actions__r, TriggerOperation.AFTER_DELETE);
				addToActionByOperationsMap(foundSetting, actionByOperationMap, foundSetting.After_Insert_Actions__r, TriggerOperation.AFTER_INSERT);
				addToActionByOperationsMap(foundSetting, actionByOperationMap, foundSetting.After_Undelete_Actions__r, TriggerOperation.AFTER_UNDELETE);
				addToActionByOperationsMap(foundSetting, actionByOperationMap, foundSetting.After_Update_Actions__r, TriggerOperation.AFTER_UPDATE);
				addToActionByOperationsMap(foundSetting, actionByOperationMap, foundSetting.Before_Delete_Actions__r, TriggerOperation.BEFORE_DELETE);
				addToActionByOperationsMap(foundSetting, actionByOperationMap, foundSetting.Before_Insert_Actions__r, TriggerOperation.BEFORE_INSERT);
				addToActionByOperationsMap(foundSetting, actionByOperationMap, foundSetting.Before_Update_Actions__r, TriggerOperation.BEFORE_UPDATE);
			}
		}

		List<CMN_TriggerAction__mdt> triggerActions = triggerActionByObjectNameAndOperationMap.get(objectName)?.get(operation.name());

		return triggerActions == null ? new List<CMN_TriggerAction__mdt>() : triggerActions;
	}

	/**
	 * @description Will add the trigger actions provided into the map based on the operation provided
	 *
	 * @param foundSetting The setting for the trigger actions provided, will be used to check permissions
	 * @param actionByOperationMap A map of trigger actions by Operation
	 * @param triggerActions Trigger Actions (may be null) that should be added to the map
	 * @param operation The operation that the actions support
	 */
	private static void addToActionByOperationsMap
			(
					CMN_TriggerSetting__mdt foundSetting,
					Map<String, List<CMN_TriggerAction__mdt>> actionByOperationMap,
					List<CMN_TriggerAction__mdt> triggerActions,
					TriggerOperation operation
			)
	{
		if(triggerActions == null || triggerActions.isEmpty())
		{
			return;
		}

		List<CMN_TriggerAction__mdt> actionsInMap = actionByOperationMap.get(operation.name());

		if(actionsInMap == null)
		{
			actionsInMap = new List<CMN_TriggerAction__mdt>();
			actionByOperationMap.put(operation.name(), actionsInMap);
		}

		for(CMN_TriggerAction__mdt triggerAction : triggerActions)
		{
			if(shouldExecute(foundSetting, triggerAction))
			{
				actionsInMap.add(triggerAction);
			}
		}
	}

	/**
	 * @description Will determine (based on custom permission names) if the provided action should be allowed action
	 *
	 * @param triggerSetting The Trigger setting associated with the provided triggerAction
	 * @param triggerAction The action whose custom permissions (if any) should be checked
	 *
	 * @return True if he action can be executed
	 */
	private static Boolean shouldExecute(CMN_TriggerSetting__mdt triggerSetting, CMN_TriggerAction__mdt triggerAction)
	{
		Boolean shouldExecute = true;

		Boolean bypass = FeatureManagement.checkPermission(triggerAction.Bypass_Permission__c)
				|| FeatureManagement.checkPermission(triggerSetting.CMN_BypassPermission__c);

		shouldExecute = !bypass &&
				(String.isBlank(triggerSetting.CMN_RequiredPermission__c) || FeatureManagement.checkPermission(triggerSetting.CMN_RequiredPermission__c));
		shouldExecute = shouldExecute &&
				(String.isBlank(triggerAction.Required_Permission__c) || FeatureManagement.checkPermission(triggerAction.Required_Permission__c));

		return shouldExecute;
	}
}