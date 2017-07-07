class ModalsController < ApplicationController
  protect_from_forgery except: :dependencies

  def signup_and_follow_school_modal
    render 'signup_and_follow_school_modal', layout: false
  end

  def signup_and_follow_schools_modal
    render 'signup_and_follow_schools_modal', layout: false
  end

  def school_user_modal
    state = modal_school_params[:state]
    school_id = modal_school_params[:school_id]
    @school = School.find_by_state_and_id(state, school_id)
    render 'school_user_modal', layout: false
  end

  def dependencies
    content = render_to_string('dependencies', layout: false)
    respond_to do |format|
      format.js {
        render json: {data: content}, callback: params['callback']
      }
    end
  end

  def show
    render params['modal'], layout: false
  end

  private
  
  def modal_school_params
    params.permit(:school_id, :state, :modal_css_class)
  end

end
