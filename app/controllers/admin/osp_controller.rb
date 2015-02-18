class Admin::OspController <  ApplicationController
  before_action :login_required


  def show

     @school = School.find_by_state_and_id(params[:state],params[:schoolId])
     # binding.pry;

     if current_user.provisional_or_approved_osp_user?(@school)
       if params[:page]== '1'
         render 'osp/osp_basic_information'
       elsif params[:page] == '2'
         render 'osp/osp_academics'
       elsif params[:page] == '3'
         render 'osp/osp_extracurricular_culture'
       elsif params[:page] == '4'
         render 'osp/osp_facilities_staff'
       else
         redirect_to my_account_url
       end

     else
      redirect_to my_account_url
     end
  end








end