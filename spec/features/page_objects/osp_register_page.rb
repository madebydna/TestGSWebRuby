require 'features/page_objects/modules/footer'
class OspRegisterPage < SitePrism::Page
  include Footer

  set_url 'school-accounts/register.page{?query*}'

  section :osp_header, ".osp-header-module" do
    element :main_title, "h1"
    element :subtitle, "h4"
  end

  section :osp_form, "form[name='ospPage']" do
    element :email, "input#email"
    element :password, "input[name=password]"
    element :password_confirmation, "input#password_verify"
    element :first_name, "input#first_name"
    element :last_name, "input#last_name"
    # element :role_select, "" custom JS button that reveals select options
  end
end