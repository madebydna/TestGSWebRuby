class HomeController < ApplicationController
  protect_from_forgery

  before_action :ad_setTargeting_through_gon
  before_action :data_layer_through_gon
  before_action :set_login_redirect

  layout "home"

  def show

    @show_ads = PropertyConfig.advertising_enabled?

    @canonical_url = home_url
    # Description lives in view because the meta-tags gem truncates description at 200 chars. See https://github.com/kpumuk/meta-tags
    set_meta_tags title: t('home.controller.meta_title'),
                  og: {
                      title: "K-12 school quality information and parenting resources",
                      description: t('home.controller.meta_description'),
                      site_name: 'GreatSchools.org',
                      image: {
                        url: asset_full_url('assets/share/logo-ollie-large.png'),
                        secure_url: asset_full_url('assets/share/logo-ollie-large.png'),
                        height: 600,
                        width: 1200,
                        type: 'image/png',
                        alt: 'GreatSchools is a non profit organization providing school quality information'
                      },
                      type: 'place',
                      url: home_url
                  },
                  twitter: {
                      image: asset_full_url('assets/share/GreatSchoolsLogo-social-optimized.png'),
                      card: 'Summary',
                      site: '@GreatSchools',
                      description: 'View parent ratings, reviews and test scores and choose the right preschool, elementary, middle or high school for public or private education.'
                  }
    @homepage_banner_prop = PropertyConfig.get_property('homePageGreatKidsMilestoneBannerActive', 'false')
    gon.pagename = "Homepage"

  end

  def page_view_metadata
    @page_view_metadata ||= (
    page_view_metadata = {}
    page_view_metadata['page_name']   = 'GS:Home'
    page_view_metadata['compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
    page_view_metadata['env']         = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    page_view_metadata['template']    = 'homepage' # use this for page name - configured_page_name
    page_view_metadata['editorial']   = 'pushdownad'

    page_view_metadata

    )
  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
      page_view_metadata.each do |key, value|
        ad_targeting_gon_hash[key] = value
      end
  end

  def data_layer_through_gon
    data_layer_gon_hash.merge!(page_view_metadata)
  end

  protected

  def greatkids_content
    @_greatkids_content ||= ExternalContent.try(:homepage_features)
  end

  private

  # StructuredMarkup
  def prepare_json_ld
    add_json_ld(StructuredMarkup.organization_hash)
  end
end
