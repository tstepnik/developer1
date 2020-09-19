/**
 * Created by BRITENET on 25.08.2020.
 */

public with sharing class MH_Doctor_PopupController {

    public Hospital__c hospital{
        get {
            if (hospital == null) {
                hospital = New Hospital__c();
            }
            return hospital;
        }
        set;
    }
}