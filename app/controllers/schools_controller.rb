# frozen_string_literal: true

class SchoolsController < ApplicationController
  layout "application"
  # PAGE_NAME = "GS:School:SinglePage"

  def new
    @new_school_submission = NewSchoolSubmission.new
  end

  def create
    @new_school_submission = NewSchoolSubmission.new(new_school_submission_params)
    if @new_school_submission.save
      redirect_to new_school_submission_success_path
    else
      render 'new'
    end
  end

  def success; end

  private

  def new_school_submission_params
    params.require(:new_school_submission).permit(:nces_code, :state, :school_name, :district_name, :url,
                    :school_type, :address, :county, :phone_number, :grades, :state_school_id, :zip_code)
  end
end
