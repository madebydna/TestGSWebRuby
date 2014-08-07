class SimpleAjaxController < ApplicationController
  include ApplicationHelper
  protect_from_forgery

  layout false

  def create_helpful_review
    review_id = params[:review_id]
    ip = remote_ip()
    hr = HelpfulReview.new
    hr.review_id = review_id
    hr.ipaddress = ip
    hr.save

    respond_to do |format|
      format.json { render json:  HelpfulReview.helpful_counts_by_id(review_id)}
    end
  end

end
