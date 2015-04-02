class OspPage < SitePrism::Page

  elements :disabledElementTrigger, ".js-disableTriggerElement"
  elements :disabledElementTarget, ".js-disableTarget"

  section :ospPageForm, "form[name='ospPage']" do
    element :submit, "button[type='submit']"
  end

end
