public with sharing class NewCustomUploadController
{
    @AuraEnabled
    public static List<sObject> getPiklistValues() {
        return[SELECT label from Parent_Category__mdt order by label ASC];
        
    }
    @AuraEnabled
    public static List<sObject> getSubValues(string subjs) {
        return [ SELECT Name__c,Label from Sub_Category__mdt where Parent_Category__r.Label =: subjs order by Name__c ASC];
        
    }
    
    @AuraEnabled
    public static List <ContentVersion> imagesRetreival(id recordIdjs){
        
        
        // List <ContentDocumentLink> newcdl = [SELECT id , ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=: recordIdjs limit 1   ];
        //system.debug('method running' +newcdl[0]);
        Set<Id> contentIds = new Set<Id>();
        // system.debug(recordIdjs);
        for (ContentDocumentLink cont :[SELECT id , ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=: recordIdjs])
        {
            contentIds.add(cont.ContentDocumentId);
        }
        // system.debug(SELECT Id,Title FROM ContentVersion WHERE ContentDocumentId IN :contentIds LIMIT 1);
        return [SELECT Id,Title,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentIds order by CreatedDate desc];
    }  
    @auraEnabled
    public static string contentVersionUpdate(string idjs,string categoryjs,string subcategoryjs,id recordIdjs,string fieldNamejs)
    {
        String message;
        try{
            
            system.debug('categoryjs::' +categoryjs);
            system.debug('subcategoryjs::' +subcategoryjs);
            String sObjName = recordIdjs.getSObjectType().getDescribe().getName();
            string myQuery= 'select '+ fieldNamejs +' from '+ sObjName +' where id =:recordIdjs limit 1';
            Sub_Category__mdt subcat= [select label,Name__c from Sub_Category__mdt where Name__c=:subcategoryjs limit 1];
            string documentName = subcat.Label+' - '+subcat.Name__c +'%';
            system.debug('id= '+idjs+'document name '+documentName);
            List <ContentDocumentLink> newContentDocumentLink = [Select id, ContentDocumentId, ContentDocument.title from ContentDocumentLink where LinkedEntityId =: recordIdjs  AND  ContentDocument.title LIKE: documentName ];
            sObject dis =   Database.query(myQuery);
            ContentVersion con=new ContentVersion();
            con.Category__c=categoryjs;
            con.Sub_Category__c=subcategoryjs;
            system.debug(newContentDocumentLink);
            if (newContentDocumentLink.size()==0)
            {
                con.Title=subcat.Label+' - '+subcat.Name__c+' ('+dis.get(fieldNamejs)+')';
            }
            else
                con.Title=subcat.Label+' - '+subcat.Name__c+' ('+dis.get(fieldNamejs)+')'+' - '+newContentDocumentLink.size();  
            con.Id=idjs;
            update con;
            message ='The data we got was '+fieldNamejs;
        }catch(exception e){
            message = e.getMessage();
        }
        return message;     
    }
    
    
}