/**
 * @description Public class to return the records of Prediction Model metadata
 *
 * @see AW_FLOW_GetAccountRecommendation_TEST
 *
 * @author Accenture
 *
 * @date Jul 2021
 */
public inherited sharing class AW_DAL_AccountPropensityPredictionModel
{
	public static final String FIELD_DEVELOPER_NAME = AW_AccountPropensityPredictionModel__mdt.DeveloperName.getDescribe().getLocalName();
	public static final String FIELD_IMAGE_ID = AW_AccountPropensityPredictionModel__mdt.AW_ImageId__c.getDescribe().getLocalName();
	public static final String PICK_STATUS_ACCEPTED = 'Accepted';

	/**
	 * @description This method is use to get the list of all Prediction Model metadata records
	 *
	 * @return List of Prediction Model metadata
	 */
	public static List<AW_AccountPropensityPredictionModel__mdt> getAll()
	{
		return AW_AccountPropensityPredictionModel__mdt.getAll().values();
	}
}