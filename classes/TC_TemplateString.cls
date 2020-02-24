public with sharing class TC_TemplateString {

    public static String mergeFields(Set<Id> referencedRecordIds, String templateStr) {
        Map<Id, Set<String>> idToReferencedFieldNames = new Map<Id, Set<String>>();
        for (Id recordId : referencedRecordIds) {
            SObjectType ty = recordId.getSobjectType();
            if (ty == null) { System.debug(LoggingLevel.ERROR, 'Record Id in Apex Merge is not a valid SObject Type: ' + recordId); continue; }
            idToReferencedFieldNames.put(recordId, parseReferencedFieldNames(ty.getDescribe().getName(), templateStr));
        }

        for (Id recordId : idToReferencedFieldNames.keySet()) {
            Set<String> referencedFieldNames = idToReferencedFieldNames.get(recordId);
            if (referencedFieldNames.isEmpty()) { continue; }
            List<String> referencedFieldNamesList = new List<String>();
            referencedFieldNamesList.addAll(referencedFieldNames);
            List<SObject> records = TC_DataUtility.getSObjectById(referencedFieldNamesList, recordId);
            if (records == null || records.isEmpty()) { System.debug(LoggingLevel.ERROR, 'No record found for Record Id: ' + recordId); continue; }
            SObject record = records.get(0);

            Map<String, String> fieldNameToFieldValue = new Map<String, String>();
            for (String field : referencedFieldNamesList) {
                try {
                    fieldNameToFieldValue.put(field, String.valueOf(TC_DataUtility.getByExpression(record, field)));
                } catch (NullPointerException ex) {
                    // It's possible that the template has a field reference which is invalid or incorrect.
                    System.debug(ex.getMessage() + ex.getStackTraceString() + ex.getLineNumber());
                    fieldNameToFieldValue.put(field, '<< failed to retrieve field value from record >>');
                }
            }

            String templateStringAfterMerge = mergeFields(recordId.getSobjectType(), fieldNameToFieldValue, templateStr);
            templateStr = templateStringAfterMerge;
        }

        return templateStr;
    }

    private static String mergeFields(SObjectType ty, Map<String, String> fieldNameToFieldValue, String templateString) {
        Matcher m = Pattern.compile('(\\{!\\s*' + ty.getDescribe().getName() + '\\.([A-Za-z\\._0-9]+)\\s*\\})').matcher(templateString);
        Set<String> matchFields = new Set<String>();
        while (m.find()) {
            String merge_field = (String) m.group(0);
            String fieldName = (String) m.group(2);

            String value;
            try {
                value = String.valueOf(fieldNameToFieldValue.get(fieldName));
            }
            catch (Exception e) { value = '<< error converting value to string >>'; }
            if (value == null) { value = ''; }
            templateString = templateString.replace(merge_field, value);
        }

        return templateString;
    }

    private static Set<String> parseReferencedFieldNames(String objectApiName, String content) {
        Set<String> fieldApiNames = new Set<String>();
        // Match the field name following a dot. (e.g. 'Account.Name' => 'Name')
        Matcher m = Pattern.compile('(\\{!\\s*' + objectApiName + '\\.([A-Za-z\\._0-9]+)\\s*\\})').matcher(content);
        while(m.find()) {
            String merge_field = m.group(2);
            fieldApiNames.add(merge_field);
        }
        return fieldApiNames;
    }

}
