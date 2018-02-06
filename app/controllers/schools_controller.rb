# frozen_string_literal: true

class SchoolsController < ApplicationController
  include RecaptchaVerifier
  require "open-uri"
  require "net/http"
  layout "application"
  # PAGE_NAME = "GS:School:SinglePage"

  before_filter :set_pk

  def new
    @new_school_submission = NewSchoolSubmission.new
  end

  def create
    @new_school_submission = NewSchoolSubmission.new(new_school_submission_params)
    unless submissions_allowed?
      @new_school_submission.errors.add(:recaptcha, 'error, please try again later.')
      render 'new'; return
    end
    if @new_school_submission.save
      redirect_to new_school_submission_success_path
    else
      render 'new'
    end
  end

  def success; end

  private

  # add_schools hides form fields depending on whether school is pre-k or k-12. This sets
  # @pk to preserve user's selection on page re-render (i.e. if there are errors)
  def set_pk
    if params[:new_school_submission]
      params[:new_school_submission][:pk] == 'true' ? @pk = true : @pk = false
    end
  end

  def new_school_submission_params
    params.require(:new_school_submission).permit(:nces_code, :state, :school_name, :district_name, :url,
                    :school_type, :address, :county, :phone_number, :grades, :state_school_id, :zip_code)
  end
end
