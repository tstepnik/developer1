public with sharing class MH_Attachment_Service {

    public static List<Attachment> getDoctorAttachments( Doctor__c doctorWithImage){
        return [
                SELECT Id,Name,Parent.Name
                FROM Attachment
                WHERE ParentId = :doctorWithImage.Id
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];
    }

    public static List<Attachment> getAllDoctorAttachedPhotos(Id doctorId) {
        List<Attachment> attachments = [
                SELECT Id,Name
                FROM Attachment
                WHERE ParentId = :doctorId
        ];
        return attachments;
    }


    public static void saveImage(String name, String contentType, String data, String parent) {
        Attachment attachedPhoto = new Attachment(Name = name, OwnerId = UserInfo.getUserId(), contentType = contentType, Body = EncodingUtil.base64Decode(data), ParentId = parent);
        Database.SaveResult result = Database.insert(attachedPhoto, true);

    }

}