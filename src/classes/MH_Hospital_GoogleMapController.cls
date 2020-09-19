public with sharing class MH_Hospital_GoogleMapController {

    public Hospital__c hospital{get; set;}

    public MH_Hospital_GoogleMapController() {
        hospital = [SELECT Name, Country__c, Town__c, Street__c, Street_Number__c FROM Hospital__c WHERE
        Id = :ApexPages.currentPage().getParameters().get('id')];
    }
}