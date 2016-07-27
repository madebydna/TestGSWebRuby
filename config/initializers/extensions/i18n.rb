module I18n
  extend ::GsI18n

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

I18n.available_locales = [:en, :es]
I18n.exception_handler = I18n::GSLoggingExceptionHandler.new
