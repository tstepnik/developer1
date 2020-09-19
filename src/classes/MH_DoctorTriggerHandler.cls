public with sharing class MH_DoctorTriggerHandler extends TriggerHandler {
    private List<Contract__c> newList;
    private List<Contract__c> oldList;
    private Map<Id, Contract__c> newMap;
    private Map<Id, Contract__c> oldMap;

    public MH_DoctorTriggerHandler() {
        this.newList = (List<Contract__c>) Trigger.New;
        this.oldList = (List<Contract__c>) Trigger.Old;
        this.newMap = (Map<Id, Contract__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Contract__c>) Trigger.oldMap;
    }

    protected override void beforeInsert() {
//        MH_DoctorOverlappingHandler.getInstance().addNonOverlappedDoctors(newList);
    }

    protected override void beforeUpdate() {

    }

    protected override void beforeDelete() {
    }

    protected override void afterInsert() {
    }

    protected override void afterUpdate() {
    }

    protected override void afterDelete() {
    }
}