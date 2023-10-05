/**
 * @description Selector Class for Service Type information
 *
 * @see SC_ServiceType__c
 *
 * @author vijay.jayswal@accenture.com uttpal.chandra@accenture.com
 *
 * @date March 2023
 */
public inherited sharing class SC_DAL_ServiceType
{
	/**
	 * @description stores the field APIName of Name of the ServiceType
	 */
	
	public static final String FIELD_NAME = SC_ServiceType__c.Name.getDescribe().getLocalName();
	/**
	 * @description stores the field APIName of Department of the ServiceType
	 */
	
	public static final String FIELD_PROCESS_NAME = SC_ServiceType__c.SC_Department__c.getDescribe().getLocalName();
	/**
	 * @description stores the field APIName of Code of the ServiceType
	 */
	public static final String FIELD_SERVICE_TYPE_CODE = SC_ServiceType__c.SC_ServiceType__c.getDescribe().getLocalName();
	/**
	 * @description stores the Object APIName of the ServiceType
	 */
	public static final String OBJECT_NAME = SC_ServiceType__c.SObjectType.getDescribe().getLocalName();
	/**
	 * @description stores the field APIName of Assignable of the ServiceType
	 */
	public static final String FIELD_ASSIGNABLE = SC_ServiceType__c.SC_Assignable__c.getDescribe().getLocalName();
	/**
	 * @description stores the field APIName of Code of the ServiceType
	 */
	public static final String FIELD_WORK_TYPE = SC_ServiceType__c.SC_WorkType__c.getDescribe().getLocalName();
	/**
	 * @description stores the Object APIName of the KnowledgeArticleId
	 */
	public static final String FIELD_KNOWLEDGE_ARTICLE_ID = 'SC_KnowledgeArticle__r.KnowledgeArticleId';
	/**
	 * @description stores the Object APIName of the IsLatestVersion
	 */
	public static final String FIELD_KNOWLEDGE_ARTICLE_IS_LATEST_VERSION = 'SC_KnowledgeArticle__r.IsLatestVersion';
	/**
	 * @description stores the field APIName of Next Action on case creation of the ServiceType
	 */
	private static final String FIELD_NEXT_ACTION_ON_CASE_CREATION = SC_ServiceType__c.SC_NextActionOnCaseCreationScreen__c.getDescribe().getLocalName();
	/**
	 * @description stores the field APIName of work order record type from work type object
	 */
	private static final String FIELD_WORK_ORDER_RECORD_tYPE = 'SC_ServiceType__c.SC_WorkType__r.SC_WorkOrderRecordType__c';
	/**
	 * @description stores the field APIName of work order line item record type from work type object
	 */
	private static final String FIELD_WORK_ORDER_LINE_ITEM_RECORD_TYPE = 'SC_ServiceType__c.SC_WorkType__r.SC_WorkOrderLineItemRecordType__c';


	/**
	 * @description Method to define the fields to retrieve for most query's
	 *
	 * @return A list of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_NAME,
				FIELD_NEXT_ACTION_ON_CASE_CREATION,
				FIELD_PROCESS_NAME,
				FIELD_SERVICE_TYPE_CODE,
				FIELD_ASSIGNABLE,
				FIELD_WORK_TYPE,
				FIELD_KNOWLEDGE_ARTICLE_ID,
				FIELD_KNOWLEDGE_ARTICLE_IS_LATEST_VERSION,
				SC_ServiceType__c.RSC_AssociatedContractExtensionFieldSet__c.getDescribe().getLocalName(),
				SC_ServiceType__c.RSC_CaseExtensionFieldSet__c.getDescribe().getLocalName(),
				SC_ServiceType__c.SC_AssociatedContractExtCreationFieldSet__c.getDescribe().getLocalName(),
				SC_ServiceType__c.SC_AssociatedContractExtRecordType__c.getDescribe().getLocalName(),
				SC_ServiceType__c.SC_CaseExtensionCreationFieldSet__c.getDescribe().getLocalName(),
				SC_ServiceType__c.SC_CaseExtensionRecordType__c.getDescribe().getLocalName(),
				SC_ServiceType__c.SC_KnowledgeArticle__c.getDescribe().getLocalName(),
				FIELD_WORK_ORDER_RECORD_tYPE,
				FIELD_WORK_ORDER_LINE_ITEM_RECORD_TYPE
		};
	}

	/**
	 * @description This method is used to get all distinct departments from service types
	 *
	 * @return list of all departments
	 */
	public static List<String> findAllDepartments()
	{

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(
				OBJECT_NAME
		);
		searchParameters.setSecurityEnforced(false);
		searchParameters.clearSelectFields();
		searchParameters.clearSearchFields();
		searchParameters.selectFields.add('COUNT(Id)');
		searchParameters.selectFields.add(FIELD_PROCESS_NAME);
		searchParameters.groupBy = FIELD_PROCESS_NAME;
		List<AggregateResult> getQueryAggregates = CMN_DAL_Search.getQueryAggregate(searchParameters);
		List<String> departments = new List<String>();
		for(AggregateResult results : getQueryAggregates)
		{
			departments.add(String.valueOf(results.get(FIELD_PROCESS_NAME)));
		}
		return departments;
	}

	/**
	 * @description Will return all Service Types created by unit tests
	 *
	 * @return A list of Service Types
	 */
	@TestVisible
	private static List<SC_ServiceType__c> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

	/**
	 * @description This method is use to get the Service type with the service type code
	 *
	 * @param serviceTypeCodes Service type numbers
	 *
	 * @return A list of Items
	 */
	public static List<SC_ServiceType__c> findByServiceTypeCodes(Set<Integer> serviceTypeCodes)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME, getDefaultFields());
		searchParameters.searchConditions.inX(FIELD_SERVICE_TYPE_CODE, CMN_UTIL_Set.integerToObject(serviceTypeCodes));
		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get a Service Type with the particular Id
	 *
	 * @param recordId The record of the Service Type
	 *
	 * @return Service Type
	 */
	public static SC_ServiceType__c findById(Id recordId)
	{
		return (SC_ServiceType__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordId, getDefaultFields());
	}

	/**
	 * @description Will find a list of ServiceType by Id
	 *
	 * @param recordIds The Set of ServiceType Ids to retrieve
	 *
	 * @return List of ServiceType
	 */
	public static List<SC_ServiceType__c> findById(Set<Id> recordIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordIds, getDefaultFields());
	}
}