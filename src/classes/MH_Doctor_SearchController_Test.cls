@isTest
private class MH_Doctor_SearchController_Test {
    static String uniqueUserName = 'standardUser' + Datetime.now().getTime() + '@gmail.com';
    static Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
    static User user = new User(Alias = 'standt',
            Email = 'standarduser@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueUserName);


    @TestSetup
    static void setupData() {
        List<Doctor__c> doctorsToDB = new List<Doctor__c>{

                new Doctor__c(Name = 'John', LastName__c = 'Gola', Country__c = 'PL', Email__c = 'tomasz.stepnik77@gmail.com', Birthday__c = Date.valueOf('1995-11-13')),
                new Doctor__c(Name = 'John', LastName__c = 'Nowak', Country__c = 'UK', Email__c = 'konrad44@gmail.com', Birthday__c = Date.valueOf('1995-11-13')),
                new Doctor__c(Name = 'Marry', LastName__c = 'Stepnik', Country__c = 'NL', Email__c = 'janekk@gmail.com', Birthday__c = Date.valueOf('1995-11-13')),
                new Doctor__c(Name = 'Kamil', LastName__c = 'Grabiński', Country__c = 'UK', Email__c = 'zienkowski@gmail.com', Birthday__c = Date.valueOf('1995-11-13')),
                new Doctor__c(Name = 'Alicja', LastName__c = 'Zieńkowski', Country__c = 'USA', Email__c = 'kowalska@gmail.com', Birthday__c = Date.valueOf('1995-11-13')),
                new Doctor__c(Name = 'Ola', LastName__c = 'Kowalska', Country__c = 'UA', Email__c = 'szlufik@gmail.com', Birthday__c = Date.valueOf('1995-11-13'))
        };
        insert doctorsToDB;
    }

    @isTest
    static void clearData_Return_EmptyList_And_EmptyUser_When_Invoke() {

        System.runAs(user) {
            MH_Doctor_SearchController controller = new MH_Doctor_SearchController();
            controller.searchedDoctor = new Doctor__c(Name = 'Jan');
            controller.doctors = new List<Doctor__c>{
                    new Doctor__c(), new Doctor__c(), new Doctor__c()
            };

            Test.startTest();
            controller.clearData();
            Test.stopTest();


            System.assertEquals(0, controller.doctors.size(), 'List is not empty.');
            System.assert(String.isBlank(controller.searchedDoctor.Name), 'Doctor is not empty');
        }
    }

    @isTest
    static void get_Doctor_When_Not_Null(){
        System.runAs(user) {
            MH_Doctor_SearchController controller = new MH_Doctor_SearchController();

            Test.startTest();
            Doctor__c doctor = controller.searchedDoctor;
            Test.stopTest();

            System.assertNotEquals(null, doctor, 'Doctor is null.');

        }
    }

    @isTest
    static void searchDoctors_Return_One_Doctor_From_PL_When_Search_By_Country() {
        System.runAs(user) {
            MH_Doctor_SearchController controller = new MH_Doctor_SearchController();
            controller.searchedDoctor = new Doctor__c(Name = 'John', LastName__c = 'Gola', Country__c = 'PL', Email__c = 'tomasz.stepnik77@gmail.com', Birthday__c = Date.valueOf('1995-11-13'));

            Test.startTest();
            controller.searchDoctors();
            Test.stopTest();

            System.assertEquals('PL', controller.doctors.get(0).Country__c, 'Method doesn\'t return correct doctor.');
        }
    }

    @isTest
    static void searchDoctors_Return_Empty_List_When_Inert_LastName() {
        System.runAs(user) {
            MH_Doctor_SearchController controller = new MH_Doctor_SearchController();
            controller.searchedDoctor = new Doctor__c(Name = 'Samuel', LastName__c = 'Gola', Country__c = 'PL', Email__c = 'tomasz.stepnik77@gmail.com', Birthday__c = Date.valueOf('1995-11-13'));

            Test.startTest();
            controller.searchDoctors();
            Test.stopTest();

            System.assertEquals(0, controller.doctors.size(), 'Method is not empty.');

        }
    }
    @isTest
    static void searchDoctors_Return_Error_When_Doctor_Without_LastName() {
        System.runAs(user) {
            MH_Doctor_SearchController controller = new MH_Doctor_SearchController();
            controller.searchedDoctor = new Doctor__c(Name = 'Samuel', Country__c = 'PL', Email__c = 'tomasz.stepnik77@gmail.com', Birthday__c = Date.valueOf('1995-11-13'));
            DmlException dmlExc;
            Test.startTest();
            try {
                controller.searchDoctors();
            } catch (DmlException dmlException) {
                dmlExc = dmlException;
            }
            Test.stopTest();
            System.assertEquals(null, dmlExc, 'Exception should be handled by the method');

        }
    }

    @isTest
    static void downloadCSVFile_Return_PageReference_When_Call_Method() {
        MH_Doctor_SearchController controller = new MH_Doctor_SearchController();
        Test.startTest();
       controller.downloadCSVFile();
        Test.stopTest();
    }

    @isTest
    static void downloadXLSFile_Return_PageReference_When_Call_Method() {
        MH_Doctor_SearchController controller = new MH_Doctor_SearchController();
        Test.startTest();
        controller.downloadXLSFile();
        Test.stopTest();
    }

    @isTest
    static void downloadJSONFile_Return_PageReference_When_Call_Method() {
        MH_Doctor_SearchController controller = new MH_Doctor_SearchController();
        Test.startTest();
        controller.downloadJSONFile();
        Test.stopTest();
    }
}