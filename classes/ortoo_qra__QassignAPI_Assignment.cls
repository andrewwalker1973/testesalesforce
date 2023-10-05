/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class QassignAPI_Assignment {
    global QassignAPI_Assignment() {

    }
    global List<Id> getMatchingMembersForAssignmentGroup_v1(Id recordId, Id assignmentGroupId, String assignmentGroupName) {
        return null;
    }
    global List<Id> getMatchingMembersForAssignmentGroup_v1(Id recordId, String assignmentGroupIdOrName) {
        return null;
    }
    global List<ortoo_qra.QassignAPI_Assignment.AssignmentResult> runOneAssignmentGroup_v1(List<Id> recordIds, String assignmentGroupNameOrId) {
        return null;
    }
    global List<ortoo_qra.QassignAPI_Assignment.AssignmentResult> runOneAssignmentGroup_v1(List<SObject> records, String assignmentGroupNameOrId) {
        return null;
    }
global class AssignmentResult {
    global Id recordId;
    global String status;
    global Id userId;
    global AssignmentResult() {

    }
}
global class QassignAPI_AssignmentException extends Exception {
}
}
