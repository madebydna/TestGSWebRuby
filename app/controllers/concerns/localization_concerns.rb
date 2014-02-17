module LocalizationConcerns
  extend ActiveSupport::Concern

  def set_hub_cookies
    write_cookie_value :hubState, @school.state.upcase unless @school.nil?
    write_cookie_value :hubCity, @school.hub_city unless @school.nil?
    write_cookie_value :ishubUser, 'y' # typo in camel casing needs to be like this to match GSWeb java code
  end

  def is_school_for_localized_profiles
    collection_id = @school.school_metadata.collection_id
    hub_city_mapping = HubCityMapping.where(collection_id: collection_id).first
    !hub_city_mapping.nil? && hub_city_mapping.city.downcase == 'detroit' && hub_city_mapping.state.downcase == 'mi'
  end

end
