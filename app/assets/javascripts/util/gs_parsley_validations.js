GS = GS || {}
GS.gsParsleyValidations = GS.gsParsleyValidations || (function() {

    var blockHtmlTags = function(val, _) {
    };

    var init = function() {
        window.ParsleyValidator
              .addValidator('blockhtmltags', blockHtmlTags)
              .addMessage('en', 'blockhtmltags', 'Sorry but html tags are not allowed')
    };

    return {
        init: init //must be inited on load after jquery has loaded
    }

})();
