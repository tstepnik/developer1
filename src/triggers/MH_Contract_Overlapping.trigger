trigger MH_Contract_Overlapping on Contract__c (before insert, before update) {
////////////1//////////
    Set<Doctor__c> doctorsFromTriggerContracts = new Set<Doctor__c>();
    Set<Hospital__c> hospitalsFromTriggerContracts = new Set<Hospital__c>();
    Set<Contract__c> oldContracts;
    Set<Contract__c> allContracts = new Set<Contract__c>();
    Set<Contract__c> newContracts = new Set<Contract__c>(Trigger.new);
    Map<String, Set<Contract__c>> mapWithAllCorrelativeContracts = new Map<String, Set<Contract__c>>();



    for (Contract__c contract : Trigger.new) {
        doctorsFromTriggerContracts.add(new Doctor__c(Id = contract.Doctor__c));
        hospitalsFromTriggerContracts.add(new Hospital__c(Id = contract.Hospital__c));
    }

    if (Trigger.isInsert) {
        oldContracts = MH_Contract_Service.contractsSetWhenInsertTrigger(doctorsFromTriggerContracts, hospitalsFromTriggerContracts);
    }
    if (Trigger.isUpdate) {
        Set<String> oldContractsIds = MH_Contract_Service.retrieveIdsFromContractsList(Trigger.old);
        oldContracts = MH_Contract_Service.contractsSetWhenUpdateTrigger(doctorsFromTriggerContracts, hospitalsFromTriggerContracts, oldContractsIds);
    }

    allContracts.addAll(oldContracts);
    allContracts.addAll(newContracts);
////////////1//////////
    ////////////2//////////
    for (Contract__c contract : newContracts) {
        //Przeniosłem z góry
        Boolean removeOnceSameContracts = false;
        String doctorId = contract.Doctor__c;
        String hospitalId = contract.Hospital__c;
        String keyMap = doctorId + hospitalId;

        if (!mapWithAllCorrelativeContracts.containsKey(keyMap)) {
            Boolean sameContract = false;
            Set<Contract__c> correlativeContractsSet = new Set<Contract__c>();
//            System.debug('NEW CONTRACTS');
//            System.debug(contract.Date_Started__c + ' ' + contract.Expire_Date__c);

            for (Contract__c contr : allContracts) {
//                System.debug('All contracts');
//                System.debug(contr.Date_Started__c + ' ' + contr.Expire_Date__c);
                if (contr.Hospital__c == hospitalId && contr.Doctor__c == doctorId) {
                    Boolean addContract = true;
//                    System.debug('Contract Expire Date + contr Expire Date');
//                    System.debug(contract.Expire_Date__c + ' ' + contr.Expire_Date__c);
//                    System.debug(contract.Expire_Date__c == contr.Expire_Date__c);
                    if ((contr.Date_Started__c == contract.Date_Started__c && contr.Expire_Date__c == contract.Expire_Date__c) && !removeOnceSameContracts) {
//                        System.debug(contr.Date_Started__c + ' ' + contr.Expire_Date__c);
                        removeOnceSameContracts = true;
                        addContract = false;
                    }
                    if (addContract) {
                        correlativeContractsSet.add(contr);
                    }
                }
            }
            System.debug('CORRELATIVECONTRACTSSET');
            MH_Contract_Service.debugContractSet(correlativeContractsSet);
            mapWithAllCorrelativeContracts.put(keyMap, correlativeContractsSet);
        }
    }
////////////2//////////
    ////////////3//////////
    for (Contract__c contract : newContracts) {

        String doctorId = contract.Doctor__c;
        String hospitalId = contract.Hospital__c;
        String keyMap = doctorId + hospitalId;

//Wszystkie Kontrakty pomiedzy doktorem i szpitalem
        Set<Contract__c> setForCopy = mapWithAllCorrelativeContracts.get(keyMap);
//        System.debug('SET FOR COPY');
//        System.debug(setForCopy);
        Set<Contract__c> sameDoctorSameHospitalContracts = new Set<Contract__c>();

        if (setForCopy != null) {

            for(Contract__c contractt : setForCopy){
                sameDoctorSameHospitalContracts.add(contractt);
            }
            System.debug('SAME DOCTORS SAME CONTRACTS BEFORE REMOVE');
            MH_Contract_Service.debugContractSet(sameDoctorSameHospitalContracts);
            System.debug('CONTRACTS WHICH ARE REMOVED');

            ///TU JEST BUG !!!!!! USUWA WSZYSTKIE KONTRAKTY
//            for (Contract__c contractForRemove : allContracts) {
//                if (contractForRemove.Date_Started__c == contract.Date_Started__c && contractForRemove.Expire_Date__c == contract.Expire_Date__c)
////                    System.debug(contractForRemove.Date_Started__c + ' ' + contractForRemove.Expire_Date__c);
//                    System.debug(contractForRemove);
//                sameDoctorSameHospitalContracts.remove(contractForRemove);
//            }
//            System.debug('SAME DOCTORS SAME CONTRACTS AFTER REMOVE');
//            MH_Contract_Service.debugContractSet(sameDoctorSameHospitalContracts);
//            System.debug('SHOULD SHOW LIST');
        }

//        System.debug('SAME DOCTOR SAME CONTRACTS');
        System.debug(sameDoctorSameHospitalContracts);
//            sameDoctorSameHospitalContracts.remove(contract);

        MH_Contract_Service.catchOverlappedContracts(contract, sameDoctorSameHospitalContracts);
    }
}