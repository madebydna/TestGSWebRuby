class Collection < ActiveRecord::Base
  db_magic :connection => :gs_schooldb

  attr_accessible :id, :state, :name, :definition, :config

  has_one :hub_city_mapping

  def config
    @config ||= begin
                JSON.parse(read_attribute(:config)).with_indifferent_access
              rescue
                {}
              end
  end

  # These methods are deprecated, but still work.
  # Collection-specific configuration should be moved to this model's config
  # attribute and hub-specific config should live in the hub_config model.
  def hub_config
    @hub_config ||= CollectionConfig.key_value_map self.id
    @hub_config
  end

  def show_ads
    (hub_config['showAds'] != "false")
  end

  def profile_banner
    hash = nil
    if hub_config['profilePage_overview_banner'].present?
      hash = JSON.parse(hub_config['profilePage_overview_banner'])
    end
    hash
  end

end
