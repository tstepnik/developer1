public with sharing class MH_ContractTriggerHandler extends TriggerHandler {
    private List<Contract__c> newList;
    private List<Contract__c> oldList;
    private Map<Id, Contract__c> newMap;
    private Map<Id, Contract__c> oldMap;

    public MH_ContractTriggerHandler() {
        this.newList = (List<Contract__c>) Trigger.New;
        this.oldList = (List<Contract__c>) Trigger.Old;
        this.newMap = (Map<Id, Contract__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Contract__c>) Trigger.oldMap;
    }

    protected override void beforeInsert() {
        MH_ContractOverlappingHandler.getInstance().addNonOverlappedContracts(newList);
    }

    protected override void beforeUpdate() {
        MH_ContractOverlappingHandler.getInstance().addNonOverlappedContracts(oldList,newList);

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