/**
 * @description Convert comma separated values into a list
 *
 * @author Futureform
 *
 * @date 2022
 */
public class CMN_FLOW_ConvertCommasToList {
    @InvocableMethod(label='Convert Comma Separated Values to List' description='Converts a string of comma separated values to a list')
    public static List<List<String>> convertToList(List<String> csvString) {
        List<List<String>> convertedList = new List<List<String>>();
        
        for(String str : csvString){
            List<String> listToConvert = str.split(',');
            convertedList.add(listToConvert);
        }
        
        return convertedList;
    
    }

}