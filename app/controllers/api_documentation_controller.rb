class ApiDocumentationController < ApplicationController
  layout 'api_documentation'

  def show
    unless %w[
      getting_started
      technical_overview
      browse_schools
      nearby_schools
      school_profile
      school_search
      school_reviews
      review_topics
      school_test_scores
      school_census_data
      city_overview
      nearby_cities
      browse_districts
      terms_of_use
    ].include? params[:page]
      render 'error/page_not_found'
      return
    end

    render params[:page]
  end
end
