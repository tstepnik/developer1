public with sharing class MH_Utils {



    public static Boolean isConfigurationEnabled(String configName, String value){
        MH_Configuration__c configuration = MH_Configuration__c.getInstance(configName);
        return configuration.Value__c.contains(value);
    }

    public static User getCurrentUser(){
        List<User> users = [SELECT Id,Username,Country FROM User WHERE Id = :UserInfo.getUserId()];
        if (users.isEmpty()) {
            return null;
        }
        return users[0];
    }

//    public static Boolean isTriggerEnabled(String ObjectName){
//
//
//    }


}