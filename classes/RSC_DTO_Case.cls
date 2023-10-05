/**
 * @description Class representing the JSON structure of case sync Inbound & Outbound APIs
 *
 * @author aakriti.a.goyal@accenture.com jayanth.kumar.s@accenture.com  @story ST-145996
 *
 * @date September 2022
 */
public inherited sharing class RSC_DTO_Case
{
	/**
	 * @description stores Source System  as ServiceConsole
	 */
	public String sourceSystem;
	/**
	 * @description stores Source Channel as either Salesforce/Horizon
	 */
	public String sourceChannel;
	/**
	 * @description stores the uacfId of the Owner on the case
	 */
	public String assignedTo;
	/**
	 * @description stores the identification number/company registration trust number of the client on the case
	 */
	public String identificationNumber;
	/**
	 * @description stores the type of the client on the case
	 */
	public String identificationType;
	/**
	 * @description stores the status of the case
	 */
	public String statusCode;
	/**
	 * @description stores the SubStatus of the case
	 */
	public String subStatusCode;
	/**
	 * @description stores the Subject of the case
	 */
	public String caseTitle;
	/**
	 * @description stores the Case Number
	 */
	public String sourceCaseNumber;
	/**
	 * @description stores the WorkFlow Case Number
	 */
	public String targetCaseNumber;
	/**
	 * @description stores the Department of the case
	 */
	public String departmentName;
	/**
	 * @description stores the code of the ServiceType on  the case
	 */
	public Integer serviceTypeCode;
	/**
	 * @description stores the code of the Adviser on  the case
	 */
	public String consultantCode;
	/**
	 * @description stores the emailAddress on  the case
	 */
	public String emailAddress;
	/**
	 * @description stores the List of contracts associated on  the case
	 */
	public List<DTO_Contract> contractNumbers;
	/**
	 * @description stores the type of the requester on  the case
	 */
	public String requestorType;
	/**
	 * @description stores the List of Document associated on  the case
	 */
	public List<DTO_Document> documents;
	/**
	 * @description stores the List of Case Comments associated on  the case
	 */
	public List<DTO_CaseComment> caseComments;
	/**
	 * @description stores the team information associated on  the case
	 */
	public String team;
	/**
	 * @description stores the priority on  the case
	 */
	public String priority;
	/**
	 * @description Class representing a contract
	 */
	public class DTO_Contract
	{
		/**
		 * @description stores the contract Number
		 */
		public String contractNumber;
	}
	/**
	 * @description Class representing a document
	 */
	public class DTO_Document
	{
		/**
		 * @description stores the VaultedId of the Document
		 */
		public String id;
		/**
		 * @description stores the DocumentChecklistItem Name
		 */
		public String typeText;
		/**
		 * @description stores the DocumentType code of the DocumentChecklistItem
		 */
		public String typeCode;
		/**
		 * @description stores the VaultedDate of the DocumentChecklistItem
		 */
		public Datetime storedDate;
	}
	/**
	 * @description Class representing case comments
	 */
	public class DTO_CaseComment
	{
		/**
		 * @description stores the salesforce commentId
		 */
		public String sourceCommentId;
		/**
		 * @description stores the target(Horizon) commentId
		 */
		public String targetCommentId;
		/**
		 * @description stores the content of the comment
		 */
		public String commentHtml;
		/**
		 * @description stores the comment date
		 */
		public Datetime commentDate;
		/**
		 * @description stores the uacfId of the user who added the comment
		 */
		public String userName;
		/**
		 * @description stores the Salesforce Case Number
		 */
		public String sourceCaseNumber;
		/**
		 * @description stores the target(Horizon) Case Number
		 */
		public String targetCaseNumber;
	}
}