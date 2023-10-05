/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AnalyticsController {
    global static List<ortoo_qra.AnalyticsController.ChartDataForAverageHoursGraphs> getChartDataByAssignmentActivityView(String data_view, String object_prefix, String start_date, String end_date, String assignment_group, String assignment_group_member, String time_view) {
        return null;
    }
    global static List<ortoo_qra.AnalyticsController.ChartDataForAssignmentCountGraphs> getChartDataByAssignmentCountPerGroupView(String data_view, String object_prefix, String start_date, String end_date, String assignment_group, String assignment_group_member, String time_view) {
        return null;
    }
    global static List<ortoo_qra.AnalyticsController.ChartDataForAssignmentCountGraphs> getChartDataByAssignmentCountPerMemberView(String graphView, String objectPrefix, String graphStartDate, String graphEndDate, String assignmentGroup, String assignmentGroupMember, String graphTime) {
        return null;
    }
    global static List<ortoo_qra.AnalyticsController.ChartDataForAverageHoursGraphs> getChartDataByCreationAssignmentView(String data_view, String object_prefix, String start_date, String end_date, String assignment_group, String assignment_group_member, String time_view) {
        return null;
    }
    @RemoteAction
    global static List<ortoo_qra.AnalyticsController.ChartDataForAssignmentCountGraphs> getChartDataForAssignmentCountGraphs(String data_view, String object_prefix, String start_date, String end_date, String assignment_group, String assignment_group_member, String time_view) {
        return null;
    }
    @RemoteAction
    global static List<ortoo_qra.AnalyticsController.ChartDataForAverageHoursGraphs> getChartDataForAverageHoursGraphs(String data_view, String object_prefix, String start_date, String end_date, String assignment_group, String assignment_group_member, String time_view) {
        return null;
    }
    global static List<String> getMembersByAssignmentActivityView() {
        return null;
    }
    global static List<String> getMembersByAssignmentCountPerGroupView(String data_view, String object_prefix, String start_date, String end_date, String assignment_group, String assignment_group_member, String time_view) {
        return null;
    }
    global static List<String> getMembersByAssignmentCountPerMemberView(String graphView, String objectPrefix, String graphStartDate, String graphEndDate, String assignmentGroup, String assignmentGroupMember, String graphTime) {
        return null;
    }
    global static List<String> getMembersByCreationActivityView() {
        return null;
    }
    global static List<String> getMembersByCreationAssignmentView() {
        return null;
    }
    global static List<String> getMembersByDataView(String data_view, String object_prefix, String start_date, String end_date, String assignment_group, String assignment_group_member, String time_view) {
        return null;
    }
    @RemoteAction
    global static List<String> getMembers(String data_view, String object_prefix, String start_date, String end_date, String assignment_group, String assignment_group_member, String time_view) {
        return null;
    }
global class ChartDataForAssignmentCountGraphs {
    global String closedate {
        get;
        set;
    }
    global List<ortoo_qra.AnalyticsController.memberClass> memberscount {
        get;
        set;
    }
    global ChartDataForAssignmentCountGraphs(String cdate, List<ortoo_qra.AnalyticsController.memberClass> memlist) {

    }
}
global class ChartDataForAverageHoursGraphs {
    global ChartDataForAverageHoursGraphs() {

    }
}
global class firstActivity {
    global firstActivity() {

    }
}
global class memberClass implements System.Comparable {
    global Integer count {
        get;
        set;
    }
    global String mem_id {
        get;
        set;
    }
    global String memberName {
        get;
        set;
    }
    global memberClass(String name, Integer xcount, String id) {

    }
}
}
