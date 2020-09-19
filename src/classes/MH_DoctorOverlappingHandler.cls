public with sharing class MH_DoctorOverlappingHandler {

    private static MH_DoctorOverlappingHandler instance;

    public static MH_DoctorOverlappingHandler getInstance() {
        if (instance == null) {
            return new MH_DoctorOverlappingHandler();
        } else {
            return instance;
        }
    }

    public void addNonOverlappedDoctors(List<Doctor__c> triggerNew) {
        Map<String,List<Doctor__c>> doctorMap = new Map<String,List<Doctor__c>>();
        for(Doctor__c doctor : triggerNew){
            String key = doctor.Name + doctor.LastName__c + doctor.Email__c;
            if(doctorMap.containsKey(key)){
                doctorMap.get(key).add(doctor);
            }else{
                List<Doctor__c> sameKeyList = new List<Doctor__c>();
                sameKeyList.add(doctor);
                doctorMap.put(key, sameKeyList);
            }
        }
        for(List<Doctor__c> sameKeyDoctors : doctorMap.values()){
            if(sameKeyDoctors.size() > 1){
                for(Doctor__c doctor : sameKeyDoctors){
                    doctor.addError('You try add duplicated doctors to database.');
                }
            }
        }
    }


}