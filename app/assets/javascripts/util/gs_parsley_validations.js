GS = GS || {}
GS.gsParsleyValidations = GS.gsParsleyValidations || (function() {

    var blockHtmlTags = function(val, _) {
        var htmlTagRegex = /<([a-z0-9]+)>(.|\n)*<\/\1>/;
        return val.match(htmlTagRegex) ? false : true
    };

    var youtubeVimeoTag = function(val, _){
        var youtubeWatchRegEx = /^(?:https?:\/\/)?(?:www\.)?(\byoutube\.com\b)\/(\bwatch\b)\?(v=)([0-9a-zA-Z\-_]*)?$/;
        var youtubeShareRegEx = /^(?:https?:\/\/)?(\byoutu\.be\b)\/?([0-9a-zA-Z\-_]*)?$/;
        var vimeoREgEx = /^(?:https?:\/\/)?(?:www\.)?(\bvimeo\.com\b)\/([0-9a-zA-Z\-_]+)$/;
        if(val.match(youtubeWatchRegEx) || val.match(youtubeShareRegEx) || val.match(vimeoREgEx) ){
            return true;
        }

    };

    var init = function() {
        window.ParsleyValidator
              .addValidator('blockhtmltags', blockHtmlTags)
              .addMessage('en', 'blockhtmltags', 'Sorry but html tags are not allowed')
              .addValidator('youtubevimeotag', youtubeVimeoTag)
              .addMessage('en','youtubevimeotag','Only valid Youtube or Vimeo videos allowed.')
    };

    return {
        init: init //must be inited on load after jquery has loaded
    }

})();
