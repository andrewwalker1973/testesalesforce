/**
 * @description Used to delete a user from a public group upon ACR deletion, enqueued by SLC_FLOW_DeleteUserFromGroupACR
 *
 * @author Futureform
 *
 * @date Dec 2022
 */
public class SLC_QUE_DeleteUserFromGroupACR implements Queueable {
    
    public List<List<GroupMember>> memberList;
    
    public SLC_QUE_DeleteUserFromGroupACR(List<List<GroupMember>> memberIds){
        memberList = memberIds;
    }
    
    public void execute(QueueableContext qc){   
        for(List<GroupMember> mList : memberList){            
            delete mList;
        }
    }

}