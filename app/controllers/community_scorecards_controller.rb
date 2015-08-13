class CommunityScorecardsController < ApplicationController

  before_filter :use_gs_bootstrap

  def show
    @collection = Collection.find(15)
    data_types = [:a_through_g, :graduation_rate]
    @table_fields = [:name, :state, :gs_rating] + data_types
    gon.scorecard_data_types = data_types
    gon.pagename = 'GS:CommunityScorecard'
  end
end
