/**
 * @description Controller used to search records for an SObject
 *
 * @see SC_CTRL_CustomLookup_TEST @story ST-133715
 *
 * @author aakriti.a.goyal@accenture.com
 *
 * @date June 2021
 */
public inherited sharing class SC_CTRL_CustomLookup
{
	/**
	 * @description Will query SObject records based on the filter & search keyword
	 *
	 * @param searchTerm The search keyword
	 * @param sObjectName The name of the SObject
	 * @param searchField The field to be searched
	 * @param filterCriteria The filter conditions
	 *
	 * @return A list of SObject
	 */
	@AuraEnabled(Cacheable=true)
	public static List<SObject> fetchLookupData(String searchTerm, String sObjectName, String searchField, String filterCriteria)
	{
		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		if(String.isNotBlank(searchTerm))
		{
			andCondition.add(new CMN_SOQL_Query.FieldCondition(searchField, CMN_SOQL_Query.Operator.LIKEX, '%' + searchTerm + '%'));
		}

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(searchField)
						.fromX(sObjectName)
						.whereX(andCondition);

		String conditionVerb = String.isNotBlank(searchTerm) ? ' AND ' : ' WHERE ';
		String query = String.isBlank(filterCriteria) ? builder.toSoql() : builder.toSoql() + conditionVerb + filterCriteria;

		return Database.query(query);
	}

	/**
	 * @description Will query selected SObject record based on the record Id
	 *
	 * @param recordId The id of the record
	 * @param searchField The field to be searched
	 *
	 * @return SObject
	 */
	@AuraEnabled(Cacheable=true)
	public static SObject fetchDefaultRecord(Id recordId, String searchField)
	{
		if(recordId != null)
		{
			Schema.SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(recordId);
			return CMN_DAL_SObjectSelector.findById(objectType.getDescribe().getLocalName(), recordId, new Set<String> {searchField});
		}

		return null;
	}
}