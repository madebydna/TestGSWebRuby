
# FindSchoolController
class ReviewSchoolChooserController < ApplicationController
  
  before_action :use_gs_bootstrap
  layout 'application'

  REVIEW_LIMIT_TO_RETURN = 15
  REVIEW_BUFFER_FOR_DISABLED = 5

  def show
    write_tags_and_gon
    @topic = review_topic
    @reviews = reviews

  end

  def morgan_stanley
    write_tags_and_gon
    @topic = review_topic
    @display_morgan_stanley = ''
    @reviews = reviews
    gon.morganstanley = "morganstanley"
    render 'show'
  end

  def write_tags_and_gon
    @display_morgan_stanley = 'dn'
    gon.pagename = "Write a school review | GreatSchools"
    gon.omniture_pagename = 'GS:Promo:Reviews'
    gon.omniture_hier1 = "School,Parent Reviews, Rating Review Marketing Landing Page "
    gon.topic_id = review_topic.id
    set_meta_tags :title => "Write a school review | GreatSchools" , :description => "Write a review for your school today and you can help other parents make a
    more informed choice about which school is right for their family."
    data_layer_gon_hash.merge!({ 'page_name' => 'GS:Promo:Reviews' })
  end

  def review_topic
    @review_topic ||= (
      topic_id = params[:topic] ||= 1
      ReviewTopic.find_by(id: topic_id, active: 1) || ReviewTopic.find_by(id: 1)
    )
  end

  def active_schools_required(review_array)
    review_array.select{|review| review&.school&.active == 1}[0..REVIEW_LIMIT_TO_RETURN-1]
  end

  def reviews
    cache_key = "recent-reviews-national"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      review_array = review_topic
          .first_question
          .reviews
          .active
          .has_comment
          .order(id: :desc)
          .limit(REVIEW_LIMIT_TO_RETURN+REVIEW_BUFFER_FOR_DISABLED)
          .includes(:answers, :votes, question: :review_topic)
          .extend(SchoolAssociationPreloading)
          .preload_associated_schools!
      active_schools_required(review_array)
    end
  end

end
