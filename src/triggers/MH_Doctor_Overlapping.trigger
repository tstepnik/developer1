/**
 * Created by BRITENET on 14.09.2020.
 */

trigger MH_Doctor_Overlapping on Doctor__c (before insert) {
    Map<String,List<Doctor__c>> doctorMap = new Map<String,List<Doctor__c>>();
    for(Doctor__c doctor : Trigger.new){
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