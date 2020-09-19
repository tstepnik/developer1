public class MH_Doctor_SearchController {

    public List<Doctor__c> doctors { get; set; }
    public String jsonString {get; set;}
    public Doctor__c searchedDoctor {
        get {
            if (searchedDoctor == null) {
                searchedDoctor = new Doctor__c();
            }
            return searchedDoctor;
        }
        set;
    }

    public MH_Doctor_SearchController() {
        doctors = new List<Doctor__c>();
    }

    public void clearData() {
        searchedDoctor = new Doctor__c();
        doctors.clear();
    }

    public PageReference downloadCSVFile() {
        return MH_Doctor_Service.downloadCSVFile();
    }

    public PageReference downloadXLSFile() {
        return MH_Doctor_Service.downloadXLSFile();
    }

    public PageReference downloadJSONFile() {
        jsonString = JSON.serialize(MH_Doctor_Service.wrapDoctors(doctors));
        return MH_Doctor_Service.downloadJSONFile();
    }

    public void searchDoctors() {
        doctors = MH_Doctor_Service.findDoctors(searchedDoctor);
    }

}