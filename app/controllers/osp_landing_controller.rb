class OspLandingController < ApplicationController


  def show

    page_title = 'Edit your school profile at GreatSchools'
    gon.pageTitle = page_title
    gon.pagename = "OspLanding"
    set_omniture_data('GS:OSP:LandingPage', 'Home,OSP,LandingPage')
    set_meta_tags title: page_title,
                  description:'Tell your school\'s story. Create a free school account on GreatSchools to claim and edit your school profile.',
                  keywords:'school account, school profile, edit profile, school leader account, school principal account, school official account'
    data_layer_gon_hash.merge!(
      {
        'page_name' => 'GS:OSP:LandingPage',
      }
    )

    render 'osp/osp_landing'
  end

end