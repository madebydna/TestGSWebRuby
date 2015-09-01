class CommunityScorecardsAjaxController < ApplicationController

  before_action :set_locale

  layout false

  def get_school_data
    return_value = CommunityScorecardData.new(valid_school_data_params.merge(link_helper: self)).scorecard_data

    respond_to do |format|
      format.json { render json: return_value}
      format.html { render text: return_value} #for testing
    end
  end

  def valid_school_data_params
    params.permit(
      :collectionId,
      :offset,
      :gradeLevel,
      :sortBy,
      :sortBreakdown,
      :sortAscOrDesc,
      :lang,
      data_sets: []
    )
  end


end
