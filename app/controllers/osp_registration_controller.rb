class OspRegistrationController < ApplicationController
  before_action :set_login_redirect
  before_action :set_city_state



  def show

    page_title = 'School Account - Register | GreatSchools'
    gon.pageTitle = page_title
    gon.pagename = 'GS:OSP:Register'
    set_omniture_data('GS:OSP:Register', 'Home,OSP,RegisterPage')
    set_meta_tags title: page_title,
                  description:' Register for a school account to edit your school\'s profile on GreatSchools.',
                  keywords:'School accounts, register, registration, edit profile'

    @school = School.find_by_state_and_id(@state[:short], params[:schoolId]) if @state.present? && params[:schoolId].present?
    @parsley_defaults = "data-parsley-trigger=keyup data-parsley-blockhtmltags data-parsley-validation-threshold=0 "

    if @school.blank?
      render 'osp/osp_no_school_selected'
    elsif @state[:short] == 'de' && (@school.type == 'public' || @school.type == 'charter')
      render 'osp/osp_registration_de'
    else @state.present? && params[:schoolId].present?
      render 'osp/osp_register'
    end
  end


  def submit
    # create row in user
    #create row in Esp memebership
    # send emails
    # escape html

    # user, error = register

    #rediect to thank you page
    redirect_to(:action => 'show',:controller => 'osp_confirmation', :state =>params[:state], :schoolId => params[:schoolId])
  end
end