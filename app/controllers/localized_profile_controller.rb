class LocalizedProfileController < ApplicationController
  protect_from_forgery

  # Find school before executing culture action
  before_filter :require_state, :require_school, :find_user

  layout 'application'

  def read_config_for_page(page_name)
    @page_config = PageConfig.new page_name, @school
  end

  def overview
    read_config_for_page 'Overview'
    init_page
  end

  def quality
    read_config_for_page 'Quality'
    init_page
  end

  def details
    read_config_for_page 'Details'
    init_page
  end

  def reviews
    init_page
    @school_reviews = @school.reviews_filter quantity_to_return: 10

    @review_offset = 0
    @review_limit = 10

  end

  def find_user
    member_id = cookies[:MEMID]
    @user = User.find member_id unless member_id.nil?
    @user_first_name = @user.first_name unless @user.nil?
  end

  def test_scores
    page('TestScores')
    init_page
  end

  def init_page
    @headerMetadata = @school.school_metadata
    @school_reviews_global = SchoolReviews.set_reviews_objects @school
    @cookie_session_cache_hash = session_cookie_load
  end
  def session_cookie_load
    if cookies[:SESSION_CACHE]
      session_cache = cookies[:SESSION_CACHE].split(';')
      session_hash = Hashie::Mash.new()
      session_cache.each do |metadata|
        #session_hash[metadata.meta_key] = metadata.meta_value
      end
    end
  end

end
