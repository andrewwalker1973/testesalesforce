/**
* @description Used by Lightning Component to retrieve Activity Measure info
 *
 * @see AW_TEST_CTR_ProductionMeasures @story ST-3928
 *
 * @author Accenture
 *
* @date 2020
*/
public inherited sharing class AW_CTR_ProductionMeasures
{
	@TestVisible
	private static final String RECORD_AVAILABLE_LABEL = 'Not Available';

    /**
	* @description   	Used by LWC to retrieve the latest production measures linked to the logged in user.
	*					Seperate queries done due to data issues.
    *
	* @return       	Returns DTO_ProductionMeasure 
	*/
	@AuraEnabled(Cacheable=true)
	public static DTO_ProductionMeasure getLatestAdviserPerformance()
	{
		String currentUserUACFID = AW_DAL_User.getCurrentUser().AW_UACFID__c;
		DTO_ProductionMeasure dtoProductionMeasure = new DTO_ProductionMeasure();

		AW_AdviserPerformance__c latestId = AW_DAL_AdviserPerformance.findLatestByUACFID(currentUserUACFID);
		AW_AdviserPerformance__c latestClubStatus = AW_DAL_AdviserPerformance.findLatestWithProductionClubStatusByUACFID(currentUserUACFID);
		AW_AdviserPerformance__c latestTenure = AW_DAL_AdviserPerformance.findLatestWithTenureByUACFID(currentUserUACFID);
		AW_AdviserPerformance__c latestAQC = AW_DAL_AdviserPerformance.findLatestWithAQCByUACFID(currentUserUACFID);


		AW_AdviserPerformance__c latestSatisfactionScore = AW_DAL_AdviserPerformance.findLatestByUACFID(currentUserUACFID);


		
        dtoProductionMeasure.productionMeasureId = latestId == null ? RECORD_AVAILABLE_LABEL :latestId.Id;
        dtoProductionMeasure.productionMeasureClubStatus = latestClubStatus == null ? RECORD_AVAILABLE_LABEL : latestClubStatus.AW_LastYearsProductionClubStatus__c;
        dtoProductionMeasure.productionMeasureTenure = latestTenure == null ? RECORD_AVAILABLE_LABEL : latestTenure.AW_LAPExpTenure__c;
        dtoProductionMeasure.productionMeasureAQC = latestAQC == null ? RECORD_AVAILABLE_LABEL : latestAQC.AW_AverageFAVP__c;
		dtoProductionMeasure.productionMeasureSatisfactionScore = latestSatisfactionScore.AW_ClientSatisfactionScore__c;

		return dtoProductionMeasure;
	}
    
 	/**
	* @description Wrapper class is use to store the Production Measure values required by the LWC component
	*/
	public class DTO_ProductionMeasure
	{
		@AuraEnabled
		public String productionMeasureId;
		@AuraEnabled
		public String productionMeasureClubStatus;
		@AuraEnabled
		public String productionMeasureTenure;
		@AuraEnabled
		public String productionMeasureAQC;
		@AuraEnabled
		public Decimal productionMeasureSatisfactionScore;
	}

}