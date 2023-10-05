/**
 * @description Extends VisualEditor.DynamicPickList class to display SLC_Document_Type_Mapping__mdt.Type__c field values as options in the Tab Name design attribute of Doc Vault LWC
 *
 * @author Futureform
 *
 * @date January 2023
 */
public with sharing class SLC_CTRL_DocumentTypeAttributesPicklist extends VisualEditor.DynamicPickList {
    public override VisualEditor.DataRow getDefaultValue() {

        return new VisualEditor.DataRow('--None--', '');
    }

    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        List<PicklistEntry> picklistValues = SLC_Document_Type_Mapping__mdt.Type__c.getDescribe().getPicklistValues();
        myValues.addRow(getDefaultValue());

        for (PicklistEntry picklistEntry: picklistValues) {
            myValues.addRow(new VisualEditor.DataRow(picklistEntry.label, picklistEntry.value));
        }

        return myValues;
    }
}