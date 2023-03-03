({

    init: function (component, event, helper) {
        var action = component.get("c.getPiklistValues");
        //action.setParams();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.categorydetails", (response.getReturnValue()));
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
            }
        });
        $A.enqueueAction(action);

        var imageaction = component.get("c.imagesRetreival");

        var recordId = component.get("v.recordId");
        imageaction.setParams({ recordIdjs: recordId });
        imageaction.setCallback(this, function (response) {

            var imagestate = response.getState();
            if (imagestate === "SUCCESS") {

                var contentRecordList = response.getReturnValue();
                // alert(contentRecordList);
                component.set("v.listURLs", contentRecordList);

            }
            else if (imagestate == "ERROR") {
                //  alert(contentRecordList);
            }

        });
        $A.enqueueAction(imageaction);



    },

    showAllFies: function (component, event, helper) {
        component.set("v.showFiels", true);
        component.set('v.hideFiels', false);
        component.set('v.showAllFiles', true);
        console.log("we are in here  ");
    },
    hideAllFies: function (component, event, helper) {
        component.set('v.hideFiels', true);
        component.set("v.showFiels", false);
        component.set('v.showAllFiles', false);
    },
    existingSearchSubCategory: function (component, event, helper) {
        try {
            //component.set('v.subdetailsList',component.get("v.subdetails"));
            if (component.get("v.searchedValue"))
                var subserchList1 = [];
            console.log("Values--> " + component.get("v.searchedValue"));
            var filtervalues = component.get("v.searchedValue");
            var subSerchList = component.get('v.subdetails');
            console.log("Yes we are --> " + JSON.stringify(subSerchList));
            for (var i = 0; i < subSerchList.length; i++) {
                let ListName = subSerchList[i].Name__c.toUpperCase();
                let SerchValue = filtervalues.toUpperCase();
                if (ListName.startsWith(SerchValue)) {
                    console.log("add" + i);
                    subserchList1.push(subSerchList[i]);
                }
            }
            component.set('v.subdetailsList', subserchList1);
        } catch (err) {
            console.log("Error--> " + err);
        }


    },
    onCatagoryChange: function (component, event, helper) {

        var categorySelected = component.find("assigned").get("v.value");

        if (categorySelected != '' && categorySelected != 'Select Category') {
            var action = component.get("c.getSubValues");
            action.setParams({ subjs: categorySelected });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.subdetails", (response.getReturnValue()));

                    component.set("v.subselect", true);

                }
                else if (state === "INCOMPLETE") {

                }
                else if (state === "ERROR") {

                }
            });
            $A.enqueueAction(action);
        }
        else {
            component.set("v.fileUploadDisabledFlag", true);
            var subcategoryToastEvent = $A.get("e.force:showToast");
            subcategoryToastEvent.setParams({
                "title": "Invalid Category",
                "type": "error",
                "message": "Please select the correct category"
            });
            subcategoryToastEvent.fire();

        }

    },
    openModel: function (component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },

    closeModel: function (component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.uploadopen", false);
        component.set("v.subselect", false);
        component.set("v.searchedValue", null);
        component.set("v.fileUploadDisabledFlag", true);
        var compEvent = component.getEvent("closeModal");
        compEvent.setParams({
            "message": false
        });
        compEvent.fire();


    },
    handleUploadFinished: function (component, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        //alert(uploadedFiles);
        // Get the file name
        uploadedFiles.forEach(file =>
            component.set("v.contentid", file.contentVersionId)
        );

        var id = component.get("v.contentid");
        //alert(id);
        var category = component.find("assigned").get("v.value");
        var subcategory = component.find("subassigned").get("v.value");
        var fieldName = component.get("v.refno");
        var recordId = component.get("v.recordId");
        var action = component.get("c.contentVersionUpdate");

        console.log(`id::${id} category::${category} subcategory::${subcategory} fieldName::${fieldName} recordId::${recordId}`);
        action.setParams({ idjs: id, categoryjs: category, subcategoryjs: subcategory, recordIdjs: recordId, fieldNamejs: fieldName });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.updatedetails", (response.getReturnValue()));


                component.set("v.isModalOpen", false);

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                var fireEvent = $A.get('e.force:refreshView');
                //location.reload()

                //$A.get("e.force:closeQuickAction").fire();
                console.log('response::', response.getReturnValue());
                var compEvent = component.getEvent("closeModal");
                compEvent.setParams({
                    "message": false
                });
                compEvent.fire();

            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {

            }


        });
        $A.enqueueAction(action);


    },
    onSubCategoryChange: function (component, event, helper) {
        component.set('v.showfilterSubData', false);
        component.set('v.searchedValue', event.currentTarget.name);
        component.set('v.subdetailsList', null);

        component.set("v.uploadopen", true);
        component.set("v.fileUploadDisabledFlag", false);
        var subcategory = component.find("subassigned").get("v.value");
        if (subcategory == '') {
            var subcategoryToastEvent = $A.get("e.force:showToast");
            subcategoryToastEvent.setParams({
                "title": "Invalid Sub-Category",
                "type": "error",
                "message": "Please select the correct sub-category",
                "mode": "pester",
                "duration": "2000"
            });
            subcategoryToastEvent.fire();
            component.set("v.fileUploadDisabledFlag", true);
        }
    },

    handleSubCategoryClick: function (component, event, helper) {
        let subSerchList = component.get('v.subdetails');
        component.set('v.subdetailsList', subSerchList);
    },

    onPictureClick: function (component, event, helper) {
        // alert('here');
        var fileId = (event.getSource().get("v.title"));
        //alert(fileId);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": fileId,
            "slideDevName": "related"
        });
        navEvt.fire()
    }




})