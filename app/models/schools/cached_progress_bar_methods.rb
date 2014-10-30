module CachedProgressBarMethods
  def progress_bar
    cache_data['progress_bar'] || {}
  end

end