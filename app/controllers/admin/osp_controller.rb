class Admin::OspController <  ApplicationController
  before_action :login_required


  def show
    # binding.pry;

     @school = School.find_by_state_and_id(params[:state],params[:schoolId])

     @osp_question = Osp::OspQuestion.take(20)
     @osp_question_group = Osp::OspQuestionGroup.take(20)
     # @osp_display_config = Osp::OspDisplayConfig.take(20)
     # @config = JSON.parse('[{"answerSet":[{"AV1":1},{"AV2":2}]},{"label":"oberride"}]')
     # @answser_set = @config['answerSet']

     if current_user.provisional_or_approved_osp_user?(@school)
       if params[:page]== '1'
         @osp_display_config = Osp::OspDisplayConfig.find_by_page('basic_information')
         render 'osp/osp_basic_information'
       elsif params[:page] == '2'
         @osp_display_config = Osp::OspDisplayConfig.find_by_page('academics')
         render 'osp/osp_academics'
       elsif params[:page] == '3'
         @osp_display_config = Osp::OspDisplayConfig.find_by_page('extracurricular_culture')
         render 'osp/osp_extracurricular_culture'
       elsif params[:page] == '4'
         @osp_display_config = Osp::OspDisplayConfig.find_by_page('facilities_staff')
         render 'osp/osp_facilities_staff'
       else
         redirect_to my_account_url
       end

     else
      redirect_to my_account_url
     end
  end








end