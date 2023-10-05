/**
 * @description The purpose of this apex class is to Create a task in Salesforce, from the inputs captured in Chatbot.
 *
 * @see AW_TEST_FLOW_CreateMeetingRequestTask
 *
 * @author Accenture
 *
 * @date 2020
 */
public without sharing class AW_FLOW_CreateMeetingRequestTask
{

	/**
	 * @description Method to create a meeting request task for adviser as requested by his client in the community'
	 *
	 * @param dtoTasks List of DTO_Task wrapper class varriable
	 *
	 * @return List<Task>
	 */
	@InvocableMethod(Label='New Meeting Request Task' Description='Method to create a meeting request task for adviser as requested by his client in the community')
	public static List<Task> createTask(List<DTO_Task> dtoTasks)
	{
		List<Task> newTasks = new List<Task>();

		for(DTO_Task dtoTask : dtoTasks)
		{
			Task newTask = new Task();

			newTask.Description = dtoTask.description;
			newTask.ActivityDate = dtoTask.dueDate;

			if(String.isNotBlank(dtoTask.loggedInUserName))
			{
				User adviser = AW_DAL_User.findCommunityUserOwner(dtoTask.loggedInUserName);
				if(adviser != null)
				{
					newTask.OwnerId = adviser.Id;
				}
			}

			newTask.Status = AW_DAL_Task.STATUS_IN_PROGRESS;
			newTask.Subject = AW_DAL_Task.SUBJECT_MEETING;
			newTask.Priority = AW_DAL_Task.PRIORITY_NORMAL;

			newTasks.add(newTask);
		}

		CMN_DAL_SObjectDomain.insertDBObjects(newTasks);

		return newTasks;
	}

	/**
	 * @description This is a wrapper class to declare the invocable varriable
	 */
	public class DTO_Task
	{
		@InvocableVariable(Required=true Label = 'Meeting Purpose')
		public String description;

		@InvocableVariable(Label = 'Meeting Date')
		public Date dueDate;

		@InvocableVariable(Label='Logged In User\'s userName')
		public String loggedInUserName;
	}
}