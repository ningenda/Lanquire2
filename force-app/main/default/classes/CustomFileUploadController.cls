public  class CustomFileUploadController {
    
    // Get Pdf,doc etc files handler
    @AuraEnabled
    public static list<ContentVersion> retriveFiles(String recordId){
        String[] filtypes = new String[]{'jpg', 'png', 'gif', 'jpeg', 'mp4'};
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        return[SELECT Id, ContentDocumentId, Favorite__c, Description, ContentModifiedById, ContentModifiedDate,ContentSize, FileExtension, FileType, Title,Category__c,Sub_Category__c  FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND Category__c != NULL AND Sub_Category__c != NULL AND FileExtension != 'snote' AND FileType NOT IN:filtypes ORDER BY Favorite__c DESC];
    }
    
    // Get picture files Handler
    @AuraEnabled(cacheable=true)
    public static list<ContentVersion> retrivePictures(String recordId){
        String[] filtypes = new String[]{'jpg', 'png', 'gif', 'jpeg'};
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        return[SELECT Id, ContentDocumentId, Description, ContentModifiedById, ContentModifiedDate,ContentSize, FileExtension, FileType, Title, Department__c,Category__c,Sub_Category__c FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND FileExtension IN: filtypes AND Category__c != NULL AND Sub_Category__c != NULL ORDER BY Category__c ASC ];
    }
    
    // Get video files
    @AuraEnabled(cacheable=true)
    public static list<ContentVersion> retriveVideos(String recordId){
        String[] filtypes = new String[]{'mp4'};
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        return[SELECT Id, ContentDocumentId, Description, ContentModifiedById, ContentModifiedDate,ContentSize, FileExtension, FileType, Title, Department__c,Category__c,Sub_Category__c  FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND FileExtension IN: filtypes AND Category__c != NULL AND Sub_Category__c != NULL ORDER BY Category__c ASC ];
    }
    
    // Update title of the document it may be video,file,picture etc.
    @AuraEnabled
    public static void updateFileTitle(string documentId,string title,string recordId){
        try{
            ContentDocument cd = [select id,title from ContentDocument where Id=:documentId]; // Getting files from Parent record 
            cd.Title = title;  // Changing file Title with user entered title
            update cd;  // Update ContentDocument (File)
        }catch(Exception e){
            System.debug('Exception e :: ' + e.getMessage());
        }
    }
    
    @AuraEnabled  
    public static ContentVersion updateFiles(string documentId,string title,string recordId,string category, string subCategory, string department){  
        try{  
            ContentDocument cd = [select id,title from ContentDocument where Id=:documentId]; // Getting files from Parent record 
            cd.Title = title;  // Changing file Title with user entered title
            update cd;  // Update ContentDocument (File)
            List<ContentVersion> cvList = new List<ContentVersion>();
            cvList = [SELECT Id, Category__c, Sub_Category__c, Department__c  FROM ContentVersion WHERE ContentDocumentId = :documentId]; // Getting ContentVersion from ContentDocument
            if (!cvList.isEmpty()) {
                cvList[0].Category__c = category;
                cvList[0].Sub_Category__c = subCategory == null ? cvList[0].Sub_Category__c : subCategory;
                update cvList[0]; // Update ContentVersion
            }  
            return[SELECT Id, ContentDocumentId, Description, ContentModifiedById, ContentModifiedDate,ContentSize, FileExtension, FileType, Title, Department__c,Category__c,Sub_Category__c FROM ContentVersion WHERE ContentDocumentId =: cd.Id AND Id =: cvList[0].Id AND Category__c != NULL AND Sub_Category__c != NULL ORDER BY Category__c ASC LIMIT 1];
        }
        catch(Exception e){  
            throw new AuraHandledException(e.getMessage());
        } 
    }      
    
    // Get document link
    @AuraEnabled
    public static ContentDistribution createContentDistribution(Id ContentDocumentId){
        ContentVersion cv = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :ContentDocumentId];
        Id contentVersionId = cv.Id;
        List<ContentDistribution> dists = new List<ContentDistribution>();
        dists = [SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId =: contentVersionId];
        
        if (!dists.isEmpty()) {
            return dists[0];
        } else {
            ContentDistribution newDist = new ContentDistribution();
            newDist.ContentVersionId = contentVersionId;
            newDist.Name = 'External Link';
            newDist.PreferencesNotifyOnVisit = false;
            newDist.PreferencesAllowViewInBrowser = true;
            newDist.PreferencesAllowOriginalDownload=true;
            insert newDist;
        }
        return [SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId =: contentVersionId];
    }
    
    // get Category picklist value
    @AuraEnabled(cacheable=true)
    public static List<sObject> getCategoriesPicklistValues() {
        return[SELECT label from Parent_Category__mdt order by label ASC];
        
    }
    
    //Get SubCategory picklist Value according category value
    @AuraEnabled
    public static List<sObject> getSubCategoriesPicklistValues(string categoryName) {
        return [ SELECT Name__c,Label from Sub_Category__mdt where Parent_Category__r.Label =: categoryName order by Name__c ASC];
    }
    
    // Get Department Picklist values
    @AuraEnabled(cacheable=true)
    public static List<String> getDepartmentPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ContentVersion.Department__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
}