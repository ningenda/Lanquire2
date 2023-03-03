@isTest
public class NewCustomUploadControllerTestClass	 		
{
    @isTest
    Public static void TestMethod1(){
        //Parent_Category__mdt pcm = new Parent_Category__mdt('Test');
        //Parent_Category__mdt objSample = Parent_Category__mdt.getSampleValue('Test');
        List<Parent_Category__mdt> pcm = [Select Label from Parent_Category__mdt where label = 'Acquisition'];
        List<Sub_Category__mdt> scm = [Select Label from Sub_Category__mdt where Parent_Category__r.label = 'Acquisition'];
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='ABC';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        test.startTest();
        NewCustomUploadController.getPiklistValues();
        NewCustomUploadController.getSubValues('Acquisition');
        NewCustomUploadController.contentVersionUpdate(cv.Id, 'Acquisition', 'Neighborscoop pictures', acc.Id, 'Name');
        NewCustomUploadController.imagesRetreival(acc.id);
        test.stopTest();
        
    }
}