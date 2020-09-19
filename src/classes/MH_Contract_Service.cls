public without sharing class MH_Contract_Service {

    public static List<MH_Hospital_Service.DoctorWrapper> doctorWrappers {
        get {
            if (doctorWrappers == null) {
                doctorWrappers = new List<MH_Hospital_Service.DoctorWrapper>();
            } return doctorWrappers;
        }
        set;
    }

    public static Boolean createContact(Contract__c contract) {
        try {
            insert contract;
            return true;
        } catch (DmlException e) {
            e.setMessage(System.Label.MH_Contract_Error_Msg1);
        }
        return false;
    }

    public static Set<Contract__c> oldContracts() {
        return new Set<Contract__c>([
                SELECT Id, Date_Started__c, Expire_Date__c,Doctor__c,Hospital__c
                FROM Contract__c
        ]);
    }

    private static String newLine = '<br>' + '&nbsp;';

    public static void catchOverlappedContracts(Contract__c newContract, Set<Contract__c> contracts) {

        String errorMessage = ' ' + System.Label.MH_Contract_Error_Message2;
        Boolean isOverlapping = false;
        if (newContract.Date_Started__c == null && newContract.Expire_Date__c == null) {
            errorMessage = ' ' + System.Label.MH_Contract_Dates_Are_Null_Error;
            isOverlapping = true;
        } else if (newContract.Date_Started__c == newContract.Expire_Date__c) {
            errorMessage = ' ' + System.Label.MH_Contract_Error_Msg_Equal_Dates;
            isOverlapping = true;
        } else if (newContract.Date_Started__c > newContract.Expire_Date__c) {
            errorMessage = ' ' + System.Label.MH_Contract_Error_Msg_End_Date_Before_Start_Date;
            isOverlapping = true;
        } else {

            for (Contract__c oldContract : contracts) {

                Boolean areOverlapped = !(newContract.Expire_Date__c <= oldContract.Date_Started__c || newContract.Date_Started__c >= oldContract.Expire_Date__c);

                if (areOverlapped) {

                    isOverlapping = true;
                    errorMessage += newLine + oldContract.Date_Started__c.format() + ' - ' + (oldContract.Expire_Date__c != null ? oldContract.Expire_Date__c.format() : ' undefined');
                }
            }
        }
        if (isOverlapping) {
            newContract.addError(errorMessage);
        }
    }

    public static Map<String, Set<Contract__c>> createMapFromSet(Set<Contract__c> contracts) {

        Map<String, Set<Contract__c>> contractsMap = new Map<String, Set<Contract__c>>();
        for (Contract__c contract : contracts) {
            String doctorId = String.valueOf(contract.Doctor__c);
            String hospitalId = String.valueOf(contract.Hospital__c);
            String mapKey = doctorId + hospitalId;
            if (contractsMap.containsKey(mapKey)) {
                Set<Contract__c> contractsList = contractsMap.get(mapKey);
                contractsList.add(contract);
                contractsMap.put(mapKey, contractsList);
            } else {
                Set<Contract__c> contractsList = new Set<Contract__c>();
                contractsList.add(contract);
                contractsMap.put(mapKey, contractsList);
            }
        }
        return contractsMap;
    }

    public static Set<Contract__c> contractsSetWhenInsertTrigger(Set<Doctor__c> doctors, Set<Hospital__c> hospitals) {

        return new Set<Contract__c>([
                SELECT Id, Date_Started__c, Expire_Date__c, Doctor__r.Name, Hospital__r.Name
                FROM Contract__c
                WHERE Doctor__c IN :doctors OR Hospital__c IN :hospitals
        ]);
    }

    public static Set<Contract__c> contractsSetWhenUpdateTrigger(Set<Doctor__c> doctors, Set<Hospital__c> hospitals, Set<String> ids) {

        return new Set<Contract__c>([
                SELECT Id, Date_Started__c, Expire_Date__c, Doctor__r.Name, Hospital__r.Name
                FROM Contract__c
                WHERE (Doctor__c IN :doctors OR Hospital__c IN :hospitals) AND Id NOT IN :ids
        ]);
    }

    public static Set<String> retrieveIdsFromContractsList(List<Contract__c> contracts) {
        Set<String> ids = new Set<String>();

        for (Contract__c contract : contracts) {
            ids.add(contract.Id);
        }
        return ids;
    }

    public static List<MH_Hospital_Service.DoctorWrapper> hospitalAllContracts(List<MH_Hospital_Service.DoctorWrapper> wrappersList) {
        doctorWrappers = new List<MH_Hospital_Service.DoctorWrapper>(wrappersList);
        List<DataBase.SaveResult> results;

        List<Contract__c> contracts = new List<Contract__c>();
        for (MH_Hospital_Service.DoctorWrapper doctorWrapper : doctorWrappers) {
            Contract__c contract = doctorWrapper.contract;
            contracts.add(contract);
        }

        try {
            results = Database.insert(contracts, false);
            for (Integer i = 0; i < contracts.size(); i++) {

                String err = '';
                if (!results[i].isSuccess()) {
                    err = results[i].getErrors()[0].getMessage();
                    err = err.replace('<br>' + '&nbsp;', '\n');
                }
                if (err == 'cannot specify Id in an insert call') {
                    doctorWrappers[i].Status = System.Label.MH_Success_Message;
                } else {
                    doctorWrappers[i].Status = results[i].isSuccess() ? System.Label.MH_Success_Message : ' ' + System.Label.MH_Error_Message + ' ' + err;
                }
            }
        } catch (DmlException dmlException) {
            System.debug(dmlException.getMessage());
        }
        return doctorWrappers;
    }

    public static void debugContractSet(Set<Contract__c> contracts) {
        for (Contract__c contract : contracts) {
            Doctor__c doctor = [SELECT Full_Name__c FROM Doctor__c WHERE Id = :contract.Doctor__c];
        }
    }

    public static List<Contract__c> getContractsConnectedWithHospital(Id hospitalId){
        return [SELECT Date_Started__c, Expire_Date__c, Doctor_Full_Name__c, Name, Status__c FROM Contract__c WHERE Hospital__c = :hospitalId];
    }

    public static List<Contract__c> getContractsConnectedWithDoctor(Id doctorId){
        return [SELECT Date_Started__c, Expire_Date__c, Hospital__c, Name FROM Contract__c WHERE Doctor__c = :doctorId];
    }
}