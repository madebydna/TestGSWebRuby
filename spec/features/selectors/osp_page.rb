class OspPage < SitePrism::Page

  section :osp_nav, ".js-ospNav" do
    elements :nav_buttons, ".js-submitTrigger"
  end

  section :osp_form, "form[name='ospPage']" do
    elements :checkboxes, ".js-checkboxButton"
    elements :buttons, ".btn"
    elements :active_buttons, ".btn.active"
    elements :disabledElementTrigger, ".js-disableTriggerElement"
    elements :disabledElementTarget, ".js-disableTarget"
    element :submit, "button[type='submit']"
  end

end
