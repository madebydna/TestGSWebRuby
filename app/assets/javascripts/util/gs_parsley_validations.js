GS = GS || {}
GS.gsParsleyValidations = GS.gsParsleyValidations || (function() {

    var blockHtmlTags = function(val, _) {
        var pairOfTagsRegex = /<(\s|\n)*([a-z0-9]+)[^>]*>(.|\n)*<\s*\/\2(.|\n)*>/;
        var whiteListedSingleTags = /<(\s|\n)*(img|input|br)(.|\n)*>/;

        return val.match(pairOfTagsRegex) || val.match(whiteListedSingleTags) ? false : true
    };

    var youtubeVimeoTag = function(val, _){
        var youtubeWatchRegEx = /^(?:https?:\/\/)?(?:www\.)?(\byoutube\.com\b)\/(\bwatch\b)\?(v=)([0-9a-zA-Z\-_]*)?/;
        var youtubeShareRegEx = /^(?:https?:\/\/)?(\byoutu\.be\b)\/?([0-9a-zA-Z\-_]*)?/;
        var vimeoREgEx = /^(?:https?:\/\/)?(?:www\.)?(\bvimeo\.com\b)\/([0-9a-zA-Z\-_]+)/;
        if(val.match(youtubeWatchRegEx) || val.match(youtubeShareRegEx) || val.match(vimeoREgEx) ){
            return true;
        } else {
            return false;
        }

    };

    var phoneNumber = function(val, _) {
        if (val === '') return true;
        var match = val.match(/\d/g);
        return (match === null || match.length !== 10) ? false : true;
    };

    var currency = function(val, _) {
        var currencyRegEx = /^\$\d{1,3}(?:\d*(?:[.,]\d{2})?|(?:,\d{3})*(?:\.\d{2})?)$/;
        if(val.match(currencyRegEx)){
            return true;
        } else {
            return false;
        }
    };

    var init = function() {
        window.ParsleyValidator
              .addValidator('blockhtmltags', blockHtmlTags)
              .addMessage('en', 'blockhtmltags', 'Sorry but html tags are not allowed')
              .addValidator('youtubevimeotag', youtubeVimeoTag)
              .addMessage('en','youtubevimeotag','Only valid Youtube or Vimeo videos allowed.')
              .addValidator('phonenumber', phoneNumber)
              .addMessage('en','phonenumber','Please enter a valid 10 digit phone number')
              .addValidator('currency', currency)
              .addMessage('en','currency', 'Please enter a valid dollar amount. (Example: $1000)')
    };

    return {
        init: init,  //must be inited on load after jquery has loaded
        currency: currency, //TODO: object needed for teaspoon test, need to find a better way to access object
        youtubeVimeoTag: youtubeVimeoTag //TODO: object needed for teaspoon test, need to find a better way to access object
    }

})();
