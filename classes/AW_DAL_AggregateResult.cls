/**
 * @description Mocking Class for Aggregate Results
 *
 * @see AW_DAL_SurveyQuestionResponse
 *
 * @author Deloitte
 *
 * @date 2020
 */
public with sharing class AW_DAL_AggregateResult
{
	public static List<AW_DAL_AggregateResult> query(List<AggregateResult> results)
	{
		return service.convert(results);
	}

	final Map<String, Object> data;
	public AW_DAL_AggregateResult(AggregateResult result)
	{
		data = result.getPopulatedFieldsAsMap();
	}
	public Object get(String alias)
	{
		return data.get(alias);
	}

	@TestVisible AW_DAL_AggregateResult()
	{
		data = new Map<String, Object>();
	}
	@TestVisible AW_DAL_AggregateResult put(String alias, Object value)
	{
		data.put(alias, value);
		return this;
	}

	private static Service service = new Service();

	@TestVisible
	private static void setMock(Service mock)
	{
		service = mock;
	}

	@TestVisible
	private virtual class Service
	{
		protected virtual List<AW_DAL_AggregateResult> convert(List<AggregateResult> results)
		{
			List<AW_DAL_AggregateResult> aggregates = new List<AW_DAL_AggregateResult>();
			for(AggregateResult result : results)
			{
				aggregates.add(new AW_DAL_AggregateResult(result));
			}
			return aggregates;
		}
	}
}