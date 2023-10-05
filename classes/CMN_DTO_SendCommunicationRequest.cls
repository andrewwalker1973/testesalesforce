/**
 * @description Class representing the JSON structure of Communication Outbound API
 *
 * @see SC_API_SendCommunication
 *
 * @author darrion.james.singh@accenture.com aakriti.a.goyal@accenture.com @story ST-146941
 *
 * @date August 2021, July 2022
 */
public inherited sharing class CMN_DTO_SendCommunicationRequest
{
	/**
	 * @description Key instance representing the Document Management item
	 */
	public DTO_DocumentManagement documentManagement;

	/**
	 * @description Class representing a document management item
	 */
	public class DTO_DocumentManagement
	{
		/**
		 * @description An instance representing the details of the requesting system
		 */
		public DTO_Requester requester;
		/**
		 * @description An instance representing the Reply Option item
		 */
		public DTO_ReplyOption replyOptions;
		/**
		 * @description An instance representing the Password details to use in the document
		 */
		public DTO_PasswordProtection passwordProtection;
		/**
		 * @description Details needed to create the document(s) or the actual document(s)
		 */
		public List<DTO_Document> documents;
		/**
		 * @description An instance representing the receiver of the email
		 */
		public DTO_DistributeTo distributeTo;
	}

	/**
	 * @description Class representing a requester
	 */
	public class DTO_Requester
	{
		/**
		 * @description Represents the requester company name configured in a custom metadata record.
		 * Used by Papyrus to identify documents for debugging and other purposes.
		 */
		public String requestCompany;
		/**
		 * @description Represents the business unit,
		 * Used by Papyrus to identify documents for debugging and other purposes
		 */
		public String requestBusinessUnit;
		/**
		 * @description Represents the department tagged to a request,
		 * Used by Papyrus to identify documents for debugging and other purposes
		 */
		public String requestDepartment;
		/**
		 * @description Represents the team tagged to a request,
		 * Used by Papyrus to identify documents for debugging and other purposes
		 */
		public String requestTeam;
		/**
		 * @description Represents the request system id configured in a custom metadata
		 */
		public String requestSystemId;
		/**
		 * @description Represents the user information who is processing the request
		 */
		public String requestId;
		/**
		 * @description A unique reference ID
		 */
		public String documentReference;
	}

	/**
	 * @description Class representing a reply option
	 */
	public class DTO_ReplyOption
	{
		/**
		 * @description Boolean flag to indicate if the documents to be returned back with the response
		 */
		public Boolean replyWithDocuments;
		/**
		 * @description Boolean flag to true if the message would go via SOAP to Papyrus else MQ.
		 * For All requests coming from SF this flag will be set Default to true.
		 */
		public Boolean replyInSession;
	}

	/**
	 * @description Class representing a Password Protection
	 */
	public class DTO_PasswordProtection
	{
		/**
		 * @description The password to be used for the documents
		 */
		public String password;
		/**
		 * @description The password type selected based on the given set of types.
		 */
		public String passwordType;
	}

	/**
	 * @description Class representing a document checklist item
	 */
	public class DTO_Document
	{
		/**
		 * @description Specified the template to be considered. The specific values agreed with Papyrus.
		 */
		public String documentName;
		/**
		 * @description The action is used by the subflows and the consumer systems do not need to pass it in.
		 * Default action is proceed to Papyrus.
		 */
		public String action;
		/**
		 * @description Represents the mime type configured in a custom metadata
		 */
		public String mimeType;
		/**
		 * @description The boolean field to indicate if the returned document should be password protected or not.
		 */
		public Boolean passwordProtect;
		/**
		 * @description The name of the grouping or element within the XML data construct
		 */
		public List<DTO_Element> element;
	}

	/**
	 * @description Class representing an element
	 */
	public class DTO_Element
	{
		/**
		 * @description The name of the grouping or element within the XML data construct
		 */
		public String name;
		/**
		 * @description List of attributes to be sent
		 */
		public List<DTO_Attribute> attributes;
		/**
		 * @description Nested to send multiple elements based on the provided structure
		 */
		public List<DTO_Element> element;
	}

	/**
	 * @description Class representing a element item
	 */
	public class DTO_Attribute
	{
		/**
		 * @description The field name to be mapped in the xml
		 */
		public String name;
		/**
		 * @description The field value to be mapped in the xml
		 */
		public String value;
	}

	/**
	 * @description Class representing a Distribute To element
	 */
	public class DTO_DistributeTo
	{
		/**
		 * @description A list containing all email details
		 */
		public List<DTO_Email> email;
		/**
		 * @description An instance containing post details
		 */
		public DTO_Post post;
		/**
		 * @description A list containing fax details
		 */
		public List<DTO_Fax> fax;
	}

	/**
	 * @description Class representing an email
	 */
	public class DTO_Email
	{
		/**
		 * @description A list of all of the selected recipients
		 */
		public List<DTO_Recipient> recipient;
		/**
		 * @description Reply to email address, configured in the custom metadata setting
		 */
		public String replyToAddress;
	}

	/**
	 * @description Class representing an post
	 */
	public class DTO_Post
	{
		/**
		 * @description If value is set to Yes, the document will be printed for post. If the value is N or Null, it would not go to post
		 * Not used at the moment.
		 */
		@SuppressWarnings('ApexUnusedDeclaration')
		public String sendPost;
	}

	/**
	 * @description Class representing an fax
	 */
	public class DTO_Fax
	{
		/**
		 * @description Used to send the fax if populated. Not used at the moment.
		 */
		@SuppressWarnings('ApexUnusedDeclaration')
		public String faxNumber;
	}

	/**
	 * @description Class representing a recipient
	 */
	public class DTO_Recipient
	{
		/**
		 * @description Email address of the recipient
		 */
		public String emailAddress;
		/**
		 * @description Email Type - Either "TO", "CC" or "BCC"
		 */
		public String emailType;
		/**
		 * @description Cellphone number to send a SMS to if the email address fails
		 */
		public String cellphoneNumber;
	}

}