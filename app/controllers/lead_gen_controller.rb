class LeadGenController < ApplicationController
  layout false

  def show
  end

  def save
    puts params
    puts valid?
    if valid?
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  private

  def valid?
    full_name.present? && email.present? && campaign.present? && level.present?
  end

  def full_name
    params[:full_name]
  end

  def email
    params[:email]
  end

  def phone
    params[:phone]
  end

  def campaign
    params[:campaign]
  end

  def level
    params[:level]
  end
end