module HubConcerns 

  extend ActiveSupport::Concern
  
  private

  def set_up_localized_search_hub_params
    if local_search?
      if hub_city_state?
        set_hub_params(@state,@city.name)
      elsif hub_state?
        set_hub_params(@state,nil)
      elsif first_school_result_is_in_hub?
        set_hub_params(@state,@first_school.hub_city)
      end
    end
  end

  def local_search?
    if search_by_location? || search_by_name?
      first_school_result_is_in_hub?
    else
      hub_city_state? || hub_state?
    end
  end

  def first_school_result_is_in_hub?
    if @schools.present?
      @first_school = School.on_db(@schools.first.database_state.first).find(@schools.first.id)
      is_hub_school?(@first_school)
    end
  end

  def hub_city_state?
    @city && @state && HubCityMapping.where(active: 1, city: @city.name, state: @state[:short]).present?
  end

  def hub_state?
    @state && HubCityMapping.where(active: 1, city: nil, state: @state[:short]).present?
  end

end
