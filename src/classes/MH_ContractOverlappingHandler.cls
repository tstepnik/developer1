public with sharing class MH_ContractOverlappingHandler {
    private static MH_ContractOverlappingHandler instance;

    public static MH_ContractOverlappingHandler getInstance() {
        if (instance == null) {
            return new MH_ContractOverlappingHandler();
        } else {
            return instance;
        }
    }

    public void addNonOverlappedContracts(List<Contract__c> triggerNew) {
        Set<Doctor__c> doctorsFromTriggerContracts = new Set<Doctor__c>();
        Set<Hospital__c> hospitalsFromTriggerContracts = new Set<Hospital__c>();
        Set<Contract__c> oldContracts;
        Set<Contract__c> allContracts = new Set<Contract__c>();
        Set<Contract__c> newContracts = new Set<Contract__c>(triggerNew);
        Map<String, Set<Contract__c>> mapWithAllCorrelativeContracts = new Map<String, Set<Contract__c>>();

        for (Contract__c contract : triggerNew) {
            doctorsFromTriggerContracts.add(new Doctor__c(Id = contract.Doctor__c));
            hospitalsFromTriggerContracts.add(new Hospital__c(Id = contract.Hospital__c));
        }

            oldContracts = MH_Contract_Service.contractsSetWhenInsertTrigger(doctorsFromTriggerContracts, hospitalsFromTriggerContracts);

        allContracts.addAll(oldContracts);
        allContracts.addAll(newContracts);

        for (Contract__c contract : newContracts) {

            Boolean removeOnceSameContracts = false;
            String doctorId = contract.Doctor__c;
            String hospitalId = contract.Hospital__c;
            String keyMap = doctorId + hospitalId;

            if (!mapWithAllCorrelativeContracts.containsKey(keyMap)) {
                Boolean sameContract = false;
                Set<Contract__c> correlativeContractsSet = new Set<Contract__c>();

                for (Contract__c contr : allContracts) {

                    if (contr.Hospital__c == hospitalId && contr.Doctor__c == doctorId) {
                        Boolean addContract = true;

                        if ((contr.Date_Started__c == contract.Date_Started__c && contr.Expire_Date__c == contract.Expire_Date__c) && !removeOnceSameContracts) {

                            removeOnceSameContracts = true;
                            addContract = false;
                        }
                        if (addContract) {
                            correlativeContractsSet.add(contr);
                        }
                    }
                }
                MH_Contract_Service.debugContractSet(correlativeContractsSet);
                mapWithAllCorrelativeContracts.put(keyMap, correlativeContractsSet);
            }
        }

        for (Contract__c contract : newContracts) {

            String doctorId = contract.Doctor__c;
            String hospitalId = contract.Hospital__c;
            String keyMap = doctorId + hospitalId;

            Set<Contract__c> setForCopy = mapWithAllCorrelativeContracts.get(keyMap);

            Set<Contract__c> sameDoctorSameHospitalContracts = new Set<Contract__c>();

            if (setForCopy != null) {

                for (Contract__c contractt : setForCopy) {
                    sameDoctorSameHospitalContracts.add(contractt);
                }

                MH_Contract_Service.debugContractSet(sameDoctorSameHospitalContracts);
            }
            MH_Contract_Service.catchOverlappedContracts(contract, sameDoctorSameHospitalContracts);
        }
    }

    public void addNonOverlappedContracts(List<Contract__c> triggerOld, List<Contract__c> triggerNew) {
        Set<Doctor__c> doctorsFromTriggerContracts = new Set<Doctor__c>();
        Set<Hospital__c> hospitalsFromTriggerContracts = new Set<Hospital__c>();
        Set<Contract__c> oldContracts;
        Set<Contract__c> allContracts = new Set<Contract__c>();
        Set<Contract__c> newContracts = new Set<Contract__c>(triggerNew);
        Map<String, Set<Contract__c>> mapWithAllCorrelativeContracts = new Map<String, Set<Contract__c>>();

        for (Contract__c contract : triggerNew) {
            doctorsFromTriggerContracts.add(new Doctor__c(Id = contract.Doctor__c));
            hospitalsFromTriggerContracts.add(new Hospital__c(Id = contract.Hospital__c));
        }


            Set<String> oldContractsIds = MH_Contract_Service.retrieveIdsFromContractsList(triggerOld);
            oldContracts = MH_Contract_Service.contractsSetWhenUpdateTrigger(doctorsFromTriggerContracts, hospitalsFromTriggerContracts, oldContractsIds);


        allContracts.addAll(oldContracts);
        allContracts.addAll(newContracts);

        for (Contract__c contract : newContracts) {

            Boolean removeOnceSameContracts = false;
            String doctorId = contract.Doctor__c;
            String hospitalId = contract.Hospital__c;
            String keyMap = doctorId + hospitalId;

            if (!mapWithAllCorrelativeContracts.containsKey(keyMap)) {
                Boolean sameContract = false;
                Set<Contract__c> correlativeContractsSet = new Set<Contract__c>();

                for (Contract__c contr : allContracts) {

                    if (contr.Hospital__c == hospitalId && contr.Doctor__c == doctorId) {
                        Boolean addContract = true;

                        if ((contr.Date_Started__c == contract.Date_Started__c && contr.Expire_Date__c == contract.Expire_Date__c) && !removeOnceSameContracts) {

                            removeOnceSameContracts = true;
                            addContract = false;
                        }
                        if (addContract) {
                            correlativeContractsSet.add(contr);
                        }
                    }
                }
                MH_Contract_Service.debugContractSet(correlativeContractsSet);
                mapWithAllCorrelativeContracts.put(keyMap, correlativeContractsSet);
            }
        }

        for (Contract__c contract : newContracts) {

            String doctorId = contract.Doctor__c;
            String hospitalId = contract.Hospital__c;
            String keyMap = doctorId + hospitalId;

            Set<Contract__c> setForCopy = mapWithAllCorrelativeContracts.get(keyMap);

            Set<Contract__c> sameDoctorSameHospitalContracts = new Set<Contract__c>();

            if (setForCopy != null) {

                for (Contract__c contractt : setForCopy) {
                    sameDoctorSameHospitalContracts.add(contractt);
                }

                MH_Contract_Service.debugContractSet(sameDoctorSameHospitalContracts);
            }
            MH_Contract_Service.catchOverlappedContracts(contract, sameDoctorSameHospitalContracts);
        }
    }

    private Boolean validateContract(Contract__c contract) {
        return true;
    }
}