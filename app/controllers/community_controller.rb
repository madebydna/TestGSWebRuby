class CommunityController < ApplicationController

  before_filter :use_gs_bootstrap

  def home
    # this landing page for now is hardcoded for the bay area
    # if we ever scale this out to other collections 
    # we'll need to change this code
    #
    @collection_id = params[:collection_id].to_i
    return redirect_to home_path unless @collection_id == 15
    @t_scope = "collection_id_#{@collection_id}"
    set_gon_vars!
    set_meta_tags!
  end

  def set_gon_vars!
    gon.pagename   = "CommunityHomePage"
    gon.state_abbr = 'ca'
  end

  def set_meta_tags!
    set_meta_tags(
      title: 'San Francisco Bay Area School Search',
      description: 'Find the best possible school for your child using ratings, reviews and in-depth school data.'
    )
  end

end
