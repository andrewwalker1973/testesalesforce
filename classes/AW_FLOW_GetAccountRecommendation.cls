/**
 * @description This class is used to generate the Einstein Next Best Action Recommendations
 *
 * @see AW_FLOW_GetAccountRecommendation_TEST
 *
 * @author Accenture
 *
 * @date Jun-2021
 */
public inherited sharing class AW_FLOW_GetAccountRecommendation
{
	@TestVisible
	private final static Integer MAX_NUMBER_OF_RECOMMENDATIONS = 4;
	@TestVisible
	private final static String ACCEPTANCE_LABEL = 'Use this Recommendation';
	private final static String DESCRIPTION_PATTERN = 'Based on the last FNA performed, we recommend the {0} that has a confidence score of {1}';
	@TestVisible
	private final static String REJECTION_LABEL = 'No Thanks';
	private static Map<String, SObject> contentAssetsByName;
	private static Map<String, SObject> predictionModelByName;

	/**
	 * @description This invocable method is used in Einstein Next Best Action Recommendations
	 *
	 * @param dtoRequests List of DTO_Request which contains the account ids
	 *
	 * @return List<List<Recommendations>>
	 */
	@InvocableMethod(Label='Account Recommendation Generator' Description='This function returns recommendations for the score generated from Einstein models.')
	public static List<List<Recommendation>> getRecommendations(List<DTO_Request> dtoRequests)
	{
		List<List<Recommendation>> outputs = new List<List<Recommendation>>();
		Set<Id> accountIds = new Set<Id>();
		List<AW_AccountPropensityPredictionModel__mdt> predictionModels = AW_DAL_AccountPropensityPredictionModel.getAll();
		predictionModelByName = CMN_UTIL_System.convertListToSingleStringMap(predictionModels, AW_DAL_AccountPropensityPredictionModel.FIELD_DEVELOPER_NAME);
		Set<String> imageNames = CMN_UTIL_System.extractSetValues(predictionModels, AW_DAL_AccountPropensityPredictionModel.FIELD_IMAGE_ID);
		contentAssetsByName = CMN_UTIL_System.convertListToSingleStringMap(AW_DAL_ContentAsset.findByDeveloperName(imageNames), AW_DAL_AccountPropensityPredictionModel.FIELD_DEVELOPER_NAME);

		for(DTO_Request request : dtoRequests)
		{
			accountIds.add(request.accountId);
		}
		Map<Id, Account> accountsById = new Map<Id, Account>(AW_DAL_Account.findPredictionScoresById(accountIds));

		//Looping through dtoRequests rather than accounts to maintain the order of accounts in the input
		for(DTO_Request request : dtoRequests)
		{
			Account account = accountsById.get(request.accountId);
			List<GeneratedScoresWrapper> generatedScores = new List<GeneratedScoresWrapper>();

			//Loop through metadata records to get field values based on metadata
			for(AW_AccountPropensityPredictionModel__mdt predictionModel : predictionModels)
			{
				Decimal predictionScore = (Decimal)account.get(predictionModel.AW_ScoreFieldAPIName__c);
				String recommendationStatus = (String)account.get(predictionModel.AW_StatusFieldAPIName__c);

				if(predictionScore > 0 && String.isBlank(recommendationStatus))
				{
					//Add GeneratedScoresWrapper to list to be able to sort
					GeneratedScoresWrapper generatedScore = new GeneratedScoresWrapper(predictionScore, predictionModel.DeveloperName);
					generatedScores.add(generatedScore);
				}
			}

			generatedScores.sort();

			Integer counter = 0;
			List<Recommendation> recommendations = new List<Recommendation>();

			for(GeneratedScoresWrapper generatedScore : generatedScores)
			{
				recommendations.add(createRecommendation(generatedScore.predictionScore, generatedScore.metadataDeveloperName));
				if(++counter == MAX_NUMBER_OF_RECOMMENDATIONS)
				{
					//Break the loop once maximum number of recommendations have been added
					break;
				}
			}
			outputs.add(recommendations);
		}

		return outputs;
	}

	/**
	 * @description This method creates new recommendations record on the fly
	 *
	 * @param predictionScore Prediction score value
	 * @param metadataDeveloperName Name of the custom metadata record
	 *
	 * @return recommendation
	 */
	public static Recommendation createRecommendation(Decimal predictionScore, String metadataDeveloperName)
	{
		AW_AccountPropensityPredictionModel__mdt predictionModel = (AW_AccountPropensityPredictionModel__mdt)predictionModelByName.get(metadataDeveloperName);

		Recommendation recommendation = new Recommendation();
		recommendation.AcceptanceLabel = ACCEPTANCE_LABEL;
		recommendation.RejectionLabel = REJECTION_LABEL;
		recommendation.ActionReference = predictionModel.AW_FlowName__c;
		recommendation.Name = predictionModel.Label;
		recommendation.ImageId = contentAssetsByName.get(predictionModel.AW_ImageId__c).Id;
		recommendation.Description = String.format(DESCRIPTION_PATTERN, new List<String> {predictionModel.Label, String.valueOf((Integer)predictionScore)});

		return recommendation;
	}

	/**
	 * @description Inner class to be able to store and sort recommendations based on prediction score in descending order
	 */
	private class GeneratedScoresWrapper implements Comparable
	{
		public Decimal predictionScore;
		public String metadataDeveloperName;

		public GeneratedScoresWrapper(Decimal predictionScore, String metadataDeveloperName)
		{
			this.predictionScore = predictionScore;
			this.metadataDeveloperName = metadataDeveloperName;
		}

		public Integer compareTo(Object compareTo)
		{
			GeneratedScoresWrapper compareToObject = (GeneratedScoresWrapper)compareTo;
			if(predictionScore > compareToObject.predictionScore)
			{
				return -1;
			}
			else
			{
				return 1;
			}
		}
	}

	/**
	 * @description This class contains the invocable variable for Account Id to be used in Next Best Action
	 */
	public class DTO_Request
	{
		@InvocableVariable(Label='Account Id' Description='Id of the account for which recommendations are needed' Required=true)
		public String accountId;
	}
}