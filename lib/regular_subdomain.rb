class RegularSubdomain
  def self.matches?(request)

    request.domain.nil? ||
    (request.subdomain.blank? && request.domain[-9..-1] == 'localhost') ||
      (request.subdomain.present? && request.subdomain.match(/^(?!pk(\.|$)).*/))

  end
end
