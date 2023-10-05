/**
 * @description API handler to support FA sync
 *
 * @see RSC_API_NotifyAdvisorSyncCompleted_TEST @226578
 * @see RSC_URL_NotifyAdvisorSyncCompleted
 *
 * @author jayanth.kumar.s@accenture.com
 *
 * @date December 2021, February 2022
 */
public inherited sharing class RSC_API_NotifyAdvisorSyncCompleted extends CMN_API_RestBaseInbound
{
	/**
	 * @description Class name of the API
	 */
	public static final String SERVICE_NAME = RSC_API_NotifyAdvisorSyncCompleted.class.getName();

	@TestVisible
	private static final String SYNC_FINISHED = 'Advisor Sync Finished';

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

		addSObjectTypes(new List<Schema.SObjectType> {SC_ConsultantCodes__c.SObjectType});
	}

	/**
	 * @description Will ensure that the change to contact is registered to be committed after
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		if(SYNC_FINISHED.equals(dtoRequest.notifyMessage))
		{
			for(SC_ConsultantCodes__c foundConsultant : SC_DAL_ConsultantCodes.findConsultantsNotModifiedToday())
			{
				foundConsultant.SC_AgreementStatus__c = false;

				registerChange(foundConsultant);
			}
		}
	}

	/**
	 * @description The DTO representing the request being sent
	 */
	@TestVisible
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String notifyMessage;

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

	/**
	 * @description DTO representing a successful response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public String message = 'Advisors terminated successfully';
	}
}