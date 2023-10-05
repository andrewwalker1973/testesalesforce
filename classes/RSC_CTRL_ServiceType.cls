/**
 * @description Public class to return the record of Service Types
 *
 * @see RSC_CTRL_ServiceType_TEST @story ST-133715
 *
 * @author aakriti.a.goyal@accenture.com kushal.a.garg@accenture.com
 *
 * @date June 2021 June 2022
 */
public inherited sharing class RSC_CTRL_ServiceType
{
	/**
	 * @description This method is used to get all distinct departments from Service Types
	 *
	 * @return list of all departments
	 */
	@AuraEnabled(Cacheable=true)
	public static List<String> findAllDepartments()
	{
		return SC_DAL_ServiceType.findAllDepartments();
	}

	/**
	 * @description This method is used to get service type by record id
	 *
	 * @return found service type
	 */
	@AuraEnabled
	public static SC_ServiceType__c findServiceTypeById(Id recordId)
	{
		return SC_DAL_ServiceType.findById(recordId);
	}
}