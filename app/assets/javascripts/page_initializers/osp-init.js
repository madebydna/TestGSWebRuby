$(function() {
    if (gon.pagename == "Osp") {

        GS.forms.elements.setCheckboxButtonHandler(".js-ospQuestionsContainer");
        GS.forms.elements.setEnableDisableElementsAndInputsHandler(".js-ospQuestionsContainer");
        GS.forms.elements.setResponsiveRadioHandler(".js-ospQuestionsContainer");
        GS.forms.elements.disableTargetElementsIfTriggerActive();
        GS.forms.elements.initOspPageAutocomplete(".js-ospQuestionsContainer");
        GS.forms.elements.setCustomSubmitHandler('.js-submitTrigger', 'ospPage', '.js-ospNav', function(e, $form) {
            e.preventDefault();
            var pageNumber = $(this).data('page-number');
            $form.find('input[name=page]').val(pageNumber);
        });

    }
});
