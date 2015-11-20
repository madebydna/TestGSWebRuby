class CommunityController < ApplicationController

  before_filter :use_gs_bootstrap

  def home
    # this landing page for now is hardcoded for the bay area
    # if we ever scale this out to other collections 
    # we'll need to change this code
    return redirect_to home_path unless params[:collection_id].to_i == 15
    @t_scope = "collection_id_#{params[:collection_id]}"
    gon.pagename = "CommunityHomePage"
    gon.state_abbr = 'ca'
  end

end
