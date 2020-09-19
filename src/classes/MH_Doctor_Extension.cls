public without sharing class MH_Doctor_Extension {

    public String emailSubject { get; set; }
    public String emailBody { get; set; }
    public String doctorWorkNumber { get; set; }

    public String contractName { get; set; }
    public String chosenHospitalId { get; set; }
    public Doctor__c doctor { get; set; }
    public Attachment attachment { get; set; }
    public Boolean hasAttachment { get; set; }
    public Boolean isLicenceEnable { get; set; }

    public List<Contract__c> contracts { get; set; }
    public List<Hospital__c> hospitals { get; set; }
    public List<Doctor__c> randomDoctors { get; set; }

    public Contract__c contract {
        get {
            if (contract == null) {
                contract = new Contract__c();
            }
            return contract;
        }
        set;
    }
    public Hospital__c searchedHospital {
        get {
            if (searchedHospital == null) {
                searchedHospital = new Hospital__c();
            }
            return searchedHospital;
        }
        set;
    }
    public Hospital__c chosenHospital {
        get {
            if (chosenHospital == null) {
                chosenHospital = new Hospital__c();
            }
            return chosenHospital;
        }
        set;
    }

    public MH_Doctor_Extension(ApexPages.StandardController stdController) {
        this.doctor = (Doctor__c) stdController.getRecord();
        this.contracts = MH_Contract_Service.getContractsConnectedWithDoctor(doctor.Id);
        this.doctorWorkNumber = doctor.Work_Phone__c;
        this.randomDoctors = MH_Doctor_Service.fiveRandomDoctors();
        this.hasAttachment = false;
        this.isLicenceEnable = MH_Utils.isConfigurationEnabled('DoctorLicenceEnableForCountry',doctor.Country__c);
        setLastAttachment();
    }

    public void dismiss() {
        contracts = MH_Doctor_Service.dismiss(contractName, doctor);
    }

    public void findHospitals() {
        hospitals = MH_Hospital_Service.findHospitals(searchedHospital);
    }

    public void clearHirePopup() {
        clearSearchAndResultSectionHirePopup();
        chosenHospital = null;
        contract = null;
    }

    public void clearSearchAndResultSectionHirePopup() {
        searchedHospital = new Hospital__c();
        if (hospitals != null) {
            hospitals.clear();
        }
    }

    public void hire() {
        contract.Hospital__c = chosenHospital.Id;
        contract.Doctor__c = doctor.Id;
        if (MH_Contract_Service.createContact(contract)) {
            contract = new Contract__c();
        }
        contracts = MH_Doctor_Service.retrieveContracts(doctor);

    }

    public void sendEmail() {
        MH_Doctor_Service.sendEmail(emailSubject, emailBody, doctor);
        emailSubject = '';
        emailBody = '';
    }

    public void setLastAttachment() {
        List<Attachment> attachments = MH_Attachment_Service.getDoctorAttachments(doctor);
        if (!attachments.isEmpty() && attachments != null) {
            attachment = attachments[0];
            System.debug(attachment);
            hasAttachment = true;
        } else {
            hasAttachment = false;
        }
    }

    public void deleteImages() {
        List<Attachment> attachmentsToDelete = MH_Attachment_Service.getAllDoctorAttachedPhotos(doctor.Id);
        try {
            if (String.isNotBlank(attachment.Id)) {
                delete attachmentsToDelete;
                attachment = new Attachment();
                hasAttachment = false;
            }
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.MH_Doctor_Upload_Photo_Error));
        }
        setLastAttachment();
    }

    @RemoteAction
    public static void saveImage(String name, String contentType, String data, String parent) {
        MH_Attachment_Service.saveImage(name,contentType,data,parent);
    }

}