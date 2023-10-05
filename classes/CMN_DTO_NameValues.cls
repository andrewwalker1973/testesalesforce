/**
 * @description Class used to transfer various name value combinations between classes
 *
 * @author Accenture, jason.van.beukering@acenture.com
 *
 * @date April 2021, June 2023
 */
public inherited sharing class CMN_DTO_NameValues extends CMN_DTO_JsonBase
{
	/**
	 * @description A list of name value pairs; no duplicate checking done
	 */
	public final List<DTO_NameValue> items;

	/**
	 * @description Base constructor
	 */
	public CMN_DTO_NameValues()
	{
		items = new List<DTO_NameValue>();
	}

	/**
	 * @description Constructor that populates name values from a map
	 *
	 * @param nameValues A map of key, value of strings which will be transformed
	 */
	public CMN_DTO_NameValues(Map<String, String> nameValues)
	{
		this();

		if(nameValues != null && !nameValues.isEmpty())
		{
			for(String key : nameValues.keySet())
			{
				String value = nameValues.get(key);

				add(key, value);
			}
		}
	}

	/**
	 * @description Will add an item into the list
	 *
	 * @param name Name of the item
	 * @param value Value of the item
	 */
	public void add(String name, String value)
	{
		DTO_NameValue dtoNameValue = new DTO_NameValue();

		dtoNameValue.name = name;
		dtoNameValue.value = value;

		items.add(dtoNameValue);
	}

	/**
	 * @description Will find all the values in the list for a given name
	 *
	 * @param name The name on which to match (please note this is NOT case sensitive)
	 *
	 * @return A list of zero or more items
	 */
	public List<String> getAll(String name)
	{
		List<String> foundValues = new List<String>();

		for(DTO_NameValue dtoNameValue : items)
		{
			if(dtoNameValue.name.equalsIgnoreCase(name))
			{
				foundValues.add(dtoNameValue.value);
			}
		}

		return foundValues;
	}

	/**
	 * @description Will return the first item found (if many items exists for the same name)
	 *
	 * @param name The name on which to match (please note this is NOT case sensitive)
	 *
	 * @return A null or item found
	 */
	public String getFirst(String name)
	{
		List<String> foundValues = getAll(name);

		return foundValues.isEmpty() ? null : foundValues[0];
	}

	/**
	 * @description Checks to see if a parameter exists
	 *
	 * @param name The name on which to match (please note this is NOT case sensitive)
	 *
	 * @return True if parameter exists
	 */
	public Boolean exists(String name)
	{
		List<String> foundValues = getAll(name);
		return !foundValues.isEmpty();
	}

	/**
	 * @description Checks to see if all the parameter names provided exist in the list
	 *
	 * @param names A list of names on which to match (please note this is case sensitive)
	 *
	 * @return True if ALL the parameters exist
	 */
	public Boolean allExists(Set<String> names)
	{
		Boolean hasNamesCheck = names != null && !names.isEmpty();

		Integer iMatchedCount = 0;

		if(hasNamesCheck)
		{
			for(DTO_NameValue dtoNameValue : items)
			{
				if(names.contains(dtoNameValue.name))
				{
					iMatchedCount++;
				}
			}
		}

		return !hasNamesCheck || iMatchedCount == names.size();
	}

	/**
	 * @description Will return empty JSON if there are no entries
	 *
	 * @return JSON string
	 */
	public override String serialize()
	{
		return items?.isEmpty() == false ? super.serialize() : CMN_UTIL_String.EMPTY_JSON_RESPONSE;
	}

	/**
	 * @description The Type of the DTO used when deserializing the class
	 *
	 * @return Class of the DTO
	 */
	protected override Type getObjectType()
	{
		return CMN_DTO_NameValues.class;
	}

	/**
	 * @description Represents an individual Name/Value pair
	 */
	public class DTO_NameValue
	{
		/**
		 * @description name part
		 */
		public String name;
		/**
		 * @description value part
		 */
		public String value;
	}
}