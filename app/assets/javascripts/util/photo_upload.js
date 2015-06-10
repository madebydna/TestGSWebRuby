GS = GS || {};
GS.photoUploads = GS.photoUploads || (function() {

    var dropzoneInit = function() {
        var dropzone = this;
        modifyDropzoneConfig(dropzone);
        var authenticity_token = $("input[name='authenticity_token']").val()
        _.each(gon.school_media_hashes, function(file) {
            var newImage = {
                name: file.name,
                id: file.id,
                size: 30000,
                authenticity_token: authenticity_token
            };

            dropzone.emit("addedfile", newImage);
            dropzone.emit("thumbnail", newImage, file.image_url );
            dropzone.emit("complete", newImage);
        })
    };

    var modifyDropzoneConfig = function(dropzone){
        //modify max files allowed to account for existing files on server
        var existingFileCount = gon.school_media_hashes.length
        dropzone.options.maxFiles = dropzone.options.maxFiles - existingFileCount;

        //Modify Headers
        dropzone.options.headers = {
            'X-CSRF-Token': $("input[name='authenticity_token']").val()
        }

        //add params for submit request
        dropzone.options.params = {
            schoolId: gon.school_id,
            state: gon.state_name
        };

        //callbacks for on delete and success
        dropzone.on("removedfile", deleteImageCallback);
        dropzone.on("success", uploadSuccessfulCallback);
    };

    var deleteImageCallback = function(file) {
        //don't execute callback if an image that failed to save was deleted
        if (typeof file.id === "undefined") return false;

        var hash = {};
        hash.callback = deleteImageCallbackSuccess;
        hash.callback_error = deleteImageCallbackFailure;

        //not using jquery ajax data attribute because java is not passing those through on DELETE method
        hash.href = GS.uri.Uri.putParamObjectIntoQueryString('/gsr/ajax/esp/delete_image?fileId=' + file.id, {
            fileName: file.name,
            schoolId: gon.school_id.toString(),
            state:    gon.state_name
        })
        hash.params_local = { dropzone: this };
        GS.util.deleteAjaxCall({}, hash);
        return false;
    };

    var uploadSuccessfulCallback = function(file, response) {
        if (typeof response['error'] === 'string') {
            console.log('Whoops! Something went wrong.')
        } else {
            file.id = response['imageId']
            console.log('Success!')
        }
    };

    var deleteImageCallbackSuccess = function(_, data, params_local) {
        if (typeof data['error'] === 'string') {
            console.log('Whoops! Something went wrong.')
        } else {
            var dropzone = params_local['dropzone']
            dropzone.options.maxFiles += 1;
            console.log('Success!')
        }
    };

    var deleteImageCallbackFailure= function(_, data) {
        console.log('Whoops! Something went wrong.')
    };

    var dropzoneConfig = {
        url: "/gsr/ajax/esp/add_image",
        paramName: 'imageFile',
        maxFilesize: 2,
        parallelUploads: 1,
        uploadMultiple: true,
        addRemoveLinks: true,
        clickable: ['#photo_uploader', '.js-dropzoneTrigger'],
        acceptedFiles: "image/gif,image/jpeg,image/png",
        maxFiles: 10,
        dictFallbackMessage: 'To upload images or photos please upgrade your browser or try a newer version of Internet Explorer, Chrome, Firefox, or Safari. Thank you!',
        dictFallbackText: null,
        dictDefaultMessage: '<h3>Drop your image here!</h3>',
        init: dropzoneInit
        //forceFallback true/false  for testing the fallback when a browser is not supported
        //fallback      function    for when a browser is not supported. defaults to input field and adds text
    };

    var init = function() {
        var $photoUploader = $("#photo_uploader")
        if ($photoUploader.length === 1) {
            Dropzone.autoDiscover = false;
            $photoUploader.dropzone(dropzoneConfig)
        }
    };

    return {
        init: init
    };
})();
