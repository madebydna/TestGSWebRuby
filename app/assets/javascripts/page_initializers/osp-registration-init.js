$(function() {
    if (gon.pagename == "GS:OSP:Register") {
        GS.forms.elements.initOspAjaxEmailValidation(".js-email-validation", ".js-email-error");
    }
});