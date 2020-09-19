public with sharing class MH_Hospital_Service {

    public static void dismiss(String contractId, Hospital__c hospital) {
        Date today = Date.today();
        try {
            Contract__c contract = [SELECT Id, Date_Started__c, Expire_Date__c, Status__c FROM Contract__c WHERE Id = :contractId];
            if (contract.Date_Started__c >= today) {
                delete contract;
            } else if (contract.Date_Started__c <= today && (contract.Expire_Date__c > today || contract.Expire_Date__c == null)) {
                contract.Expire_Date__c = today;
                update contract;
            }
        }catch (DmlException ex){
            System.debug('DML EXCEPTION');
            System.debug(ex.getMessage());
        }
    }

    public static List<Hospital__c> findHospitals(Hospital__c searchedHospital) {

        List<String> fields = new List<String>{
                'Email__c',
                'Country__c'
        };
        String searchQuery =
                'SELECT Name,Email__c,Country__c ' +
                        'FROM Hospital__c ';

        if (String.isNotBlank(String.valueOf(searchedHospital.get('Name')))) {
            searchQuery += 'WHERE Name LIKE \'%' + searchedHospital.get('Name') + '%\'';
        } else {
            searchQuery += 'WHERE Name LIKE \'%\'';
        }

        for (String field : fields) {

            if (field.equals('Email__c') && String.isNotBlank(String.valueOf(searchedHospital.get('Search_Email__c')))) {
                searchQuery += ' AND ' + field + ' LIKE \'%' + searchedHospital.get('Search_Email__c') + '%\'';
            }
            if (String.isNotBlank(String.valueOf(searchedHospital.get(field)))) {
                searchQuery += ' AND ' + field + ' LIKE \'%' + searchedHospital.get(field) + '%\'';
            }
        }
        return Database.query(searchQuery);
    }

    public class DoctorWrapper {
        public String Id { get; set; }
        public String FullName { get; set; }
        public String Status { get; set; }
        public Contract__c contract { get; set; }
        public Boolean editButtonIsClicked { get; set; }

        public DoctorWrapper(Doctor__c doctor, Hospital__c hospital) {
            this.contract = new Contract__c(Doctor__c = doctor.Id, Hospital__c = hospital.Id);
            this.Id = doctor.Id;
            this.FullName = doctor.Full_Name__c;
            this.editButtonIsClicked = false;
            this.Status = '';
        }
        public void editBtnIsClicked() {
            editButtonIsClicked = true;
            if (contract.Date_Started__c == null) {
                contract.Date_Started__c = Date.today();
            }

        }
        public void saveBtnIsClicked() {
            editButtonIsClicked = false;
        }
    }
}