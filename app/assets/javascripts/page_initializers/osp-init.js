$(function() {
    if (gon.pagename == "Osp") {

        GS.forms.elements.setCheckboxButtonHandler(".js-ospQuestionsContainer");
        GS.forms.elements.setEnableDisableElementsAndInputsHandler(".js-ospQuestionsContainer");
        GS.forms.elements.setResponsiveRadioHandler(".js-ospQuestionsContainer");
        GS.forms.elements.disableTargetElementsIfTriggerActive();
        GS.forms.elements.setConditionalQuestionHandler('.js-conditionalQuestion');
        GS.forms.elements.disableTargetElementsIfTriggerEmpty('.js-conditionalQuestion');
        GS.forms.elements.initOspPageAutocomplete(".js-ospQuestionsContainer");
        GS.forms.elements.setCustomSubmitHandler('.js-submitTrigger', 'ospPage', '.js-ospNav', function(e, $form) {
            e.preventDefault();
            var pageNumber = $(this).data('page-number');
            $form.find('input[name=redirectPage]').val(pageNumber);
        });

        GS.gsParsleyValidations.init();
        GS.photoUploads.init();
    }
});
