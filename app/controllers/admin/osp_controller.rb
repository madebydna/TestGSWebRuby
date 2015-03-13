class Admin::OspController <  ApplicationController
  before_action :login_required
  before_action :set_city_state
  before_action :set_footer_cities


  def show
    # binding.pry;

     @school = School.find_by_state_and_id(params[:state],params[:schoolId])

     @osp_form = OspFormResponse.take(20)
     # @osp_question_group = Osp::OspQuestionGroup.take(20)

     if current_user.provisional_or_approved_osp_user?(@school)
       if params[:page]== '1'
         @osp_display_config = OspDisplayConfig.find_by_page_and_school('basic_information',@school)
         render 'osp/osp_basic_information'
       elsif params[:page] == '2'
         @osp_display_config = OspDisplayConfig.find_by_page_and_school('academics',@school)
         render 'osp/osp_academics'
       elsif params[:page] == '3'
         @osp_display_config = OspDisplayConfig.find_by_page_and_school('extracurricular_culture',@school)
         render 'osp/osp_extracurricular_culture'
       elsif params[:page] == '4'
         @osp_display_config = OspDisplayConfig.find_by_page_and_school('facilities_staff',@school)
         render 'osp/osp_facilities_staff'
       else
         redirect_to my_account_url
       end

     else
      redirect_to my_account_url
     end
  end








end