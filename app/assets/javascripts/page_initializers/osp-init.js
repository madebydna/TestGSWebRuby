$(function() {
    if (gon.pagename == "Osp") {
        GS.forms.elements.setCheckboxButtonHandler(".js-ospQuestionsContainer");
        GS.forms.elements.setEnableDisableElementsAndInputsHandler(".js-ospQuestionsContainer");
        GS.forms.elements.disableTargetElementsIfTriggerActive();
    }
});
