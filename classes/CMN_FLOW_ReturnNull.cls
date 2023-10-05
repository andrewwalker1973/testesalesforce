/**
 * @description Used with process builder where no immediate action is required.
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_FLOW_ReturnNull
{

	/**
	 * @description Returns null for use in Process Builder.
	 *
	 * @return
	 */
	@InvocableMethod(Label = 'Return null' Description = 'Returns null for use in Process Builder.')
	public static List<String> returnNull()
	{
		return null;
	}
}