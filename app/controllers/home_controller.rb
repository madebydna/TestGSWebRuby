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
                      title: t('home.controller.og_title'),
                      description: t('home.controller.og_description'),
                      site_name: 'GreatSchools.org',
                      image: {
                        url: asset_full_url('assets/share/logo-ollie-large.png'),
                        secure_url: asset_full_url('assets/share/logo-ollie-large.png'),
                        height: 600,
                        width: 1200,
                        type: 'image/png',
                        alt: 'GreatSchools is a non profit organization providing school quality information'
                      },
                      type: 'website',
                      url: home_url
                  },
                  twitter: {
                      image: asset_full_url('assets/share/GreatSchoolsLogo-social-optimized.png'),
                      card: 'Summary',
                      site: '@GreatSchools',
                      description: t('home.controller.twitter_description')
                  }
    @homepage_banner_prop = PropertyConfig.get_property('homePageGreatKidsMilestoneBannerActive', 'false')
    gon.pagename = "Homepage"

    # NOTE: this is temporary until we get the final list from product
    @city_list_for_footer = ['Albuquerque, NM', 'Allentown, PA', 'Anchorage, AK', 'Atlanta, GA', 'Austin, TX', 'Baltimore, MD', 'Bellingham, WA',
                             'Boise, ID', 'Boston, MA', 'Bridgeport, CT', 'Charleston, WV', 'Charlotte, NC', 'Chicago, IL', 'Colorado Springs, CO',
                             'Columbus, OH', 'Dallas, TX', 'Denver, CO', 'Des Moines, IA', 'Detroit, MI', 'Fort Lauderdale, FL', 'Grand Rapids, MI',
                             'Honolulu, HI', 'Houston, TX', 'Huntsville, AL', 'Indianapolis, IN', 'Irvine, CA', 'Jacksonville, FL', 'Kansas City, MO',
                             'Las Vegas, NV', 'Little Rock, AR', 'Long Beach, CA', 'Los Angeles, CA', 'Manchester, NH', 'Marietta, GA', 'Memphis, TN',
                             'Miami, FL', 'Milwaukee, WI', 'Minneapolis, MN', 'New Orleans, LA', 'New York, NY', 'Newark, NJ', 'Oakland, CA',
                             'Oklahoma City, OK', 'Omaha, NE', 'Orlando, FL', 'Pasadena, CA', 'Philadelphia, PA', 'Phoenix, AZ', 'Sacramento, CA',
                             'Salt Lake City, UT', 'San Antonio, TX', 'San Diego, CA', 'San Francisco, CA', 'San Jose, CA', 'Seattle, WA', 'Sioux Falls, SD',
                             'Tacoma, WA', 'Tampa, FL', 'Temecula, CA', 'Tucson, AZ', 'Virginia Beach, VA', 'Washington, DC', 'West Palm Beach, FL',
                             'Wilmington, DE']
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
