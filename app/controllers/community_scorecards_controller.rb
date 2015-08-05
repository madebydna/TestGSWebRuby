class CommunityScorecardsController < ApplicationController

def show
  @collection = Collection.find(15)
end
end