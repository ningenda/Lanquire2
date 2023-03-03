@isTest
public class CustomFileUploadControllerTestClass {
    @isTest
    public static void customFileUploadControllerTestMethod(){
        Direct_Mail_Campaign__c acqObj = new Direct_Mail_Campaign__c();
        insert acqObj;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion; 
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acqObj.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.visibility = 'AllUsers';
        insert cdl;
        
        Test.startTest();
        CustomFileUploadController.retriveFiles(acqObj.Id);
        CustomFileUploadController.retrivePictures(acqObj.Id);
        CustomFileUploadController.getDepartmentPickListValuesIntoList();
        CustomFileUploadController.retriveVideos(acqObj.Id);
        CustomFileUploadController.updateFileTitle(documents[0].Id, 'Test.Pdf', acqObj.Id);
        CustomFileUploadController.updateFiles(documents[0].Id, 'Test.jpg', acqObj.Id, 'Acquisitions', 'Appraisal 1', '');
        CustomFileUploadController.createContentDistribution(documents[0].Id);
        CustomFileUploadController.getCategoriesPicklistValues();
        CustomFileUploadController.getSubCategoriesPicklistValues('Acquisitions');
        Test.stopTest();
    }
}