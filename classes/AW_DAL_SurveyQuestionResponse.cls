/**
 * @description Retrieves survey responses statistics
 *
 * @author Deloitte
 *
 * @date 2020
 */
public class AW_DAL_SurveyQuestionResponse
{
	private static final String QUESTION_TYPE_RATING = 'Rating';

	/**
	 * @description This method is used to return list of AW_DAL_AggregateResult with Average Satisfaction Score
	 * calculated from SurveyQuestionResponses for Questions of type Rating grouped by Survey Invitation creator UACFID
	 * and filtered by Survey Invitation creator UACFID and Survey Invitation creation date
	 *
	 * @param uacfids list of UACFIDs of Survey Invitations creators to filter by
	 * @param surveyName name of Survey to retrieve responses for
	 * @param startDate start date used to filter on Survey Invitation creation date
	 * @param endDate end date used to filter on Survey Invitation creation date
	 *
	 * @return adviser's performance records
	 */
	public static List<AW_DAL_AggregateResult> getAverageSatisfactionScoresGroupedByUacfid(Set <String> uacfids, String surveyName, Date startDate, Date endDate)
	{
		return AW_DAL_AggregateResult.query
				(
				[
						SELECT AVG(NumberValue) avgSatisfactionScore,
								Invitation.CreatedBy.AW_UACFID__c uacfid
						FROM SurveyQuestionResponse
						WHERE Question.QuestionType = :QUESTION_TYPE_RATING
						AND SurveyVersion.Survey.Name = :surveyName
						AND Invitation.CreatedBy.AW_UACFID__c IN :uacfids
						AND Invitation.CreatedDate >= :startDate
						AND Invitation.CreatedDate < :endDate
						AND NumberValue != NULL
						AND Invitation.CreatedBy.AW_UACFID__c != NULL
						GROUP BY Invitation.CreatedBy.AW_UACFID__c
				]
				);
	}

}