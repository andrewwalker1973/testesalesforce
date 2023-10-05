/**
 * @description The purpose of the apex class is to find current user's access to various objects.
 */
public with sharing class AW_FLOW_VerifyObjectAccess
{
	/**
	 * @description Method to find user access for given objects
	 *
	 * @param dtoObjects List of DTO_Object wapper class varriable
	 *
	 * @return List of DTO_ObjectAccess
	 */
	@InvocableMethod(Label='Get Object Access' Description='Method to find user access for given objects')
	public static List<DTO_ObjectAccess> getObjectAccess(List<DTO_Object> dtoObjects)
	{
		List<DTO_ObjectAccess> dtoObjectAccesses = new List<DTO_ObjectAccess>();

		for(DTO_Object dtoObject : dtoObjects)
		{
			SObjectType sObjectType = Schema.getGlobalDescribe().get(dtoObject.objectApiName);

			DTO_ObjectAccess dtoObjectAccess = new DTO_ObjectAccess();

			dtoObjectAccess.objectApiName = dtoObject.objectApiName;
			dtoObjectAccess.hasReadAccess = (sObjectType != null && sObjectType.getDescribe().isAccessible()) ? true : false;
			dtoObjectAccess.hasCreateAccess = (sObjectType != null && sObjectType.getDescribe().isCreateable()) ? true : false;
			dtoObjectAccess.hasEditAccess = (sObjectType != null && sObjectType.getDescribe().isUpdateable()) ? true : false;
			dtoObjectAccess.hasDeleteAccess = (sObjectType != null && sObjectType.getDescribe().isDeletable()) ? true : false;

			dtoObjectAccesses.add(dtoObjectAccess);
		}
		return dtoObjectAccesses;
	}

	/**
	 * @description Wrapper class to declare the varriable .
	 */
	public class DTO_ObjectAccess
	{
		@InvocableVariable(Required=true Label = 'Object API Name')
		public String objectApiName;

		@InvocableVariable(Required=false Label = 'Has Read Access')
		public Boolean hasReadAccess;

		@InvocableVariable(Required=false Label = 'Has Create Access')
		public Boolean hasCreateAccess;

		@InvocableVariable(Required=false Label = 'Has Edit Access')
		public Boolean hasEditAccess;

		@InvocableVariable(Required=false Label = 'Has Delete Access')
		public Boolean hasDeleteAccess;
	}

	/**
	 * @description Wrapper class to declare the varriable .
	 */
	public class DTO_Object
	{
		@InvocableVariable(Required=true Label = 'Object API Name')
		public String objectApiName;
	}
}