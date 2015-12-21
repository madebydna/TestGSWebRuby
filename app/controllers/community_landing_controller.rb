class CommunityLandingController < ApplicationController

  before_action :set_city_state


  def show
    gon.pagename = 'GS:Home:CommunityLandingPage'
    set_meta_tags title: 'Connect With Greatschools',
                  description:'Tell your school\'s story. Connect with Greatschools',
                  keywords:'Connect with Greatschools,Find Community with Greatschools'

    render 'home/community_landing'

 end
end
