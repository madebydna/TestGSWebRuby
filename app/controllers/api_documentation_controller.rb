class ApiDocumentationController < ApplicationController
  layout 'api_documentation'

  def show
    unless %w[
      getting-started
      technical-overview
      browse-schools
      nearby-schools
      school-profile
      school-search
      school-reviews
      review-topics
      school-census-data
      city-overview
      nearby-cities
      browse-districts
    ].include? params[:page]
      render 'error/page_not_found'
      return
    end

    render params[:page].gsub('-','_')
  end
end
