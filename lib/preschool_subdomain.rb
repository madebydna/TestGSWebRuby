class PreschoolSubdomain
  def self.matches?(request)
    (request.subdomain.blank? && request.domain[-9..-1] == 'localhost') ||
      (request.subdomain.present? && request.subdomain.match(/^pk\..*/))
  end

  def self.current_url_on_pk_subdomain(params, request)
    if request.subdomain.present?
      if request.subdomain == 'www'
        new_url = request.original_url.sub "www.", "pk."
      else
        new_url = request.original_url.sub "#{request.subdomain}.", "pk.#{request.subdomain}."
      end
    else
      new_url = request.original_url.sub "#{request.domain}.", "pk.#{request.domain}."
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
      new_url = request.original_url.sub 'pk.', ''
    end
  end

end