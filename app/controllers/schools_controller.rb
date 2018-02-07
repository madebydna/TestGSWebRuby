# frozen_string_literal: true

class SchoolsController < ApplicationController
  include RecaptchaVerifier
  require "open-uri"
  require "net/http"
  layout "application"

  before_filter :set_pk, only: [:new, :create]

  def new
    @new_school_submission = NewSchoolSubmission.new
  end

  def create
    @new_school_submission = NewSchoolSubmission.new(new_school_submission_params)
    render_if_not_allowed(@new_school_submission, 'new'); return if performed?
    if @new_school_submission.save
      redirect_to new_remove_school_submission_success_path
    else
      render 'new'
    end
  end

  def new_remove_school_submission
    @remove_school_submission = RemoveSchoolSubmission.new
  end

  def create_remove_school_submission
    @remove_school_submission = RemoveSchoolSubmission.new(remove_school_submissions_params)
    render_if_not_allowed(@remove_school_submission, 'new_remove_school_submission'); return if performed?
    if @remove_school_submission.save
      redirect_to new_remove_school_submission_success_path
    else
      render 'new_remove_school_submission'
    end
  end

  def success; end

  private

  def render_if_not_allowed(obj,template)
    unless submissions_allowed?
      obj.errors.add(:recaptcha, 'error, please try again later.')
      render template
    end
  end

  # The add new school form hides fields depending on whether user selects pk or k-12. This method sets
  # @pk to preserve user's selection on page re-render (i.e. if there are validation errors)
  def set_pk
    if params[:new_school_submission]
      params[:new_school_submission][:pk] == 'true' ? @pk = true : @pk = false
    end
  end

  def new_school_submission_params
    params.require(:new_school_submission).permit(:nces_code, :state, :school_name, :district_name, :url,
                    :school_type, :address, :county, :phone_number, :grades, :state_school_id, :zip_code)
  end

  def remove_school_submissions_params
    params.require(:remove_school_submission).permit(:gs_url, :evidence_url, :submitter_role, :submitter_email)
  end
end
