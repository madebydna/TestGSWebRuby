class PreschoolSubdomain
  def self.matches?(request)
    request.domain.nil? ||
    (request.subdomain.blank? && request.domain[-9..-1] == 'localhost') ||
      (request.subdomain.present? && request.subdomain.match(/^pk(\.|$).*/))
  end

  def self.current_url_on_pk_subdomain(params, request)
    if request.subdomain.present?
      if request.subdomain == 'www'
        new_url = request.original_url.sub "www.", "pk."
      else
        new_url = request.original_url.sub "#{request.subdomain}.", "pk.#{request.subdomain}."
      end
    else
      new_url = request.original_url
    end
  end

  def self.current_url_without_pk_subdomain(params, request)
    if request.subdomain.present?
      if request.subdomain == 'pk'
        new_url = request.original_url.sub 'pk.', 'www.'
      else
        # The subdomain is more than just 'pk'. Such as pk.dev.
        new_url = request.original_url.sub 'pk.', ''
      end
    else
      new_url = request.original_url
    end
  end

  # For a given request, return the non pk'ed version of the subdomain
  # pk.dev -> dev,  localhost -> localhost, pk -> www
  def self.default_subdomain(request)
    if request.subdomain.present?
      if request.subdomain == 'pk'
        new_subdomain = 'www'
      else
        new_subdomain = request.subdomain.sub /^pk\./, ''
      end
    else
      new_subdomain = ''
    end
  end

  # For a given request, return the pk'ed version of the subdomain
  # dev -> pk.dev,  localhost -> localhost, www -> pk
  def self.pk_subdomain(request)
    if request.subdomain.present?
      if request.subdomain.match /^pk/
        new_subdomain = request.subdomain
      elsif request.subdomain == 'www'
        new_subdomain = 'pk'
      else
        new_subdomain = "pk.#{request.subdomain}"
      end
    else
      new_subdomain = ''
    end
  end

end
