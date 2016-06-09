module CityParamsConcerns

  protected

  def city_param
    return if params[:city].nil?
    gs_legacy_url_decode(params[:city])
  end

  def require_city_instance_variable
    if @city.nil?
      block_given? ? yield : render('error/page_not_found', layout: 'error', status: 404)
    end
  end

end
