public without sharing class MH_Doctor_Service {

    public static List<Doctor__c> findDoctors(Doctor__c searchedDoctor) {

        List<String> fields = new List<String>{
                'Name',
                'Email__c',
                'Country__c'
        };

        String searchQuery =
                'SELECT Name,LastName__c,Email__c,Country__c,Full_Name__c ' +
                        'FROM Doctor__c ' +
                        'WHERE LastName__c LIKE \'' + searchedDoctor.LastName__c + '%\'';

        for (String field : fields) {

            if (field.equals('Email__c') && String.isNotBlank(String.valueOf(searchedDoctor.get('Search_Email__c')))) {
                searchQuery += ' AND ' + field + ' LIKE \'' + searchedDoctor.get('Search_Email__c') + '%\'';
            }
            if (String.isNotBlank(String.valueOf(searchedDoctor.get(field)))) {
                searchQuery += ' AND ' + field + ' LIKE \'' + searchedDoctor.get(field) + '%\'';
            }
        }
        return Database.query(searchQuery);
    }

    public static List<Doctor__c> findDoctorsForHospital(Doctor__c searchedDoctor) {

        String searchQuery =
                'SELECT Id,Email__c,Country__c,Full_Name__c,Selected__c ' +
                        'FROM Doctor__c ';

        List<String> fields = new List<String>{
                'Name',
                'Email__c',
                'Country__c'
        };

        if (String.isNotBlank(String.valueOf(searchedDoctor.get('Searched_Last_Name__c')))) {
            searchQuery += 'WHERE LastName__c LIKE \'%' + searchedDoctor.get('Searched_Last_Name__c') + '%\'';
        } else {
            searchQuery += 'WHERE LastName__c LIKE \'%\'';
        }

        for (String field : fields) {

            if (field.equals('Email__c') && String.isNotBlank(String.valueOf(searchedDoctor.get('Search_Email__c')))) {
                searchQuery += ' AND ' + field + ' LIKE \'' + searchedDoctor.get('Search_Email__c') + '%\'';
            }
            if (String.isNotBlank(String.valueOf(searchedDoctor.get(field)))) {
                searchQuery += ' AND ' + field + ' LIKE \'' + searchedDoctor.get(field) + '%\'';
            }
        }

        return Database.query(searchQuery);
    }

    public static PageReference downloadCSVFile() {
        return Page.MH_Doctor_ExportCSV.setRedirect(false);
    }
    public static PageReference downloadXLSFile() {
        return Page.MH_Doctor_ExportXLS.setRedirect(false);
    }
    public static PageReference downloadJSONFile() {
        return Page.MH_Doctor_ExportJSON.setRedirect(false);
    }

    public static List<Contract__c> dismiss(String contractName, Doctor__c doctor) {
        Date today = Date.today();
        Contract__c contract = [SELECT Date_Started__c, Expire_Date__c FROM Contract__c WHERE Name LIKE :contractName];

        if (contract.Date_Started__c >= today) {
            delete contract;
        } else if (contract.Date_Started__c <= today && (contract.Expire_Date__c > today || contract.Expire_Date__c == null)) {
            contract.Expire_Date__c = today;
            update contract;
        }
        return retrieveContracts(doctor);
    }

    public static List<Contract__c> retrieveContracts(Doctor__c doctor) {
        return [SELECT Date_Started__c, Expire_Date__c, Hospital__c, Name FROM Contract__c WHERE Doctor__c = :doctor.Id];
    }

    public static void sendEmail(String emailSubject, String emailBody, Doctor__c doctor) {

        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{
                doctor.Email__c
        };
        singleEmail.setToAddresses(sendingTo);
        singleEmail.setSubject(emailSubject);
        singleEmail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                singleEmail
        });
    }

    public static List<Doctor__c> fiveRandomDoctors() {

        Integer randomNumber = Integer.valueOf(Math.random() * 10);
        return [SELECT Name, LastName__c, Email__c, Work_Phone__c FROM Doctor__c LIMIT 5 OFFSET :randomNumber];
    }

    public class MH_Doctor_WrapperJSON {
        public String Name { get; set; }
        public String LastName { get; set; }
        public String Email { get; set; }
        public String Country { get; set; }

        public MH_Doctor_WrapperJSON(Doctor__c doctor) {
            this.Name = doctor.Name;
            this.LastName = doctor.LastName__c;
            this.Email = doctor.Email__c;
            this.Country = doctor.Country__c;
        }
    }

    public class CsvWrapper {
        public String doctorId { get; set; }
        public Boolean toImport { get; set; }
        public Boolean lackOfData { get; set; }
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public String country { get; set; }
        public String birthdate { get; set; }
        public String status { get; set; }
    }

    public static List<Doctor__c> toDoctors(List<CsvWrapper> wrappers) {
        List<Doctor__c> doctors = new List<Doctor__c>();


        for (CsvWrapper wrapper : wrappers) {
            if (wrapper.toImport == true) {
                Doctor__c doctor = new Doctor__c();
                        doctor.Name = wrapper.firstName;
                        doctor.LastName__c = wrapper.lastName;
                        doctor.Email__c = wrapper.email;
                        doctor.Country__c = wrapper.country;
                try {
                    Date docDate =  Date.valueOf(wrapper.birthdate);
                    doctor.Birthday__c = docDate;
                }catch (TypeException e){
                    doctor.Birthday__c = null;
                }catch (Exception e){
                    System.debug(e.getMessage());
                }

                    doctors.add(doctor);
            }
        }
        return doctors;
    }

    public static List<MH_Doctor_WrapperJSON> wrapDoctors(List<Doctor__c> doctors) {
        List<MH_Doctor_WrapperJSON> wrapDoctors = new List<MH_Doctor_Service.MH_Doctor_WrapperJSON>();
        for (Doctor__c doctor : doctors) {
            wrapDoctors.add(new MH_Doctor_WrapperJSON(doctor));
        }
        return wrapDoctors;
    }

    public static List<CsvWrapper> importDoctors(List<CsvWrapper> wrappers) {

        List<Doctor__c> doctors;
        List<CsvWrapper> csvWrappers = new List<MH_Doctor_Service.CsvWrapper>(wrappers);
        List<CsvWrapper> wrappersToImport = new List<MH_Doctor_Service.CsvWrapper>();

        for(CsvWrapper wrapper : csvWrappers){
            if(wrapper.toImport == true){
                wrappersToImport.add(wrapper);
            }
        }

        List<DataBase.SaveResult> results;

        doctors = toDoctors(csvWrappers);

        try {
            results = Database.insert(doctors, false);
            for (Integer i = 0; i < doctors.size(); i++) {
                wrappersToImport[i].doctorId = doctors[i].Id;
                String err = '';
                if (!results[i].isSuccess()) {
                    err = results[i].getErrors()[0].getMessage();
                    err = err.replace('<br>' + '&nbsp;', '\n');
                }
                if(wrappersToImport[i].lackOfData == true){
                    wrappersToImport[i].status = System.Label.MH_Doctor_Wrapper_Error_Status1;
                }else if (err == 'cannot specify Id in an insert call') {
                    wrappersToImport[i].status = System.Label.MH_Success_Message;
                } else if(doctors[i].Birthday__c == null){
                    wrappersToImport[i].status = System.Label.MH_Doctor_Wrapper_Error_Status2;
                }
                else {
                    wrappersToImport[i].status = results[i].isSuccess() ? System.Label.MH_Success_Message : err;
                }
            }
        } catch (DmlException dmlException) {
       System.debug(dmlException.getMessage());
        }
        
        Integer counter = 0;
        for(CsvWrapper wrapper : csvWrappers){
            if(wrapper.toImport == true){
                wrapper = wrappersToImport.get(counter);
                counter++;
            }
        }

        return csvWrappers;

    }

    public static CsvWrapper createWrapperFromArray(String[] csvRecord){
        CsvWrapper wrapper = new CsvWrapper();

        try {
            wrapper.firstName = csvRecord[0].replaceAll('\"', '');
            wrapper.lastName = csvRecord[1].replaceAll('\"', '');
            wrapper.email = csvRecord[2].replaceAll('\"', '');
            wrapper.country = csvRecord[3].replaceAll('\"', '');
            wrapper.birthdate = csvRecord[4].replaceAll('\"', '');
        } catch (Exception e) {
            if (csvRecord.size() < 5) {
                wrapper.lackOfData = true;
            } else {
                throw e;
            }
        }
        return wrapper;
    }

}