/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class GRAXBatch implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global String CurrentObjectName;
    global grax.GRAXSettings gxcSettings;
    global String Query;
    global Integer recordLimit;
    global Integer recordsProcessed;
    global GRAXBatch(String ObjectName) {

    }
    global static void executeGRAXBatches(String dataJSON) {

    }
    global void execute(Database.BatchableContext bc, List<SObject> scope) {

    }
    global void finish(Database.BatchableContext bc) {

    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }
}
