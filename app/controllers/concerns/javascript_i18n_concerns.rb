module JavascriptI18nConcerns
  extend ActiveSupport::Concern

  protected

  TRANSLATIONS_TO_ADD_TO_JS = [
    'data_layouts.test_scores.advanced',
    'data_layouts.test_scores.proficient',
    'data_layouts.test_scores.proficient_or_better'
  ].freeze

  # I18n.available_locales returns locales we don't have translations for, so hard-code this for now
  LOCALES_TO_USE_FOR_JS_TRANSLATIONS = %w[en es]

  def add_configured_translations_to_js
    TRANSLATIONS_TO_ADD_TO_JS.each do |key|
      LOCALES_TO_USE_FOR_JS_TRANSLATIONS.each do |locale|
        value = I18n.t(key, locale: locale) # inefficient way of doing this?
        add_translation_to_js(key, value, locale)
      end
    end
  end

  def add_translation_to_js(key, value, locale)
    gon.translations ||= {}
    gon.translations[locale] ||= {}
    gon.translations[locale][key] = value
  end

end