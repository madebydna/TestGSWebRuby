# frozen_string_literal: true

require "open-uri"
require "net/http"

class AddSchoolsController < ApplicationController
  layout "application"
  PAGE_NAME = "GS:LandingPage:AddSchool"
# rubocop:disable Style/SafeNavigation
  before_filter :set_pk_and_grades, only: [:new, :create]
# rubocop:enable Style/SafeNavigation
  def new
    set_seo_meta_tags
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

  def success
    render 'success'
  end

  private

  def render_if_not_allowed(obj,template)
    unless RecaptchaVerifier.submissions_allowed?(params['g-recaptcha-response'])
      @recaptcha_error = true
      render template
    end
  end

  # The add new school form hides fields depending on whether user selects pk or k-12. This method sets
  # @pk to preserve user's selection on page re-render (i.e. if there are validation errors)
  def set_pk_and_grades
    @grades ||= []
    if params[:new_school_submission]
      @pk = params[:new_school_submission][:pk] == 'true'
      @grades = params[:new_school_submission][:grades]
    end
  end

  def new_school_submission_params
    params.require(:new_school_submission).permit(:nces_code, :state, :school_name, :district_name, :url,
                    :school_type, :county, :phone_number, :grades, :state_school_id,
                    :physical_address, :physical_city, :physical_zip_code, :mailing_address,
                    :mailing_city, :mailing_zip_code)
  end

  def set_seo_meta_tags
    set_meta_tags title: 'Add your school to GreatSchools.',
                  description: 'Use the form provided to let us know about a new school that is not currently represented on GreatSchools.'
  end

end
