class Collection < ActiveRecord::Base
  db_magic :connection => :gs_schooldb

  attr_accessible :id, :name, :definition, :config

  has_one :hub_city_mapping
  has_many :school_collections

  def schools
    @schools ||= (
      definition.keys.map do |state|
        School.on_db(state.to_s.downcase.to_sym).for_collection(id).active.to_a
      end.flatten
    )
  end

  def config
    @_config ||= read_json_attribute(:config)
  end

  def url_name
    config[:url_name]
  end

  def scorecard_scope
    config[:scorecard_scope]
  end

  def scorecard_fields
    config[:scorecard_fields]
  end

  def definition
    @_definition ||= read_json_attribute(:definition)
  end

  def self.for_school(state, school_id)
    ids = SchoolCollection.school_collection_mapping[[state, school_id]]
    where(id: ids).to_a
  end

  # These methods are deprecated, but still work.
  # Collection-specific configuration should be moved to this model's config
  # attribute and hub-specific config should live in the hub_config model.
  def hub_config
    @_hub_config ||= CollectionConfig.key_value_map self.id
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
