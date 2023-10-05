/**
 * @description Test class for AW_FLOW_GetAccountRecommendation
 *
 * @see AW_FLOW_GetAccountRecommendation
 *
 * @author prashant.k.jain@accenture.com
 *
 * @date 2021, February 2022
 */
@IsTest(SeeAllData=false IsParallel=true)
private class AW_FLOW_GetAccountRecommendation_TEST
{
	/**
	 * @description Setup method to create test data
	 */
	@TestSetup
	private static void insertTestData()
	{
		AW_DAL_TestDataFactory.createClientAccount();
	}

	/**
	 * @description Method to test the scenario for generating the recommendations for prediction model scores
	 */
	@IsTest
	private static void getRecommendations()
	{
		List<AW_AccountPropensityPredictionModel__mdt> predictionModels = AW_DAL_AccountPropensityPredictionModel.getAll();
		List<Account> accounts = AW_DAL_Account.getAll();
		Account account = accounts.iterator().next();
		List<Decimal> randomPercentages = generateRandomPercentages(predictionModels.size());
		Integer counter = 0;

		//Loop through metadata records to set prediction scores based on metadata
		for(AW_AccountPropensityPredictionModel__mdt predictionModel : predictionModels)
		{
			account.put(predictionModel.AW_ScoreFieldAPIName__c, randomPercentages.get(counter++));
		}
		update account;

		List<AW_FLOW_GetAccountRecommendation.DTO_Request> dtoRequests = getDtoRequests(account.Id);

		Test.startTest();
		List<List<Recommendation>> outputFull = AW_FLOW_GetAccountRecommendation.getRecommendations(dtoRequests);

		//Loop through metadata records to set prediction status based on metadata
		for(AW_AccountPropensityPredictionModel__mdt predictionModel : predictionModels)
		{
			//Set the status so that recommendation is not provided for it
			account.put(predictionModel.AW_StatusFieldAPIName__c, AW_DAL_AccountPropensityPredictionModel.PICK_STATUS_ACCEPTED);
		}
		update account;

		List<List<Recommendation>> outputBlank = AW_FLOW_GetAccountRecommendation.getRecommendations(dtoRequests);
		Test.stopTest();

		System.assertEquals(1, outputFull.size(), 'Size should be 1');
		List<Recommendation> recommendations = outputFull.iterator().next();
		System.assertEquals
				(
						AW_FLOW_GetAccountRecommendation.MAX_NUMBER_OF_RECOMMENDATIONS,
						recommendations.size(),
						'Size should match MAX_NUMBER_OF_RECOMMENDATIONS'
				);
		System.assertEquals
				(
						AW_FLOW_GetAccountRecommendation.ACCEPTANCE_LABEL,
						recommendations.iterator().next().AcceptanceLabel,
						'Acceptance Label should match'
				);
		System.assertEquals(AW_FLOW_GetAccountRecommendation.REJECTION_LABEL, recommendations.iterator().next().RejectionLabel, 'Rejection Label should match');
		randomPercentages.sort();
		Decimal maxScore = randomPercentages.get(randomPercentages.size() - 1);
		String maxScoreString = String.valueOf((Integer)maxScore);
		System.assert
				(
						recommendations.iterator().next().Description.contains(maxScoreString),
						'Maximum Score should be included in Description of first Recommendation'
				);
		System.assertEquals(1, outputBlank.size(), 'Size should be 1');
		System.assertEquals(0, outputBlank.iterator().next().size(), 'Size should match zero');
	}

	private static List<Decimal> generateRandomPercentages(Integer numberOfValues)
	{
		List<Decimal> randomPercentages = new List<Decimal>();
		for(Integer i = 0; i < numberOfValues; i++)
		{
			randomPercentages.add(CMN_DAL_SObjectDomain.generateRandomPercentage());
		}
		return randomPercentages;
	}

	private static List<AW_FLOW_GetAccountRecommendation.DTO_Request> getDtoRequests(Id accountId)
	{
		List<AW_FLOW_GetAccountRecommendation.DTO_Request> dtoRequests = new List<AW_FLOW_GetAccountRecommendation.DTO_Request>();
		AW_FLOW_GetAccountRecommendation.DTO_Request dtoRequest = new AW_FLOW_GetAccountRecommendation.DTO_Request();
		dtoRequest.accountId = accountId;
		dtoRequests.add(dtoRequest);

		return dtoRequests;
	}
}