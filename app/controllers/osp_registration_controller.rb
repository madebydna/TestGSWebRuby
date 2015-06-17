class OspRegistrationController < ApplicationController


  def show

    page_title = 'School Account - Register | GreatSchools'
    gon.pageTitle = page_title
    gon.pagename = "OspLanding"
    set_omniture_data('GS:OSP:Register', 'Home,OSP,RegisterPage')
    set_meta_tags title: page_title,
                  description:' Register for a school account to edit your school\'s profile on GreatSchools.',
                  keywords:'School accounts, register, registration, edit profile'

    render 'osp/osp_register'
  end

end