class StatesController < ApplicationController
  before_filter :set_city_state
  before_filter :set_hub_params
  before_filter :set_login_redirect
  before_filter :set_footer_cities

  def foobar
  end

  def show
    collection_mapping = mapping
    if collection_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      collection_id = collection_mapping.collection_id
      configs = CollectionConfig.where(collection_id: collection_id)
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @content_modules = CollectionConfig.content_modules(configs)
      @sponsor = CollectionConfig.sponsor(configs, :state)
      @sponsor[:sponsor_page_visible] = mapping.has_partner_page? if @sponsor

      @partners = CollectionConfig.state_partners(configs)
      @choose_school = CollectionConfig.state_choose_school(configs)

      @articles = CollectionConfig.state_featured_articles(configs)

      @hero_image = "/assets/hubs/desktop/#{collection_id}-#{@state[:short].upcase}_hero.jpg"
      @hero_image_mobile  = "/assets/hubs/small/#{collection_id}-#{@state[:short].upcase}_hero_small.jpg"
    end
  end


  private
    def mapping
      hub_city_mapping_key = "hub_city_mapping-city:#{@state[:long]}-active:1"
      Rails.cache.fetch(hub_city_mapping_key, expires_in: 1.day) do
        HubCityMapping.where(active: 1, city: nil, state: @state[:short]).first
      end
    end
end
