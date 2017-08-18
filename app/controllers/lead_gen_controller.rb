class LeadGenController < ApplicationController
  protect_from_forgery with: :exception
  layout false

  def show
    @campaign = params[:cc]
  end

  def save
    if valid?
      LeadGen.create(lead_gen_params)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  private

  def valid?
    full_name.present? && email.present? && campaign.present? && grade_level.present?
  end

  def lead_gen_params
    params.permit(:campaign, :full_name, :email, :phone, :grade_level)
  end

  def full_name
    lead_gen_params[:full_name]
  end

  def email
    lead_gen_params[:email]
  end

  def phone
    lead_gen_params[:phone]
  end

  def campaign
    lead_gen_params[:campaign]
  end

  def grade_level
    lead_gen_params[:grade_level]
  end
end