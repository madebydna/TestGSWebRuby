require 'features/page_objects/modules/footer'
class OspPage < SitePrism::Page
  include Footer

  set_url 'school/esp/form.page{?query*}'

  section :osp_nav, ".js-ospNav" do
    elements :nav_buttons, ".js-submitTrigger"
  end

  section :osp_form, "form[name='ospPage']" do
    elements :checkboxes, ".js-checkboxButton"
    elements :buttons, ".btn"
    elements :active_buttons, ".btn.active"
    elements :conditionalMultiSelectTrigger, ".js-disableTriggerElement"
    elements :conditionalMultiSelectTarget, ".js-disableTarget"
    element :submit, "button[type='submit']"
  end

end
