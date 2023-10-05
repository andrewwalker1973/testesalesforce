/**
 * @description Public class to return the record of Feature Switch
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class AW_DAL_FeatureSwitches
{

	/**
	 * @description This method is to get the record of Feature switch.
	 *
	 * @param instanceId
	 *
	 * @return instanceId
	 */
	public static AW_FeatureSwitches__c getFeatureSwitch(Id instanceId)
	{
		return instanceId == null ? AW_FeatureSwitches__c.getInstance() : AW_FeatureSwitches__c.getInstance(instanceId);
	}

	/**
	 * @description This method is to check the adviser targer
	 */
	public static Boolean adviserTargetsEnabled
	{
		get
		{
			return getFeatureSwitch(null).AW_AdviserTargetsOn__c == true ? true : false;
		}
	}
}