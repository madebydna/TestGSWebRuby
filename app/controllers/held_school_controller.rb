class HeldSchoolController < ApplicationController

  layout 'application'


  def create
    held_school = HeldSchool.new params[:held_school]
    held_school.save!

    # TODO: redirect logic
    redirect_back
  end

  def update
    held_school = HeldSchool.find(params[:id]) rescue nil

    if held_school
      held_school[:notes] = params[:notes]
      held_school.save!
    end

    # TODO: redirect logic
    redirect_back
  end

  def destroy
    held_school = HeldSchool.find(params[:id]) rescue nil
    held_school.destroy if held_school

    # TODO: redirect logic
    redirect_back
  end

end
