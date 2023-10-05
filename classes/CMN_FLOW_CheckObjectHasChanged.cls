/**
 * @description Class used to check fields in field sets are updated
 *
 * @see CMN_FLOW_CheckObjectHasChanged_TEST
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class CMN_FLOW_CheckObjectHasChanged
{
	/**
	 * @description method used to check if the required fields are updated before calling the API
	 *
	 * @param dtoRequests Contains new Sobject, old Sobject,FieldSet name and ObjectAPI name
	 *
	 * @return true,if fields are updated and oldSo is null, else returns false
	 */
	@InvocableMethod(Label='Compare two Objects' Description='Method used to check if two Objects have changed based on a Fieldset')
	public static List<Boolean> checkIsFieldsUpdated(List<DTO_Request> dtoRequests)
	{
		List<Boolean> results = new List<Boolean>();

		for(DTO_Request dtoRequest : dtoRequests)
		{
			results.add(hasObjectChanged(dtoRequest));
		}

		return results;
	}
	/**
	 * @description Checks to see object has changed in the request
	 *
	 * @param dtoRequest DTO to check to see object has changed based on the fieldset provided
	 *
	 * @return Indicates whether object has changed
	 */
	private static Boolean hasObjectChanged(DTO_Request dtoRequest)
	{
		Boolean hasChanged = dtoRequest.oldSObject == null; //New Object has obviously changed

		if(!hasChanged)
		{
			CMN_UTIL_SObjectDescribe objectDescribe = CMN_UTIL_SObjectDescribe.getDescribe(dtoRequest.newSObject);
			FieldSet objectFieldSet = objectDescribe.getFieldSetsMap().get(dtoRequest.fieldSetName);

			if(objectFieldSet != null)
			{
				for(FieldSetMember fieldMember : objectFieldSet.getFields())
				{
					String fieldPath = fieldMember.getFieldPath();

					if(dtoRequest.newSObject.get(fieldPath) != dtoRequest.oldSObject.get(fieldPath))
					{
						hasChanged = true;
						break;
					}
				}
			}
		}

		return hasChanged;
	}

	/**
	 * @description Request DTO
	 */
	public class DTO_Request
	{
		@InvocableVariable(Required=true Label = 'New Record' Description = 'Used to store the new values of the SObject record')
		public SObject newSObject;

		@InvocableVariable(Required=true Label = 'fieldSetName' Description = 'Used to store the field set name')
		public String fieldSetName;

		@InvocableVariable(Required=false Label = 'Old Record' Description = 'Used to store the old values of the SObject record')
		public SObject oldSObject;

	}
}