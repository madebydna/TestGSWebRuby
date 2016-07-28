class ModalsController < ApplicationController

  def signup_and_follow_school_modal
      render 'signup_and_follow_school_modal', layout: false
  end

  def signup_and_follow_schools_modal
      render 'signup_and_follow_schools_modal', layout: false
  end

  def show
    render params['modal'], layout: false
  end

end
