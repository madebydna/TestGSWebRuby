class CitySearchResult
  include ActionView::Helpers::AssetTagHelper
  include UrlHelper

  attr_accessor :name, :name_url, :state, :state_name, :number_of_schools, :latitude, :longitude, :state_name_url

  KEYS_TO_DELETE = ['contentKey', 'document_type', 'indexedTimestamp']

  def initialize(hash)
    hash.entries.each do |key, value|
      hash[key[5..-1]] = value if key.start_with? 'city_' # strip the preceding 'city_' from keys
    end
    hash.delete_if { |key| key.start_with?('city_') || KEYS_TO_DELETE.include?(key)}
    @state = get_state_abbreviation(hash)
    hash.delete('state')
    @state_name = States.state_name(@state)
    @state_name_url = gs_legacy_url_encode(@state_name)
    @name = hash.delete('sortable_name')
    @name = 'Washington, DC' if @state == 'DC' and @name == 'Washington'
    @name_url = gs_legacy_url_encode(@name)
    @number_of_schools = hash.delete('number_of_schools')
    @latitude = hash.delete('latitude')
    @longitude = hash.delete('longitude')
    hash.delete('name')
    hash.delete('keyword')
    hash.delete('citystate')

    @attributes = hash
    @attributes.each do |k,v|
      define_singleton_method k do v end
    end
  end

  protected

  def get_state_abbreviation(hash)
    if hash.include? 'state'
      return hash['state'].select {|v| v.length == 2 && States.abbreviation_hash.include?(v)}[0]
    end
    nil
  end
end
