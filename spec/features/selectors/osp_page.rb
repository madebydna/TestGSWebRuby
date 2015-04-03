class OspPage < SitePrism::Page

  section :osp_form, "form[name='ospPage']" do
    elements :checkboxes, ".js-checkboxButton"
    elements :disabledElementTrigger, ".js-disableTriggerElement"
    elements :disabledElementTarget, ".js-disableTarget"
    element :submit, "button[type='submit']"
  end

end
