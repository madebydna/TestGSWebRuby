module I18n

  def self.db_t(key, *args)
    cleansed_key = key.to_s.gsub('.', '')
    cleansed_key = cleansed_key.to_sym if key.is_a?(Symbol)
    self.t(cleansed_key, *args)
  end

  def self.non_default_locale
    locale != default_locale && locale_available?(locale) ? locale.to_s : nil
  end

end
