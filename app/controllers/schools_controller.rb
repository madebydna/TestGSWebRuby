# frozen_string_literal: true

class SchoolsController < ApplicationController
  require "open-uri"
  require "net/http"
  layout "application"
  # PAGE_NAME = "GS:School:SinglePage"

  def new
    @new_school_submission = NewSchoolSubmission.new
  end

  def create
    @new_school_submission = NewSchoolSubmission.new(new_school_submission_params)
    unless submissions_allowed?
      @new_school_submissions.errors.add(:recaptcha, 'is taking too long. Please try again later.')
      render 'new'
      return
    end
    if @new_school_submission.save
      redirect_to new_school_submission_success_path
    else
      render 'new'
    end
  end

  def success; end

  private

  def submissions_allowed?
    PropertyConfig.allow_new_school_submissions? && valid_recaptcha?
  end

  def valid_recaptcha?
    uri = URI('https://www.google.com/recaptcha/api/siteverify')
    secret = '6LeAEEQUAAAAAHuerLWHAGjCbq8nY2tQg90DuMZD'
    captcha_response = params['g-recaptcha-response']
    recaptcha_data = "secret=#{secret}&response=#{captcha_response}"
    response = Net::HTTP.post uri, recaptcha_data, {'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8'}
    response = JSON.parse(response.body)
    response['success']
  end

  def new_school_submission_params
    params.require(:new_school_submission).permit(:nces_code, :state, :school_name, :district_name, :url,
                    :school_type, :address, :county, :phone_number, :grades, :state_school_id, :zip_code)
  end
end
