# frozen_string_literal: true

require "open-uri"
require "net/http"

class RemoveSchoolsController < ApplicationController
  layout "application"
  PAGE_NAME = "GS:LandingPage:RemoveSchool"

  def new
    set_seo_meta_tags
    @remove_school_submission = RemoveSchoolSubmission.new
  end

  def create
    @remove_school_submission = RemoveSchoolSubmission.new(remove_school_submissions_params)
    render_if_not_allowed(@remove_school_submission, 'new'); return if performed?
    if @remove_school_submission.save
      redirect_to new_remove_school_submission_success_path
    else
      render 'new'
    end
  end

  private

  def render_if_not_allowed(obj,template)
    unless RecaptchaVerifier.submissions_allowed?(params['g-recaptcha-response'])
      obj.errors.add(:recaptcha, 'error, please try again later.')
      render template
    end
  end

  def remove_school_submissions_params
    params.require(:remove_school_submission).permit(:gs_url, :evidence_url, :submitter_role, :submitter_email)
  end

  def set_seo_meta_tags
    set_meta_tags title: 'Remove a school from GreatSchools.',
                  description: 'Use the form provided to let us know about a school that has permanently closed.'
  end

end