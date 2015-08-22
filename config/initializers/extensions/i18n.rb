module I18n

  def self.db_t(key, *args)
    default = args.first[:default] if args.first.is_a?(Hash) && args.first[:default]
    if key.blank?
      GSLogger.warn(:i18n, nil, vars: [key] + args, message: 'db_t received blank key')
      return default || key
    end
    cleansed_key = key.to_s.gsub('.', '')
    cleansed_key = cleansed_key.to_sym if key.is_a?(Symbol)
    self.t(cleansed_key, *args)
  end

  def self.non_default_locale
    locale != default_locale && locale_available?(locale) ? locale.to_s : nil
  end

  class GSLoggingExceptionHandler < ExceptionHandler
    def call(exception, locale, key, options)
      if exception.is_a?(MissingTranslation)
        GSLogger.warn(:i18n, nil, vars: options.merge(key: key, locale: locale), message: "Translation missing for #{key}")
        super
      else
        super
      end
    end
  end

end

I18n.exception_handler = I18n::GSLoggingExceptionHandler.new
