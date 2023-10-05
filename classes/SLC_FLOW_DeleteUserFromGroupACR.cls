/**
 * @description Used to delete a user from a public group upon ACR deletion
 *
 * @author Futureform
 *
 * @date Dec 2022
 */
public class SLC_FLOW_DeleteUserFromGroupACR {
    /**
     * @description Deletes user from public groups on account record when ACR is deleted
     *
     * @return void
     */
    @InvocableMethod(label='Delete User from ACR Groups' description='Deletes users from account groups of ACR record')
    public static void deleteUserFromGroups(List<List<GroupMember>> groupMembersToDelete){
        
        System.enqueueJob(new SLC_QUE_DeleteUserFromGroupACR(groupMembersToDelete));
    }
}