class CommunityScorecardsController < ApplicationController

  before_filter :use_gs_bootstrap

  def show
    @collection = Collection.find(15)
  end
end