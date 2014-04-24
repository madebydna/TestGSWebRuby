class PathWithPeriod
  def self.matches?(request)
    !!request.path.match(/\./)
  end

  def self.url_without_period_in_path(params, request)
    path_without_period = request.path.gsub('.', '')

    request.original_url.sub request.path, path_without_period
  end
end