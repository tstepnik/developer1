trigger MH_DoctorTrigger on Doctor__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {

    new MH_DoctorTriggerHandler().run();
}