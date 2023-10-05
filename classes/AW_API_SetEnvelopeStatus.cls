/**
 * @description API handler to support updating Envelope Status when package on signing hub changes
 *
 * @see AW_URL_Envelope
 * @see AW_API_SetEnvelopeStatus_TEST
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class AW_API_SetEnvelopeStatus extends CMN_API_RestBaseInbound
{
	private AW_Envelope__c updateEnvelope;
	private Map<Id, DocumentChecklistItem> idByDocumentChecklistItemMap;

	@TestVisible
	private static final String ERROR_ENVELOPE_NOT_FOUND = 'Envelope could not be found for the packageId provided';
	@TestVisible
	private static final String ERROR_PACKAGE_ID_MISSING = '"packageId" is a required field for updating an Envelope Status';

	private static final String STATUS_DRAFT = 'DRAFT';
	private static final String STATUS_PENDING = 'PENDING';
	private static final String STATUS_SIGNED = 'SIGNED';
	@TestVisible
	private static final String STATUS_DECLINED = 'DECLINED';
	private static final String STATUS_INPROGRESS = 'INPROGRESS';
	@TestVisible
	private static final String STATUS_COMPLETED = 'COMPLETED';

	private static final Map<String, String> ENVELOPE_STATUS_MAPPING = new Map<String, String>
	{
			STATUS_DRAFT => AW_DAL_Envelope.STATUS_SENT_FOR_SIGNING,
			STATUS_PENDING => AW_DAL_Envelope.STATUS_AWAITING_SIGNATURE,
			STATUS_SIGNED => AW_DAL_Envelope.STATUS_COMPLETED,
			STATUS_DECLINED => AW_DAL_Envelope.STATUS_DECLINED,
			STATUS_INPROGRESS => AW_DAL_Envelope.STATUS_AWAITING_SIGNATURE,
			STATUS_COMPLETED => AW_DAL_Envelope.STATUS_COMPLETED
	};

	public static final String SERVICE_NAME = AW_API_SetEnvelopeStatus.class.getName();

	/**
	 * @description Initialise variable Object variables
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType> {AW_Envelope__c.SObjectType, DocumentChecklistItem.SObjectType});
	}

	/**
	 * @description Will check that the information received is valid and query any related data
	 */
	protected override void processRequest()
	{
		super.processRequest();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		if(String.isBlank(dtoRequest.packageId))
		{
			throw new SearchException(ERROR_PACKAGE_ID_MISSING);
		}

		updateEnvelope = AW_DAL_Envelope.findByPackageId(dtoRequest.packageId);

		if(updateEnvelope == null)
		{
			throw new SearchException(ERROR_ENVELOPE_NOT_FOUND);
		}

	}

	/**
	 * @description Will ensure that the change to envelope is registered to be committed after
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		updateEnvelope.AW_Status__c = ENVELOPE_STATUS_MAPPING.get(CMN_UTIL_String.upperCase(dtoRequest.packageStatus));
		registerChange(updateEnvelope);
	}

	/**
	 * @description The DTO representing the request being sent
	 */
	@TestVisible
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String packageId;
		public String packageStatus;
		public List<DTO_Document> documents;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Request.class;
		}
	}

	@TestVisible
	private class DTO_Document
	{
		public String documentId;
		public String documentStatus;
	}

	/**
	 * @description DTO representing a successful response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public String message = 'Envelope status updated successfully';
	}
}