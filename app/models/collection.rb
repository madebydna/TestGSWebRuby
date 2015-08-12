class Collection < ActiveRecord::Base
  db_magic :connection => :gs_schooldb

  attr_accessible :id, :name, :definition, :config

  has_one :hub_city_mapping
  has_many :school_collections

  scope :for_school, ->(state, school_id) do
    joins(:school_collections)
      .where('state = ? and school_id = ?', state, school_id)
  end

  def schools
    @schools ||= (
      definition.keys.map do |state|
        School.on_db(state.to_s.downcase.to_sym).for_collection(id).active.to_a
      end.flatten
    )
  end

  def config
    @config ||= read_json_attribute(:config)
  end

  def definition
    @config ||= read_json_attribute(:definition)
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

  protected

  def read_json_attribute(attribute)
    begin
      JSON.parse(read_attribute(attribute)).with_indifferent_access
    rescue
      {}
    end
  end
end
